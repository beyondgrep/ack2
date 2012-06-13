#!perl

use warnings;
use strict;

use Test::More tests => 6;

use lib 't';
use Util;

prep_environment();

my @exp_types = qw{ rake ruby text };

sub get_types {
    my $line = shift;
    $line =~ s/.* => //;

    my @types = split( ',', $line );

    return \@types;
}

sub do_test {
    my @args = @_;
    my @results = run_ack( @args );

    is( scalar @results, 1, "Only one file should be returned from 'ack @args'" );
    sets_match( get_types( $results[0] ), \@exp_types , "'ack @args' must return all the expected types" );
}

DASH_F: {
    do_test( qw{ -f --show-types t/swamp/Rakefile } );
}

DASH_G: {
    do_test( qw{ -g Rakef --show-types t/swamp } );
}
