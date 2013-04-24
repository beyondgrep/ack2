#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::FirstLineMatch;

pass( 'App::Ack::Filter::FirstLineMatch loaded with nothing else loaded first' );

done_testing();
