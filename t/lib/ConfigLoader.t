#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::ConfigLoader;

pass( 'App::Ack::ConfigLoader loaded with nothing else loaded first' );

done_testing();
