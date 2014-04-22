#!perl -T

use warnings;
use strict;

use Test::More tests => 12;

use lib 't';
use Util;

prep_environment();

DASH_L: {
    my @expected = qw(
        t/text/science-of-myth.txt
    );

    my @args  = qw( religion -i -l );
    my @files = qw( t/text );

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for religion with -l' );
}

DASH_CAPITAL_L: {
    my @expected = qw(
        t/text/4th-of-july.txt
        t/text/boy-named-sue.txt
        t/text/me-and-bobbie-mcgee.txt
        t/text/number.txt
        t/text/numbered-text.txt
        t/text/freedom-of-choice.txt
        t/text/shut-up-be-happy.txt
    );

    my @switches = (
        ['-L'],
        ['--files-without-matches'],
    );

    for my $switches ( @switches ) {
        my @files = qw( t/text );
        my @args  = ( 'religion', @{$switches} );

        ack_sets_match( [ @args, @files ], \@expected, "Looking for religion with @{$switches}" );
    }
}

DASH_LV: {
    my @expected = qw(
        t/text/4th-of-july.txt
        t/text/boy-named-sue.txt
        t/text/me-and-bobbie-mcgee.txt
        t/text/number.txt
        t/text/numbered-text.txt
        t/text/freedom-of-choice.txt
        t/text/science-of-myth.txt
        t/text/shut-up-be-happy.txt
    );
    my @switches = (
        ['-l','-v'],
        ['-l','--invert-match'],
        ['--files-with-matches','-v'],
        ['--files-with-matches','--invert-match'],
    );

    for my $switches ( @switches ) {
        my @files = qw( t/text );
        my @args  = ( 'religion', @{$switches} );

        ack_sets_match( [ @args, @files ], \@expected, '-l -v will mostly likely match all input files' );
    }
}

DASH_C: {
    my @expected = qw(
        t/text/4th-of-july.txt:1
        t/text/boy-named-sue.txt:2
        t/text/freedom-of-choice.txt:0
        t/text/me-and-bobbie-mcgee.txt:0
        t/text/number.txt:0
        t/text/numbered-text.txt:0
        t/text/science-of-myth.txt:0
        t/text/shut-up-be-happy.txt:0
    );

    my @args  = qw( boy -i -c );
    my @files = qw( t/text );

    ack_sets_match( [ @args, @files ], \@expected, 'Boy counts' );
}

DASH_LC: {
    my @expected = qw(
        t/text/science-of-myth.txt:2
    );

    my @args  = qw( religion -i -l -c );
    my @files = qw( t/text );

    ack_sets_match( [ @args, @files ], \@expected, 'Religion counts -l -c' );
}

PIPE_INTO_C: {
    my $file = 't/text/science-of-myth.txt';
    my @args = qw( religion -i -c );
    my @results = pipe_into_ack( $file, @args );

    is_deeply( \@results, [2], 'Piping into ack --count should return one line of results' );
}

DASH_HC: {
    my @args     = qw( boy -i -c -h );
    my @files    = qw( t/text );
    my @expected = ( '3' );

    ack_sets_match( [ @args, @files ], \@expected, 'ack -c -h should return one line of results' );
}

SINGLE_FILE_COUNT: {
    my @args     = qw( boy -i -c -h );
    my @files    = ( 't/text/boy-named-sue.txt' );
    my @expected = ( '2' );

    ack_sets_match( [ @args, @files ], \@expected, 'ack -c -h should return one line of results' );
}

done_testing();
