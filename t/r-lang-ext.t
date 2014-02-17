#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More tests => 2;
use Util;

prep_environment();

my @expected = qw(
    t/swamp/example.R
);

my @args    = qw( --rr -f );
my @results = run_ack( @args );

sets_match( \@results, \@expected, __FILE__ );
