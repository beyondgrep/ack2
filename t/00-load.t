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
use Pod::Usage;
use File::Spec;

my @modules = qw(
    File::Next
    File::Spec
    Getopt::Long
    Pod::Usage
    Test::Harness
    Test::More
);

pass( 'All modules loaded' );

diag( "Testing ack version $App::Ack::VERSION under Perl $], $^X" );
for my $module ( @modules ) {
    no strict 'refs';
    my $ver = ${$module . '::VERSION'};
    diag( "Using $module $ver" );
}

done_testing();
