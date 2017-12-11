#!perl -T

use warnings;
use strict;

use Test::More tests => 11;
use File::Spec ();
use File::Temp ();

use lib 't';
use Util;

prep_environment();

NO_O: {
    my @files = qw( t/text/gettysburg.txt );
    my @args = qw( the\\s+\\S+ );
    my @expected = line_split( <<'EOF' );
        but it can never forget what they did here. It is for us the living,
        rather, to be dedicated here to the unfinished work which they who
        here dedicated to the great task remaining before us -- that from these
        the last full measure of devotion -- that we here highly resolve that
        shall have a new birth of freedom -- and that government of the people,
        by the people, for the people, shall not perish from the earth.
EOF
    s/^\s+// for @expected;

    ack_lists_match( [ @args, @files ], \@expected, 'Find all the things without -o' );
}


WITH_O: {
    my @files = qw( t/text/gettysburg.txt );
    my @args = qw( the\\s+\\S+ -o );
    my @expected = line_split( <<'EOF' );
        the living,
        the unfinished
        the great
        the last
        the people,
        the people,
        the people,
        the earth.
EOF
    s/^\s+// for @expected;

    ack_lists_match( [ @args, @files ], \@expected, 'Find all the things with -o' );
}


# Find a match in multiple files, and output it in double quotes.
OUTPUT_DOUBLE_QUOTES: {
    my @files = qw( t/text/ );
    my @args  = ( '--output="$1"', '(free\\w*)', '--sort-files' );

    my @target_file = map { reslash($_) } qw(
        t/text/bill-of-rights.txt
        t/text/constitution.txt
        t/text/gettysburg.txt
    );
    my @expected = (
        qq{$target_file[0]:4:"free"},
        qq{$target_file[0]:4:"freedom"},
        qq{$target_file[0]:10:"free"},
        qq{$target_file[1]:32:"free"},
        qq{$target_file[2]:23:"freedom"},
    );

    ack_sets_match( [ @args, @files ], \@expected, 'Find all the things with --output function' );
}

my $wd      = getcwd_clean();
my $tempdir = File::Temp->newdir;
mkdir File::Spec->catdir($tempdir->dirname, 'subdir');

PROJECT_ACKRC_OUTPUT_FORBIDDEN: {
    my @files = untaint( File::Spec->rel2abs('t/text/') );
    my @args = qw/ --env question(\\S+) /;

    chdir $tempdir->dirname;
    write_file '.ackrc', "--output=foo\n";

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args, @files);

    is_empty_array( $stdout );
    first_line_like( $stderr, qr/\QOptions --output, --pager and --match are forbidden in project .ackrc files/ );

    chdir $wd;
}

HOME_ACKRC_OUTPUT_PERMITTED: {
    my @files = untaint( File::Spec->rel2abs('t/text/') );
    my @args = qw/ --env question(\\S+) --sort-files /;

    write_file(File::Spec->catfile($tempdir->dirname, '.ackrc'), "--output=foo\n");
    chdir File::Spec->catdir($tempdir->dirname, 'subdir');
    local $ENV{'HOME'} = $tempdir->dirname;

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args, @files);

    is_nonempty_array( $stdout );
    is_empty_array( $stderr );

    chdir $wd;
}

ACKRC_ACKRC_OUTPUT_PERMITTED: {
    my @files = untaint( File::Spec->rel2abs('t/text/') );
    my @args = qw/ --env question(\\S+) --sort-files /;

    write_file(File::Spec->catfile($tempdir->dirname, '.ackrc'), "--output=foo\n");
    chdir File::Spec->catdir($tempdir->dirname, 'subdir');
    local $ENV{'ACKRC'} = File::Spec->catfile($tempdir->dirname, '.ackrc');

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args, @files);

    is_nonempty_array( $stdout );
    is_empty_array( $stderr );

    chdir $wd;
}

done_testing();
