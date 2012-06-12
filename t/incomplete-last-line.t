#!perl

use warnings;
use strict;

use Test::More tests => 2;

use lib 't';
use Util;

prep_environment();

# check that a match on the last line of a file without a proper
# ending newline gets this newline append by ack
INCOMPLETE_LAST_LINE: {
    my @expected = split( /\n/, <<"EOF" );
but no new line on the last line!
At last everything is done for you.
EOF

    my @args  = qw( -a -h --nogroup last );
    my @files = qw( t/swamp/incomplete-last-line.txt t/text/shut-up-be-happy.txt );

    ack_lists_match( [ @args, @files ], \@expected, 'Incomplete line gets a newline appended.' );
}

done_testing();
