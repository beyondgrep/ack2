#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use App::Ack::Filter::ExtensionGroup;

pass( 'App::Ack::Filter::ExtensionGroup loaded with nothing else loaded first' );

done_testing();
