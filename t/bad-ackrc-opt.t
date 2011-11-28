use strict;
use warnings;
use lib 't';

use Util;
use Test::More tests => 4;

my ( $stdout, $stderr ) = run_ack_with_stderr( '--noenv', '--ackrc=./bad-ackrc', 'the', 't/text' );

is @{$stdout}, 0;
is @{$stderr}, 1;
like $stderr->[0], qr/Unable to load ackrc/;
isnt get_rc(), 0;
