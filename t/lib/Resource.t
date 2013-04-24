#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Resource;

pass( 'App::Ack::Resource loaded with nothing else loaded first' );

done_testing();
