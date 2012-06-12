#!perl -T

use warnings;
use strict;
use Test::More tests => 1;

use App::Ack;
use App::Ack::Resource;
use App::Ack::ConfigDefault;
use App::Ack::ConfigFinder;
use App::Ack::ConfigLoader;
use File::Next;
use Test::Harness;

pass( 'All modules loaded' );

diag( "Testing App::Ack $App::Ack::VERSION, File::Next $File::Next::VERSION, Perl $], $^X" );
diag( "Using Test::More $Test::More::VERSION and Test::Harness $Test::Harness::VERSION" );

done_testing();
