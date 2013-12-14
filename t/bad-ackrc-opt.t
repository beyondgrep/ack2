#!perl -T

use strict;
use warnings;
use lib 't';

use Util;
use Test::More tests => 4;

prep_environment();

my ( $stdout, $stderr ) = run_ack_with_stderr( '--noenv', '--ackrc=./bad-ackrc', 'the', 't/text' );

is_empty_array( $stdout, 'Nothing to stdout' );
is( @{$stderr}, 1, 'only one line to stderr' );
like( $stderr->[0], qr/Unable to load ackrc/, 'Got the right message' );
isnt( get_rc(), 0, 'Non-zero return code' );
