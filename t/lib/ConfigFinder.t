#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::ConfigFinder;

pass( 'App::Ack::ConfigFinder loaded with nothing else loaded first' );

done_testing();
