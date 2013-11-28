#!perl

use strict;
use warnings;

use lib 't';
use Util;

use Test::More tests => 5;

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

    sets_match( \@results, \@expected, __FILE__ );

    my @perl = grep { /\bperl\b/ } @results;
    is( scalar @perl, 2, 'Two specs for Perl' );

    my @ignore_dir = grep { /ignore-dir/ } @results;
    is( scalar @ignore_dir, 23, 'Twenty-three specs for ignoring directories' );
}
