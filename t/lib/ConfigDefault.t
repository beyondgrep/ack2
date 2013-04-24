#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::ConfigDefault;

pass( 'App::Ack::ConfigDefault loaded with nothing else loaded first' );

done_testing();
