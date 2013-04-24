#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::Default;

pass( 'App::Ack::Filter::Default loaded with nothing else loaded first' );

done_testing();
