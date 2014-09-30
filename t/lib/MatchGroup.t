#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::MatchGroup;

pass( 'App::Ack::Filter::MatchGroup loaded with nothing else loaded first' );

done_testing();
