#!perl -T

use strict;
use warnings;
use lib 't';

use Util;
use Test::More tests => 4;

prep_environment();

my @expected = (
    't/swamp/groceries/fruit:1:apple',
    't/swamp/groceries/junk:1:apple fritters',
);

my @targets = map {
    "t/swamp/groceries/$_"
} qw/fruit junk meat/;

my @args    = ( qw( --nocolor APPLE -i ), @targets );
my @results = run_ack( @args );

lists_match( \@results, \@expected, '-i flag' );

@args    = ( qw( --nocolor APPLE --ignore-case ), @targets );
@results = run_ack( @args );

lists_match( \@results, \@expected, '--ignore-case flag' );
