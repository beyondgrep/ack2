use strict;
use warnings;
use lib 't';

use Util;
use Test::More tests => 4;

my @expected = (
    't/swamp/groceries/meat',
);

my @targets = map {
    "t/swamp/groceries/$_"
} qw/fruit junk meat/;

my @args    = ( qw( --ackrc=./ackrc --nocolor apple -L ), @targets );
my @results = run_ack( @args );

lists_match( \@results, \@expected );

@args    = ( qw( --ackrc=./ackrc --nocolor apple --files-without-matches ), @targets );
@results = run_ack( @args );

lists_match( \@results, \@expected );
