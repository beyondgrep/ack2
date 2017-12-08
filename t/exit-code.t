#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More tests => 4;
use Util;

prep_environment();

run_ack( 'legislative', 't/text/constitution.txt' );
is( get_rc(), 0, 'Exit code with matches should be 0' );

run_ack( 'foo', 't/text/constitution.txt' );
is( get_rc(), 1, 'Exit code with no matches should be 1' );
