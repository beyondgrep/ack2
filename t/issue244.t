#!perl

# https://github.com/petdance/ack2/issues/244

use strict;
use warnings;
use Test::More;

use lib 't';
use Util;

plan tests => 1;

prep_environment();

my ( $stdout, $stderr ) = run_ack_with_stderr('--color', '(foo)|(bar)', 't/swamp');
is_empty_array( $stderr );
