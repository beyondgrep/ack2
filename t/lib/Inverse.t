#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::Inverse;

pass( 'App::Ack::Filter::Inverse loaded with nothing else loaded first' );

done_testing();
