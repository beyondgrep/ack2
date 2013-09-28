#!perl

# Make sure we have a .t file each *.pm

use warnings;
use strict;

use Test::More;

use lib 't';
use Util;

my @pms = glob( '*.pm' );

plan tests => scalar @pms;

for my $pm ( @pms ) {
    my $t = $pm;
    $t =~ s/\.pm$/.t/;
    ok( -r "t/lib/$t", "$pm has a corresponding $t" );
}

done_testing();
