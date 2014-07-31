#!perl -T

# Make sure we have a .t file each *.pm.  This prevents a forgetful
# developer from creating a .pm without making the test, too.

# If you've made this test fail, it's because you need a t/lib/*.t
# file to test your new module.

use warnings;
use strict;

use Test::More;

my @pms = glob( '*.pm' );

@pms = grep { !/Debug.pm/ } @pms;

plan tests => scalar @pms;

for my $pm ( @pms ) {
    my $t = $pm;
    $t =~ s/\.pm$/.t/;
    ok( -r "t/lib/$t", "$pm has a corresponding $t" );
}

done_testing();
