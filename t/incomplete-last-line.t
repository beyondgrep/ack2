#!perl -T

use warnings;
use strict;

use Test::More tests => 2;

use lib 't';
use Util;

prep_environment();

# Check that a match on the last line of a file without a proper
# ending newline gets this newline appended by ack.
INCOMPLETE_LAST_LINE: {
    my @expected = split( /\n/, <<"EOF" );
but no new line on the last line!
At last everything is done for you.
EOF

    my @args  = qw( -h --nogroup last );
    my @files = qw( t/swamp/incomplete-last-line.txt t/text/shut-up-be-happy.txt );

    ack_lists_match( [ @args, @files ], \@expected, 'Incomplete line gets a newline appended.' );
}

done_testing();
