use strict;
use warnings;
use lib 't';

use Util;
use Test::More tests => 4;

my @expected = (
    't/swamp/groceries/fruit:2:pear',
    't/swamp/groceries/fruit:3:grapes',
    't/swamp/groceries/junk:2:grape jam',
    't/swamp/groceries/junk:3:fried pork rinds',
    't/swamp/groceries/meat:1:pork',
    't/swamp/groceries/meat:2:beef',
    't/swamp/groceries/meat:3:chicken',
);

my @targets = map {
    "t/swamp/groceries/$_"
} qw/fruit junk meat/;

my @args    = ( qw( --ackrc=./ackrc --nocolor apple -v ), @targets );
my @results = run_ack( @args );

lists_match( \@results, \@expected );

@args    = ( qw( --ackrc=./ackrc --nocolor apple --invert-match ), @targets );
@results = run_ack( @args );

lists_match( \@results, \@expected );
