#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More tests => 3;
use Util;

prep_environment();

DUMP: {
    my $fh;
    open $fh, '<', './ackrc' or die $!;
    my @lines = map { chomp; $_ } <$fh>;
    close $fh;
    my @expected = grep {
        /\S/ && !/^\s*#/
    } @lines;

    my @args    = qw( --ackrc=./ackrc --dump );
    my @results = run_ack( @args );

    is( $results[0], './ackrc', 'header should be name of ackrc' );
    splice @results, 0, 2; # remove header (2 lines)

    foreach my $result ( @results ) {
        $result =~ s/^\s*//;
    }

    sets_match( \@results, \@expected );
}
