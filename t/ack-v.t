#!perl

use warnings;
use strict;

use Test::More tests => 6;
use File::Next ();

use lib 't';
use Util;

prep_environment();

NORMAL_CASE: {
    my @expected = ( 'Well, my daddy left home when I was three' );

    my @args  = qw( -v are -a -h -m1 );
    my @files = qw( t/text/boy-named-sue.txt );

    ack_lists_match( [ @args, @files ], \@expected, 'First line of a file that does not contain "are".' );
}

DASH_L: {
    my @expected = qw(
        t/text/4th-of-july.txt
        t/text/boy-named-sue.txt
        t/text/freedom-of-choice.txt
        t/text/me-and-bobbie-mcgee.txt
        t/text/shut-up-be-happy.txt
    );

    my @args  = qw( religion -i -a -v -l );
    my @files = qw( t/text );

    ack_sets_match( [ @args, @files ], \@expected, 'No religion please' );
}

DASH_C: {
    my @expected = qw(
        t/text/4th-of-july.txt:37
        t/text/boy-named-sue.txt:72
        t/text/freedom-of-choice.txt:50
        t/text/me-and-bobbie-mcgee.txt:32
        t/text/science-of-myth.txt:24
        t/text/shut-up-be-happy.txt:26
    );

    my @args  = qw( religion -i -a -v -c );
    my @files = qw( t/text );

    ack_sets_match( [ @args, @files ], \@expected, 'Non-religion counts' );
}

done_testing();
