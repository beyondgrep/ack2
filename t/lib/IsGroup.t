#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::IsGroup;

pass( 'App::Ack::Filter::IsGroup loaded with nothing else loaded first' );

done_testing();
