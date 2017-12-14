#!perl -T

use warnings;
use strict;

use Test::More tests => 5;

use lib 't';
use Util;

prep_environment();

# Check that a match on the last line of a file without a proper
# ending newline gets this newline appended by ack.


VERIFY_LAST_LINE_IS_MISSING_NEWLINE: {
    # Verify that our test data file is set up the way we expect and that it hasn't had a newline
    # added to the end of the file by mistake.
    open( my $fh, '<', 't/swamp/incomplete-last-line.txt' ) or die $!;
    my @lines = <$fh>;
    close $fh;
    is( substr( $lines[0], -1, 1 ), "\n", 'First line ends with a newline' );
    is( substr( $lines[1], -1, 1 ), "\n", 'Second line ends with a newline' );
    is( substr( $lines[2], -1, 1 ), '!', 'Third line ends with a bang, not a newline' );
}


INCOMPLETE_LAST_LINE: {
    my @expected = line_split( <<"HERE" );
but no new line on the last line!
the last full measure of devotion -- that we here highly resolve that
HERE

    my @args  = qw( -h --nogroup last );
    my @files = qw( t/swamp/incomplete-last-line.txt t/text/gettysburg.txt );

    ack_lists_match( [ @args, @files ], \@expected, 'Incomplete line gets a newline appended.' );
}

done_testing();
