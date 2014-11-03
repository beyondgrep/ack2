#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::IsPathGroup;

pass( 'App::Ack::Filter::IsPathGroup loaded with nothing else loaded first' );

done_testing();
