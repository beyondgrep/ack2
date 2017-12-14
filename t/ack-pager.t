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
    my @args = qw(--nocolor --sort-files -i nevermore t/text);

    my @expected = line_split( <<'HERE' );
t/text/raven.txt
55:    Quoth the Raven, "Nevermore."
62:    With such name as "Nevermore."
69:    Then the bird said, "Nevermore."
76:    Of 'Never -- nevermore.'
83:    Meant in croaking "Nevermore."
90:    She shall press, ah, nevermore!
97:    Quoth the Raven, "Nevermore."
104:    Quoth the Raven, "Nevermore."
111:    Quoth the Raven, "Nevermore."
118:    Quoth the Raven, "Nevermore."
125:    Shall be lifted--nevermore!
HERE

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'NO_PAGER' );
}

PAGER: {
    my @args = qw(--nocolor --pager=./test-pager --sort-files -i nevermore t/text);

    my @expected = line_split( <<'HERE' );
t/text/raven.txt
55:    Quoth the Raven, "Nevermore."
62:    With such name as "Nevermore."
69:    Then the bird said, "Nevermore."
76:    Of 'Never -- nevermore.'
83:    Meant in croaking "Nevermore."
90:    She shall press, ah, nevermore!
97:    Quoth the Raven, "Nevermore."
104:    Quoth the Raven, "Nevermore."
111:    Quoth the Raven, "Nevermore."
118:    Quoth the Raven, "Nevermore."
125:    Shall be lifted--nevermore!
HERE

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'PAGER' );
}

PAGER_WITH_OPTS: {
    my @args = ('--nocolor', '--pager=./test-pager --skip=2', '--sort-files', '-i', 'nevermore', 't/text');

    my @expected = line_split( <<'HERE' );
t/text/raven.txt
62:    With such name as "Nevermore."
76:    Of 'Never -- nevermore.'
90:    She shall press, ah, nevermore!
104:    Quoth the Raven, "Nevermore."
118:    Quoth the Raven, "Nevermore."
HERE

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'PAGER_WITH_OPTS' );
}

FORCE_NO_PAGER: {
    my @args = ('--nocolor', '--pager=./test-pager --skip=2', '--nopager', '--sort-files',
        '-i', 'nevermore', 't/text');

    my @expected = line_split( <<'HERE' );
t/text/raven.txt
55:    Quoth the Raven, "Nevermore."
62:    With such name as "Nevermore."
69:    Then the bird said, "Nevermore."
76:    Of 'Never -- nevermore.'
83:    Meant in croaking "Nevermore."
90:    She shall press, ah, nevermore!
97:    Quoth the Raven, "Nevermore."
104:    Quoth the Raven, "Nevermore."
111:    Quoth the Raven, "Nevermore."
118:    Quoth the Raven, "Nevermore."
125:    Shall be lifted--nevermore!
HERE

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'FORCE_NO_PAGER' );
}

PAGER_ENV: {
    local $ENV{'ACK_PAGER'} = './test-pager --skip=2';
    local $TODO             = q{Setting ACK_PAGER in tests won't work for the time being};

    my @args = ('--nocolor', '--sort-files', '-i', 'nevermore', 't/text');

    my @expected = line_split( <<'HERE' );
t/text/raven.txt
62:    With such name as "Nevermore."
76:    Of 'Never -- nevermore.'
90:    She shall press, ah, nevermore!
104:    Quoth the Raven, "Nevermore."
118:    Quoth the Raven, "Nevermore."
HERE

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'PAGER_ENV' );
}

PAGER_ENV_OVERRIDE: {
    local $ENV{'ACK_PAGER'} = './test-pager --skip=2';

    my @args = ('--nocolor', '--nopager', '--sort-files', '-i', 'nevermore', 't/text');

    my @expected = line_split( <<'HERE' );
t/text/raven.txt
55:    Quoth the Raven, "Nevermore."
62:    With such name as "Nevermore."
69:    Then the bird said, "Nevermore."
76:    Of 'Never -- nevermore.'
83:    Meant in croaking "Nevermore."
90:    She shall press, ah, nevermore!
97:    Quoth the Raven, "Nevermore."
104:    Quoth the Raven, "Nevermore."
111:    Quoth the Raven, "Nevermore."
118:    Quoth the Raven, "Nevermore."
125:    Shall be lifted--nevermore!
HERE

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'PAGER_ENV_OVERRIDE' );
}


PAGER_ACKRC: {
    my @args = ('--nocolor', '--sort-files', '-i', 'nevermore', 't/text');

    my $ackrc = <<'HERE';
--pager=./test-pager --skip=2
HERE

    my @expected = line_split( <<'HERE' );
t/text/raven.txt
62:    With such name as "Nevermore."
76:    Of 'Never -- nevermore.'
90:    She shall press, ah, nevermore!
104:    Quoth the Raven, "Nevermore."
118:    Quoth the Raven, "Nevermore."
HERE

    my @got = run_ack_interactive(@args, {
        ackrc => \$ackrc,
    });

    lists_match( \@got, \@expected, 'PAGER_ACKRC' );
}


PAGER_ACKRC_OVERRIDE: {
    my @args = ('--nocolor', '--nopager', '--sort-files', '-i', 'nevermore', 't/text');

    my $ackrc = <<'HERE';
--pager=./test-pager --skip=2
HERE

    my @expected = line_split( <<'HERE' );
t/text/raven.txt
55:    Quoth the Raven, "Nevermore."
62:    With such name as "Nevermore."
69:    Then the bird said, "Nevermore."
76:    Of 'Never -- nevermore.'
83:    Meant in croaking "Nevermore."
90:    She shall press, ah, nevermore!
97:    Quoth the Raven, "Nevermore."
104:    Quoth the Raven, "Nevermore."
111:    Quoth the Raven, "Nevermore."
118:    Quoth the Raven, "Nevermore."
125:    Shall be lifted--nevermore!
HERE

    my @got = run_ack_interactive(@args, {
        ackrc => \$ackrc,
    });

    lists_match( \@got, \@expected, 'PAGER_ACKRC_OVERRIDE' );
}

PAGER_NOENV: {
    local $ENV{'ACK_PAGER'} = './test-pager --skip=2';

    my @args = ('--nocolor', '--noenv', '--sort-files', '-i', 'nevermore', 't/text');

    my @expected = line_split( <<'HERE' );
t/text/raven.txt
55:    Quoth the Raven, "Nevermore."
62:    With such name as "Nevermore."
69:    Then the bird said, "Nevermore."
76:    Of 'Never -- nevermore.'
83:    Meant in croaking "Nevermore."
90:    She shall press, ah, nevermore!
97:    Quoth the Raven, "Nevermore."
104:    Quoth the Raven, "Nevermore."
111:    Quoth the Raven, "Nevermore."
118:    Quoth the Raven, "Nevermore."
125:    Shall be lifted--nevermore!
HERE

    my @got = run_ack_interactive(@args);

    lists_match( \@got, \@expected, 'PAGER_NOENV' );
}

my $wd      = getcwd_clean();
my $tempdir = File::Temp->newdir;
my $pager   = File::Spec->rel2abs('test-pager');
safe_mkdir( File::Spec->catdir($tempdir->dirname, 'subdir') );

PROJECT_ACKRC_PAGER_FORBIDDEN: {
    my @files = untaint( File::Spec->rel2abs('t/text/') );
    my @args = qw/ --env question(\\S+) /;

    safe_chdir( $tempdir->dirname );
    write_file '.ackrc', "--pager=$pager\n";

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args, @files);

    is_empty_array( $stdout );
    first_line_like( $stderr, qr/\QOptions --output, --pager and --match are forbidden in project .ackrc files/ );

    safe_chdir( $wd );
}

HOME_ACKRC_PAGER_PERMITTED: {
    my @files = untaint( File::Spec->rel2abs('t/text/') );
    my @args = qw/ --env question(\\S+) /;

    write_file(File::Spec->catfile($tempdir->dirname, '.ackrc'), "--pager=$pager\n");
    safe_chdir( File::Spec->catdir($tempdir->dirname, 'subdir') );
    local $ENV{'HOME'} = $tempdir->dirname;

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args, @files);

    is_nonempty_array( $stdout );
    is_empty_array( $stderr );

    safe_chdir( $wd );
}

ACKRC_ACKRC_PAGER_PERMITTED: {
    my @files = untaint( File::Spec->rel2abs('t/text/') );
    my @args = qw/ --env question(\\S+) /;

    write_file(File::Spec->catfile($tempdir->dirname, '.ackrc'), "--pager=$pager\n");
    safe_chdir( File::Spec->catdir($tempdir->dirname, 'subdir') );
    local $ENV{'ACKRC'} = File::Spec->catfile($tempdir->dirname, '.ackrc');

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args, @files);

    is_nonempty_array( $stdout );
    is_empty_array( $stderr );

    safe_chdir( $wd );
}

done_testing();
exit 0;
