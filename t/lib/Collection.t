#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::Collection;

pass( 'App::Ack::Filter::Collection loaded with nothing else loaded first' );

done_testing();
