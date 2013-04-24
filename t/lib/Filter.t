#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter;

pass( 'App::Ack::Filter loaded with nothing else loaded first' );

done_testing();
