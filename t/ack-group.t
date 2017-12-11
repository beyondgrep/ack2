#!perl -T

use strict;
use warnings;

use Test::More tests => 12;

use lib 't';
use Util;

prep_environment();

my ($bill_, $const, $getty) = map { reslash( "t/text/$_" ) } qw( bill-of-rights.txt constitution.txt gettysburg.txt );

my @TEXT_FILES = sort map { untaint($_) } glob( 't/text/*.txt' );


NO_GROUPING: {
    my @expected = line_split( <<"EOF" );
$bill_:4:or prohibiting the free exercise thereof; or abridging the freedom of
$bill_:10:A well regulated Militia, being necessary to the security of a free State,
$const:32:Number of free Persons, including those bound to Service for a Term
$getty:23:shall have a new birth of freedom -- and that government of the people,
EOF

    my @cases = (
        [qw( --nogroup --nocolor free )],
        [qw( --nobreak --noheading --nocolor free )],
    );
    for my $args ( @cases ) {
        my @results = run_ack( @{$args}, @TEXT_FILES );
        lists_match( \@results, \@expected, 'No grouping' );
    }
}


STANDARD_GROUPING: {
    my @expected = line_split( <<"EOF" );
$bill_
4:or prohibiting the free exercise thereof; or abridging the freedom of
10:A well regulated Militia, being necessary to the security of a free State,

$const
32:Number of free Persons, including those bound to Service for a Term

$getty
23:shall have a new birth of freedom -- and that government of the people,
EOF

    my @cases = (
        [qw( --group --nocolor free )],
        [qw( --heading --break --nocolor free )],
    );
    for my $args ( @cases ) {
        my @results = run_ack( @{$args}, @TEXT_FILES );
        lists_match( \@results, \@expected, 'Standard grouping' );
    }
}

HEADING_NO_BREAK: {
    my @expected = line_split( <<"EOF" );
$bill_
4:or prohibiting the free exercise thereof; or abridging the freedom of
10:A well regulated Militia, being necessary to the security of a free State,
$const
32:Number of free Persons, including those bound to Service for a Term
$getty
23:shall have a new birth of freedom -- and that government of the people,
EOF

    my @arg_sets = (
        [qw( --heading --nobreak --nocolor free )],
    );
    for my $set ( @arg_sets ) {
        my @results = run_ack( @{$set}, @TEXT_FILES );
        lists_match( \@results, \@expected, 'Standard grouping' );
    }
}

BREAK_NO_HEADING: {
    my @expected = line_split( <<"EOF" );
$bill_:4:or prohibiting the free exercise thereof; or abridging the freedom of
$bill_:10:A well regulated Militia, being necessary to the security of a free State,

$const:32:Number of free Persons, including those bound to Service for a Term

$getty:23:shall have a new birth of freedom -- and that government of the people,
EOF

    my @arg_sets = (
        [qw( --break --noheading --nocolor free )],
    );
    for my $set ( @arg_sets ) {
        my @results = run_ack( @{$set}, @TEXT_FILES );
        lists_match( \@results, \@expected, 'No grouping' );
    }
}

done_testing();

exit 0;
