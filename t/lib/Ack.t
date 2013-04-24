#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack;

pass( 'App::Ack loaded with nothing else loaded first' );

done_testing();
