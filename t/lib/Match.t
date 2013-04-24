#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::Match;

pass( 'App::Ack::Filter::Match loaded with nothing else loaded first' );

done_testing();
