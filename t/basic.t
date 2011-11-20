use strict;
use warnings;
use lib 't';

use Util;
use Test::More tests => 2;

my @expected = (
    't/swamp/groceries/fruit:1:apple',
    't/swamp/groceries/junk:1:apple fritters',
);

my @targets = map {
    "t/swamp/groceries/$_"
} qw/fruit junk meat/;

my @args    = ( qw( --ackrc=./ackrc --nocolor apple ), @targets );
my @results = run_ack( @args );

lists_match( \@results, \@expected );
