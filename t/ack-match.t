#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use lib 't';
use Util;

prep_environment();

my @files = qw( t/text );

my @tests = (
    [ qw/Sue -a/ ],
    [ qw/boy -a -i/ ], # case-insensitive is handled correctly with --match
    [ qw/ll+ -a -Q/ ], # quotemeta        is handled correctly with --match
    [ qw/gon -a -w/ ], # words            is handled correctly with --match
);

# 3 tests for each call to test_match()
# and 4 other test
#plan tests => @tests * 3 + 4;

test_match( @{$_} ) for @tests;

# giving only the --match argument (and no other args) should not
# result in an error
run_ack( '--match', 'Sue' );

# not giving a regex when piping into ack should result in an error
my ($stdout, $stderr) = pipe_into_ack_with_stderr( 't/text/4th-of-july.txt', '--perl' );
ok( get_rc() != 0, 'ack should return an error when piped into without a regex' );
is( scalar @{$stdout}, 0, 'ack should return no STDOUT when piped into without a regex' );
is( scalar @{$stderr}, 1, 'ack should return one line of error message when piped into without a regex' ) or diag(explain($stderr));

done_testing;

# call ack normally and compare output to calling with --match regex
#
# due to 2 calls to run_ack, this sub runs altogether 3 tests
sub test_match {
    my $regex = shift;
    my @args = @_;

    my @results_normal = run_ack( @args, $regex, @files );
    my @results_match  = run_ack( @args, @files, '--match', $regex );

    return sets_match( \@results_normal, \@results_match, "Same output for regex '$regex'." );
}
