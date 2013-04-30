#!perl

use warnings;
use strict;

use Test::More;

use lib 't';
use Util;

prep_environment();

# test for behavior with illegal regexes
my @tests = (
    [ 'illegal pattern',  '?foo', 't/' ],
    [ 'illegal -g regex', '-g', '?foo', 't/' ],
);

plan tests => @tests * 4;

for ( @tests ) {
    test_ack_with( @{$_} );
}

sub test_ack_with {
    my $testcase = shift;

    my ( $stdout, $stderr ) = run_ack_with_stderr( @_ );

    is( scalar @{$stdout}, 0, "No STDOUT for $testcase" );
    is( scalar @{$stderr}, 2, "Two lines of STDERR for $testcase" );
    like( $stderr->[0], qr/Invalid regex/, "Correct ack error message for $testcase" );
    like( $stderr->[1], qr/^\s+Quantifier follows nothing/, "Correct type of error for $testcase" );

    return;
}
