#!/usr/bin/env perl

# https://github.com/petdance/ack2/issues/276

use strict;
use warnings;

use lib 't';
use Util;
use Test::More;

my @regexes = (
    '((foo)bar)',
    '((foo)(bar))',
);

plan tests => scalar @regexes;

prep_environment();

my $match_start = "\e[30;43m";
my $match_end   = "\e[0m";

for my $regex ( @regexes ) {
    subtest $regex => sub {
        my ( $stdout, $stderr ) = pipe_into_ack_with_stderr( \'foobar', '--color', $regex );

        is( scalar(@{$stdout}), 1, 'Verify that exactly one line is printed to standard output' );
        is_empty_array( $stderr, 'Verify that no lines are printed to standard error' );
        is( $stdout->[0], "${match_start}foobar${match_end}", 'Verify that the single match is properly colored' );
    };
}
