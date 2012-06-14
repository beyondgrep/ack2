#!perl

use strict;
use warnings;

use lib 't';
use Util;

use Test::More tests => 3;

use App::Ack::ConfigDefault;

prep_environment();

DUMP: {
    my @expected = split( /\n/, App::Ack::ConfigDefault::_options_block );
    @expected = grep { /./ && !/^#/ } @expected;

    my @args    = qw( --dump );
    my @results = run_ack( @args );

    is( $results[0], 'Defaults', 'header should be Defaults' );
    splice @results, 0, 2; # remove header (2 lines)

    foreach my $result ( @results ) {
        $result =~ s/^\s*//;
    }

    sets_match( \@results, \@expected );
}
