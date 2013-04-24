#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::Is;

pass( 'App::Ack::Filter::Is loaded with nothing else loaded first' );

done_testing();
