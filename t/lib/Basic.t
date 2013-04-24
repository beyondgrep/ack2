#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Resource::Basic;

pass( 'App::Ack::Resource::Basic loaded with nothing else loaded first' );

done_testing();
