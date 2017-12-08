#!perl -T

use warnings;
use strict;

use Test::More tests => 5;

use lib 't';
use Util;

prep_environment();

NORMAL_CASE: {
    my @expected = ( '# The Cask of Amontillado, by Edgar Allen Poe' );

    my @args  = qw( -v x -h -m1 );
    my @files = qw( t/text/amontillado.txt );

    ack_lists_match( [ @args, @files ], \@expected, 'First line of a file that does not contain "x".' );
}

DASH_L: {
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

    my @args  = qw( free -i -v -l --sort-files );
    my @files = qw( t/text );

    ack_sets_match( [ @args, @files ], \@expected, 'No free' );

    ack_sets_match( [ '.*', '-l', '-v', 't/text' ], [], '-l -v with .* (which matches any line) should have no results' );
}

DASH_C: {
    my @expected = qw(
        t/text/amontillado.txt:206
        t/text/bill-of-rights.txt:45
        t/text/constitution.txt:259
        t/text/gettysburg.txt:15
        t/text/number.txt:1
        t/text/numbered-text.txt:20
        t/text/ozymandias.txt:9
        t/text/raven.txt:77
    );

    my @args  = qw( the -i -w -v -c --sort-files );
    my @files = qw( t/text );

    ack_sets_match( [ @args, @files ], \@expected, 'Non-the counts' );
}

done_testing();
