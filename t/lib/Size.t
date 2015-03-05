#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::Size;

pass( 'App::Ack::Filter::Size loaded with nothing else loaded first' );

done_testing();
