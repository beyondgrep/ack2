#!perl -T

use strict;
use warnings;

use Test::More tests => 12;
use File::Next ();

use lib 't';
use Util;

prep_environment();

my $freedom = File::Next::reslash( 't/text/freedom-of-choice.txt' );
my $bobbie  = File::Next::reslash( 't/text/me-and-bobbie-mcgee.txt' );

NO_GROUPING: {
    my @expected = split( /\n/, <<"EOF" );
$freedom:2:Nobody ever said life was free
$freedom:4:But use your freedom of choice
$freedom:6:I'll say it again in the land of the free
$freedom:7:Use your freedom of choice
$freedom:8:Your freedom of choice
$freedom:28:I'll say it again in the land of the free
$freedom:29:Use your freedom of choice
$bobbie:12:    Nothin' don't mean nothin' if it ain't free
$bobbie:27:    Nothin' don't mean nothin' if it ain't free
EOF

    my @files = sort map {
        untaint($_)
    } glob( 't/text/*.txt' );

    my @cases = (
        [qw( --nogroup --nocolor free )],
        [qw( --nobreak --noheading --nocolor free )],
    );
    for my $args ( @cases ) {
        my @results = run_ack( @{$args}, @files );
        lists_match( \@results, \@expected, 'No grouping' );
    }
}


STANDARD_GROUPING: {
    my @expected = split( /\n/, <<"EOF" );
$freedom
2:Nobody ever said life was free
4:But use your freedom of choice
6:I'll say it again in the land of the free
7:Use your freedom of choice
8:Your freedom of choice
28:I'll say it again in the land of the free
29:Use your freedom of choice

$bobbie
12:    Nothin' don't mean nothin' if it ain't free
27:    Nothin' don't mean nothin' if it ain't free
EOF

    my @files = sort map {
        untaint($_)
    } glob( 't/text/*.txt' );
    my @cases = (
        [qw( --group --nocolor free )],
        [qw( --heading --break --nocolor free )],
    );
    for my $args ( @cases ) {
        my @results = run_ack( @{$args}, @files );
        lists_match( \@results, \@expected, 'Standard grouping' );
    }
}

HEADING_NO_BREAK: {
    my @expected = split( /\n/, <<"EOF" );
$freedom
2:Nobody ever said life was free
4:But use your freedom of choice
6:I'll say it again in the land of the free
7:Use your freedom of choice
8:Your freedom of choice
28:I'll say it again in the land of the free
29:Use your freedom of choice
$bobbie
12:    Nothin' don't mean nothin' if it ain't free
27:    Nothin' don't mean nothin' if it ain't free
EOF

    my @files = sort map {
        untaint($_)
    } glob( 't/text/*.txt' );
    my @arg_sets = (
        [qw( --heading --nobreak --nocolor free )],
    );
    for my $set ( @arg_sets ) {
        my @results = run_ack( @{$set}, @files );
        lists_match( \@results, \@expected, 'Standard grouping' );
    }
}

BREAK_NO_HEADING: {
    my @expected = split( /\n/, <<"EOF" );
$freedom:2:Nobody ever said life was free
$freedom:4:But use your freedom of choice
$freedom:6:I'll say it again in the land of the free
$freedom:7:Use your freedom of choice
$freedom:8:Your freedom of choice
$freedom:28:I'll say it again in the land of the free
$freedom:29:Use your freedom of choice

$bobbie:12:    Nothin' don't mean nothin' if it ain't free
$bobbie:27:    Nothin' don't mean nothin' if it ain't free
EOF

    my @files = sort map {
        untaint($_)
    }glob( 't/text/*.txt' );

    my @arg_sets = (
        [qw( --break --noheading --nocolor free )],
    );
    for my $set ( @arg_sets ) {
        my @results = run_ack( @{$set}, @files );
        lists_match( \@results, \@expected, 'No grouping' );
    }
}
