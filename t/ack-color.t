#!perl

use warnings;
use strict;

use Test::More;
use File::Next ();

use lib 't';
use Util;

plan tests => 10;

prep_environment();

my $match_start = "\e[30;43m";
my $match_end   = "\e[0m";
my $line_end    = "\e[0m\e[K";

NORMAL_COLOR: {
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( called --color );
    my @results = run_ack( @args, @files );

    ok( grep { /\e/ } @results, 'normal match highlighted' ) or diag(explain(\@results));
}

MATCH_WITH_BACKREF: {
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( (called).*\1 --color );
    my @results = run_ack( @args, @files );

    is( @results, 1, 'backref pattern matches once' );

    ok( grep { /\e/ } @results, 'match with backreference highlighted' );
}

BRITISH_COLOR: {
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( called --colour );
    my @results = run_ack( @args, @files );

    ok( grep { /\e/ } @results, 'normal match highlighted' );
}

MULTIPLE_MATCHES: {
    my @files = qw( t/text/freedom-of-choice.txt );
    my @args = qw( v.+?m|c.+?n -w --color );
    my @results = run_ack( @args, @files );

    is( @results, 1, 'multiple matches on 1 line' );
    is( $results[0], "A ${match_start}victim${match_end} of ${match_start}collision${match_end} on the open sea$line_end",
        'multiple matches highlighted' );
}
