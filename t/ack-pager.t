#!perl -T

use strict;
use warnings;

use File::Spec ();
use File::Temp ();
use Test::More;

use lib 't';
use Util;

if ( not has_io_pty() ) {
    plan skip_all => q{You need to install IO::Pty to run this test};
    exit(0);
}

plan tests => 15;

prep_environment();

NO_PAGER: {
    my @args = qw(--nocolor Sue t/text);

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
6:Was before he left, he went and named me Sue.
13:I tell ya, life ain't easy for a boy named Sue.
27:Sat the dirty, mangy dog that named me Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
62:Cause I'm the son-of-a-bitch that named you Sue."
70:Bill or George! Anything but Sue! I still hate that name!
72:    -- "A Boy Named Sue", Johnny Cash
END_TEXT

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'NO_PAGER' );
}

PAGER: {
    my @args = qw(--nocolor --pager=./test-pager Sue t/text);

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
6:Was before he left, he went and named me Sue.
13:I tell ya, life ain't easy for a boy named Sue.
27:Sat the dirty, mangy dog that named me Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
62:Cause I'm the son-of-a-bitch that named you Sue."
70:Bill or George! Anything but Sue! I still hate that name!
72:    -- "A Boy Named Sue", Johnny Cash
END_TEXT

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'PAGER' );
}

PAGER_WITH_OPTS: {
    my @args = ('--nocolor', '--pager=./test-pager --skip=2', 'Sue', 't/text');

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
13:I tell ya, life ain't easy for a boy named Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
70:Bill or George! Anything but Sue! I still hate that name!
END_TEXT

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'PAGER_WITH_OPTS' );
}

FORCE_NO_PAGER: {
    my @args = ('--nocolor', '--pager=./test-pager --skip=2', '--nopager',
        'Sue', 't/text');

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
6:Was before he left, he went and named me Sue.
13:I tell ya, life ain't easy for a boy named Sue.
27:Sat the dirty, mangy dog that named me Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
62:Cause I'm the son-of-a-bitch that named you Sue."
70:Bill or George! Anything but Sue! I still hate that name!
72:    -- "A Boy Named Sue", Johnny Cash
END_TEXT

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'FORCE_NO_PAGER' );
}

PAGER_ENV: {
    local $ENV{'ACK_PAGER'} = './test-pager --skip=2';
    local $TODO             = q{Setting ACK_PAGER in tests won't work for the time being};

    my @args = ('--nocolor', 'Sue', 't/text');

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
13:I tell ya, life ain't easy for a boy named Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
70:Bill or George! Anything but Sue! I still hate that name!
END_TEXT

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'PAGER_ENV' );
}

PAGER_ENV_OVERRIDE: {
    local $ENV{'ACK_PAGER'} = './test-pager --skip=2';

    my @args = ('--nocolor', '--nopager', 'Sue', 't/text');

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
6:Was before he left, he went and named me Sue.
13:I tell ya, life ain't easy for a boy named Sue.
27:Sat the dirty, mangy dog that named me Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
62:Cause I'm the son-of-a-bitch that named you Sue."
70:Bill or George! Anything but Sue! I still hate that name!
72:    -- "A Boy Named Sue", Johnny Cash
END_TEXT

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'PAGER_ENV_OVERRIDE' );
}

PAGER_ACKRC: {
    my @args = ('--nocolor', 'Sue', 't/text');

    my $ackrc = <<'END_ACKRC';
--pager=./test-pager --skip=2
END_ACKRC

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
13:I tell ya, life ain't easy for a boy named Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
70:Bill or George! Anything but Sue! I still hate that name!
END_TEXT

    my @got = run_ack_interactive(@args, {
        ackrc => \$ackrc,
    });

    lists_match( \@got, \@expected, 'PAGER_ACKRC' );
}

PAGER_ACKRC_OVERRIDE: {
    my @args = ('--nocolor', '--nopager', 'Sue', 't/text');

    my $ackrc = <<'END_ACKRC';
--pager=./test-pager --skip=2
END_ACKRC

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
6:Was before he left, he went and named me Sue.
13:I tell ya, life ain't easy for a boy named Sue.
27:Sat the dirty, mangy dog that named me Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
62:Cause I'm the son-of-a-bitch that named you Sue."
70:Bill or George! Anything but Sue! I still hate that name!
72:    -- "A Boy Named Sue", Johnny Cash
END_TEXT

    my @got = run_ack_interactive(@args, {
        ackrc => \$ackrc,
    });

    lists_match( \@got, \@expected, 'PAGER_ACKRC_OVERRIDE' );
}

PAGER_NOENV: {
    local $ENV{'ACK_PAGER'} = './test-pager --skip=2';

    my @args = ('--nocolor', '--noenv', 'Sue', 't/text');

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
6:Was before he left, he went and named me Sue.
13:I tell ya, life ain't easy for a boy named Sue.
27:Sat the dirty, mangy dog that named me Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
62:Cause I'm the son-of-a-bitch that named you Sue."
70:Bill or George! Anything but Sue! I still hate that name!
72:    -- "A Boy Named Sue", Johnny Cash
END_TEXT

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'PAGER_NOENV' );
}

my $wd      = getcwd_clean();
my $tempdir = File::Temp->newdir;
my $pager   = File::Spec->rel2abs('test-pager');
mkdir File::Spec->catdir($tempdir->dirname, 'subdir');

PROJECT_ACKRC_PAGER_FORBIDDEN: {
    my @files = untaint( File::Spec->rel2abs('t/text/') );
    my @args = qw/ --env question(\\S+) /;

    chdir $tempdir->dirname;
    write_file '.ackrc', "--pager=$pager\n";

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args, @files);

    is_empty_array( $stdout );
    first_line_like( $stderr, qr/\QOptions --output, --pager and --match are forbidden in project .ackrc files/ );

    chdir $wd;
}

HOME_ACKRC_PAGER_PERMITTED: {
    my @files = untaint( File::Spec->rel2abs('t/text/') );
    my @args = qw/ --env question(\\S+) /;

    write_file(File::Spec->catfile($tempdir->dirname, '.ackrc'), "--pager=$pager\n");
    chdir File::Spec->catdir($tempdir->dirname, 'subdir');
    local $ENV{'HOME'} = $tempdir->dirname;

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args, @files);

    is_nonempty_array( $stdout );
    is_empty_array( $stderr );

    chdir $wd;
}

ACKRC_ACKRC_PAGER_PERMITTED: {
    my @files = untaint( File::Spec->rel2abs('t/text/') );
    my @args = qw/ --env question(\\S+) /;

    write_file(File::Spec->catfile($tempdir->dirname, '.ackrc'), "--pager=$pager\n");
    chdir File::Spec->catdir($tempdir->dirname, 'subdir');
    local $ENV{'ACKRC'} = File::Spec->catfile($tempdir->dirname, '.ackrc');

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args, @files);

    is_nonempty_array( $stdout );
    is_empty_array( $stderr );

    chdir $wd;
}
