#!perl

use warnings;
use strict;

use Test::More skip_all => 'for now';

use lib 't';
use Util;

prep_environment();

DASH_L: {
    my @expected = qw(
        t/text/science-of-myth.txt
    );

    my @files = qw( t/text );
    my @args = qw( religion -i -a -l );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, 'Looking for religion with -l' );
}

DASH_CAPITAL_L: {
    my @expected = qw(
        t/text/4th-of-july.txt
        t/text/boy-named-sue.txt
        t/text/me-and-bobbie-mcgee.txt
        t/text/freedom-of-choice.txt
        t/text/shut-up-be-happy.txt
    );

    # -L and -l -v are identical
    for my $switches ( (['-L'], ['-l','-v']) ) {
        my @files = qw( t/text );
        my @args = ( 'religion', '-a', @{$switches} );
        my @results = run_ack( @args, @files );

        sets_match( \@results, \@expected, "Looking for religion with @{$switches}" );
    }
}

DASH_C: {
    my @expected = qw(
        t/text/4th-of-july.txt:1
        t/text/boy-named-sue.txt:2
        t/text/freedom-of-choice.txt:0
        t/text/me-and-bobbie-mcgee.txt:0
        t/text/science-of-myth.txt:0
        t/text/shut-up-be-happy.txt:0
    );

    my @files = qw( t/text );
    my @args = qw( boy -i -a -c );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, 'Boy counts' );
}

DASH_LC: {
    my @expected = qw(
        t/text/science-of-myth.txt:2
    );

    my @files = qw( t/text );
    my @args = qw( religion -i -a -l -c );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, 'Religion counts -l -c' );
}

PIPE_INTO_C: {
    my $file = 't/text/science-of-myth.txt';
    my @args = qw( religion -i -c );
    my @results = pipe_into_ack( $file, @args );

    is( scalar @results, 1, 'Piping into ack --count should return one line of results' );
    is( $results[0], '2', 'Piping into ack --count should return "<count>"' );
}
