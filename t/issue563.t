
#!perl -T

# https://github.com/petdance/ack2/issues/563

use strict;
use warnings;
use lib 't';

use Test::More tests => 4;
use Util;

prep_environment();

my @result = pipe_into_ack(\'aa', '-c', 'a');
is( $result[0], 1, 'Only one match counts per line' );

@result = pipe_into_ack(\'abcdgh', '-c', 'ab(c(d|e)|ef)gh');
is( $result[0], 1, 'Nested groups with alternation in pattern match only once per line' );

@result = pipe_into_ack(\'abcdgh', '-c', 'abc(((d)))gh');
is( $result[0], 1, 'Nested groups in pattern match only once per line' );

@result = pipe_into_ack(\'abcdgh', '-c', 'abc(d)(g)h');
is( $result[0], 1, 'Many groups in pattern match only once per line' );
