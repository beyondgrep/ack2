#!perl -T

use strict;
use warnings;

use Test::More tests => 10;
use lib 't';
use Util;

my $expected_norecurse = <<'END';
t/swamp/groceries/fruit:1:apple
t/swamp/groceries/junk:1:apple fritters
END

my $expected_recurse = <<'END';
t/swamp/groceries/another_subdir/fruit:1:apple
t/swamp/groceries/another_subdir/junk:1:apple fritters
t/swamp/groceries/fruit:1:apple
t/swamp/groceries/junk:1:apple fritters
t/swamp/groceries/subdir/fruit:1:apple
t/swamp/groceries/subdir/junk:1:apple fritters
END

chomp $expected_norecurse;
chomp $expected_recurse;

if ( is_windows() ) {
    $expected_norecurse =~ s{/}{\\}g;
    $expected_recurse =~ s{/}{\\}g;
}

my @args;
my $lines;

prep_environment();

# We sort to ensure determinstic results.
@args  = ('-n', '--sort-files', 'apple', 't/swamp/groceries');
$lines = run_ack(@args);
is_deeply $lines, $expected_norecurse;

@args  = ('--no-recurse', '--sort-files', 'apple', 't/swamp/groceries');
$lines = run_ack(@args);
is_deeply $lines, $expected_norecurse;

# Make sure that re-enabling recursion works.
@args  = ('-n', '-r', '--sort-files', 'apple', 't/swamp/groceries');
$lines = run_ack(@args);
is_deeply $lines, $expected_recurse;

@args  = ('--no-recurse', '-R', '--sort-files', 'apple', 't/swamp/groceries');
$lines = run_ack(@args);
is_deeply $lines, $expected_recurse;

@args  = ('--no-recurse', '--recurse', '--sort-files', 'apple', 't/swamp/groceries');
$lines = run_ack(@args);
is_deeply $lines, $expected_recurse;
