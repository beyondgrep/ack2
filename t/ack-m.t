#!perl -T

use strict;
use warnings;

use Test::More tests => 6;

use lib 't';
use Util;

prep_environment();

LIMIT_MATCHES_RETURNED: {
    my @text = sort map { untaint($_) } glob( 't/text/[bc]*.txt' );

    my $bill_ = reslash( 't/text/bill-of-rights.txt' );
    my $const = reslash( 't/text/constitution.txt' );

    my @expected = line_split( <<"EOF" );
$bill_:4:or prohibiting the free exercise thereof; or abridging the freedom of
$bill_:5:speech, or of the press; or the right of the people peaceably to assemble,
$bill_:6:and to petition the Government for a redress of grievances.
$const:3:We the People of the United States, in Order to form a more perfect
$const:4:Union, establish Justice, insure domestic Tranquility, provide for the
$const:5:common defense, promote the general Welfare, and secure the Blessings
EOF

    ack_lists_match( [ '-m', 3, '-w', 'the', @text ], \@expected, 'Should show only 3 lines per file' );

    @expected = line_split( <<"EOF" );
$bill_:4:or prohibiting the free exercise thereof; or abridging the freedom of
EOF

ack_lists_match( [ '-1', '-w', 'the', @text ], \@expected, 'We should only get one line back for the entire run, not just per file.' );
}


DASH_L: {
    my $target   = 'the';
    my @files    = reslash( 't/text' );
    my @args     = ( '-m', 3, '-l', '--sort-files', $target );
    my @results  = run_ack( @args, @files );
    my @expected = map { reslash( "t/text/$_" ) } (
        'amontillado.txt', 'bill-of-rights.txt', 'constitution.txt'
    );

    is_deeply(\@results, \@expected);
}
