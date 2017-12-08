#!perl -T

use warnings;
use strict;

use Test::More tests => 12;

use lib 't';
use Util;

prep_environment();

DASH_L: {
    my @expected = qw(
        t/text/amontillado.txt
        t/text/gettysburg.txt
        t/text/raven.txt
    );

    my @args  = qw( God -i -l --sort-files );
    my @files = qw( t/text );

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for God with -l' );
}

DASH_CAPITAL_L: {
    my @expected = qw(
        t/text/bill-of-rights.txt
        t/text/constitution.txt
        t/text/number.txt
        t/text/numbered-text.txt
        t/text/ozymandias.txt
    );

    my @switches = (
        ['-L'],
        ['--files-without-matches'],
    );

    for my $switches ( @switches ) {
        my @files = qw( t/text );
        my @args  = ( 'God', @{$switches}, '--sort-files' );

        ack_sets_match( [ @args, @files ], \@expected, "Looking for God with @{$switches}" );
    }
}

DASH_LV: {
    my @expected = qw(
        t/text/amontillado.txt
        t/text/bill-of-rights.txt
        t/text/constitution.txt
        t/text/gettysburg.txt
        t/text/number.txt
        t/text/numbered-text.txt
        t/text/ozymandias.txt
        t/text/raven.txt
    );
    my @switches = (
        ['-l','-v'],
        ['-l','--invert-match'],
        ['--files-with-matches','-v'],
        ['--files-with-matches','--invert-match'],
    );

    for my $switches ( @switches ) {
        my @files = qw( t/text );
        my @args  = ( 'religion', @{$switches}, '--sort-files' );

        ack_sets_match( [ @args, @files ], \@expected, '-l -v will match all input files because "religion" will not be on every line' );
    }
}

DASH_C: {
    my @expected = qw(
        t/text/amontillado.txt:2
        t/text/bill-of-rights.txt:0
        t/text/constitution.txt:0
        t/text/gettysburg.txt:1
        t/text/number.txt:0
        t/text/numbered-text.txt:0
        t/text/ozymandias.txt:0
        t/text/raven.txt:2
    );

    my @args  = qw( God -c --sort-files );
    my @files = qw( t/text );

    ack_sets_match( [ @args, @files ], \@expected, 'God counts' );
}

DASH_LC: {
    my @expected = qw(
        t/text/bill-of-rights.txt:1
        t/text/constitution.txt:29
    );

    my @args  = qw( congress -i -l -c --sort-files );
    my @files = qw( t/text );

    ack_sets_match( [ @args, @files ], \@expected, 'congress counts with -l -c' );
}

PIPE_INTO_C: {
    my $file = 't/text/raven.txt';
    my @args = qw( nevermore -i -c );
    my @results = pipe_into_ack( $file, @args );

    is_deeply( \@results, [ 11 ], 'Piping into ack --count should return one line of results' );
}

DASH_HC: {
    my @args     = qw( Montresor -c -h );
    my @files    = qw( t/text );
    my @expected = ( '3' );

    ack_sets_match( [ @args, @files ], \@expected, 'ack -c -h should return one line of results' );
}

SINGLE_FILE_COUNT: {
    my @args     = qw( Montresor -c -h );
    my @files    = ( 't/text/amontillado.txt' );
    my @expected = ( '3' );

    ack_sets_match( [ @args, @files ], \@expected, 'ack -c -h should return one line of results' );
}

done_testing();
