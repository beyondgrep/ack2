#!/usr/bin/env perl

use strict;
use warnings;
use lib 't';

use Util;
use Cwd qw(getcwd);
use Test::More tests => 14;
use File::Spec;
use File::Temp;

prep_environment();

my $orig_wd            = getcwd();
my $tempdir            = File::Temp->newdir;
my $existing_ackrc     = File::Spec->catfile($tempdir->dirname, 'existing-ackrc');
my $non_existing_ackrc = File::Spec->catfile($tempdir->dirname, 'non-existing-ackrc');

my ( $stdout, $stderr );

FOO_TYPE_SANITY_CHECK: {
    ( $stdout, $stderr ) = run_ack_with_stderr('-f', '--foo');

    is(scalar(@$stdout), 0, 'No lines should be printed on standard output for --foo');
    ok(scalar(@$stderr) > 0, 'At least one line should be printed on standard error for --foo') or diag(explain($stderr));
}

FOO_TYPE_VIA_ABSOLUTE_INCLUDE: {
    write_file($existing_ackrc, <<'END_ACKRC');
--type-add=foo:ext:badextension
END_ACKRC

    ( $stdout, $stderr ) = run_ack_with_stderr('-f', '--foo', {
        ackrc => \<<"END_ACKRC",
--include=$existing_ackrc
END_ACKRC
    });
    is(scalar(@$stdout), 0, 'No lines should be printed on standard output for --foo') or diag(explain($stdout));
    is(scalar(@$stderr), 0, q{No lines should be printed on standard error for --foo when its definition is --include'd}) or diag(explain($stderr));
}

MISSING_INCLUDE_FILE: {
    ( $stdout, $stderr ) = run_ack_with_stderr('-f', '--rust', {
        ackrc => \<<"END_ACKRC",
--include=$non_existing_ackrc
END_ACKRC
    });

    is(scalar(@$stdout), 0, 'No lines should be printed on standard output for --rust');
    is(scalar(@$stderr), 0, 'No errors should occur due a missing --include file') or diag(explain($stderr));
}

INCLUDE_FILE_ORDER: {
    write_file($existing_ackrc, <<'END_ACKRC');
--type-del=foo
--type-del=bar
END_ACKRC

    ( $stdout, $stderr ) = run_ack_with_stderr('--help-types', {
        ackrc => \<<"END_ACKRC",
--type-add=foo:ext:foo
--include=$existing_ackrc
--type-add=bar:ext:bar
END_ACKRC
    });

    my $has_seen_foo = 0;
    my $has_seen_bar = 0;

    foreach my $line (@$stdout) {
        if($line =~ /\Q--[no]foo\E/) {
            $has_seen_foo = 1;
        }
        elsif($line =~ /\Q--[no]bar\E/) {
            $has_seen_bar = 1;
        }
    }

    my $both_succeeding = 1;

    $both_succeeding &&=
        ok(!$has_seen_foo, q{Type definition for type 'foo' should not be in help-types when removed from an --include'd file following it definition});

    $both_succeeding &&=
        ok($has_seen_bar, q{Type definition for type 'bar' should be in help-types when removed from an --include'd file preceding its defintion});

    unless($both_succeeding) {
        diag(explain($stdout));
    }
}

INCLUDE_COMMAND_LINE: {
    write_file($existing_ackrc, <<'END_ACKRC');
--type-del=foo
--type-del=bar
END_ACKRC

    ( $stdout, $stderr ) = run_ack_with_stderr('--include=' . $existing_ackrc);

    is(scalar(@$stdout), 0, 'When providing --include on the command line, no lines should be printed to standard output');
    ok(@$stderr > 0, 'When providing --include on the command line, at least one line should be printed to standard error');
}

# XXX If we do allow this in the future, consider and add tests for a depth limit and cycles
SUBINCLUDE: {
    write_file($existing_ackrc, <<"END_ACKRC");
--include=$non_existing_ackrc
END_ACKRC

    ( $stdout, $stderr ) = run_ack_with_stderr('-f', 't/swamp/', {
        ackrc => \<<"END_ACKRC",
--include=$existing_ackrc
END_ACKRC
    });

    is(scalar(@$stdout), 0, 'An --include directive in an included file should result in nothing being printed to standard output');
    ok(@$stderr > 0, 'An --include directive in an included file should result in at least one line being printed to standard error');
}

RELATIVE_INCLUDE: {
    write_file($existing_ackrc, <<'END_ACKRC');
--type-del=foo
END_ACKRC

    my ( undef, undef, $ackrc_basename ) = File::Spec->splitpath($existing_ackrc);

    chdir $tempdir->dirname or die "Unable to change directory: $!";

    ( $stdout, $stderr ) = run_ack_with_stderr('--help-types', {
        ackrc => \<<"END_ACKRC",
--type-add=foo:ext:foo
--include=$ackrc_basename
END_ACKRC
    });

    my $has_seen_foo = 0;

    foreach my $line (@$stdout) {
        if($line =~ /\Q--[no]foo\E/) {
            $has_seen_foo = 1;
        }
    }

    chdir $orig_wd or die "Unable to change directory: $!";

    ok(@$stderr == 0, q{Relative includes shouldn't print anything to standard error}) or diag(explain($stderr));
    ok(!$has_seen_foo, '--included files with relative paths should be resolved relative to the including file');
}

# XXX --dump
