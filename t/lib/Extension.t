#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::Extension;

pass( 'App::Ack::Filter::Extension loaded with nothing else loaded first' );

done_testing();
