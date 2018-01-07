#!perl -T

use warnings;
use strict;

use Test::More tests => 2;

use lib 't';
use Util;

prep_environment();

# The "bongo" match is after the 100,000-byte cutoff.
NEEDS_LINE_SCAN: {
    my @expected = line_split( <<'HERE' );
my $bongo = 'yada yada';
HERE

    my @files = qw( t/swamp );
    my @args = qw( bongo -w -h );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for Lenore!' );
}

done_testing();
exit 0;
