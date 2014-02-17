#!perl -T

use warnings;
use strict;

use Test::More tests => 12;
use File::Next ();
use File::Spec ();
use File::Temp ();

use lib 't';
use Util;

prep_environment();

NO_O: {
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( the\\s+\\S+ );
    my @expected = split( /\n/, <<'EOF' );
        But the meanest thing that he ever did
        But I made me a vow to the moon and stars
        That I'd search the honky-tonks and bars
        Sat the dirty, mangy dog that named me Sue.
        Well, I hit him hard right between the eyes
        And we crashed through the wall and into the street
        Kicking and a-gouging in the mud and the blood and the beer.
        And it's the name that helped to make you strong."
        And I know you hate me, and you got the right
        For the gravel in ya gut and the spit in ya eye
        Cause I'm the son-of-a-bitch that named you Sue."
EOF
    s/^\s+// for @expected;

    ack_lists_match( [ @args, @files ], \@expected, 'Find all the things without -o' );
}


WITH_O: {
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( the\\s+\\S+ -o );
    my @expected = split( /\n/, <<'EOF' );
        the meanest
        the moon
        the honky-tonks
        the dirty,
        the eyes
        the wall
        the street
        the mud
        the blood
        the beer.
        the name
        the right
        the gravel
        the spit
        the son-of-a-bitch
EOF
    s/^\s+// for @expected;

    ack_lists_match( [ @args, @files ], \@expected, 'Find all the things with -o' );
}


# Give an output function and find match in multiple files (so print filenames, just like grep -o).
WITH_OUTPUT: {
    my @files = qw( t/text/ );
    my @args = qw/ --output=x$1x question(\\S+) /;

    my @target_file = (
        File::Next::reslash( 't/text/science-of-myth.txt' ),
        File::Next::reslash( 't/text/shut-up-be-happy.txt' ),
    );
    my @expected = (
        "$target_file[0]:1:xedx",
        "$target_file[1]:15:xs.x",
        "$target_file[1]:21:x.x",
    );

    ack_sets_match( [ @args, @files ], \@expected, 'Find all the things with --output function' );
}

OUTPUT_DOUBLE_QUOTES: {
    my @files = qw( t/text/ );
    my @args  = ( '--output="$1"', 'question(\\S+)' );

    my @target_file = (
        File::Next::reslash( 't/text/science-of-myth.txt' ),
        File::Next::reslash( 't/text/shut-up-be-happy.txt' ),
    );
    my @expected = (
        qq{$target_file[0]:1:"ed"},
        qq{$target_file[1]:15:"s."},
        qq{$target_file[1]:21:"."},
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
    my @args = qw/ --env question(\\S+) /;

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
    my @args = qw/ --env question(\\S+) /;

    write_file(File::Spec->catfile($tempdir->dirname, '.ackrc'), "--output=foo\n");
    chdir File::Spec->catdir($tempdir->dirname, 'subdir');
    local $ENV{'ACKRC'} = File::Spec->catfile($tempdir->dirname, '.ackrc');

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args, @files);

    is_nonempty_array( $stdout );
    is_empty_array( $stderr );

    chdir $wd;
}

done_testing();
