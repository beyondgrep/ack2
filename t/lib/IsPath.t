#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::IsPath;

pass( 'App::Ack::Filter::IsPath loaded with nothing else loaded first' );

done_testing();
