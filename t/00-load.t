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
use Getopt::Long;

pass( 'All modules loaded' );

diag( "Testing ack version $App::Ack::VERSION under Perl $], $^X" );
for my $module ( qw( File::Next Getopt::Long Test::More Test::Harness ) ) {
    no strict 'refs';
    my $ver = ${$module . '::VERSION'};
    diag( "Using $module $ver" );
}

done_testing();
