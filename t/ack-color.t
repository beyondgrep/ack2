#!perl -T

use warnings;
use strict;

use Test::More;

use lib 't';
use Util;

plan tests => 11;

prep_environment();

my $match_start = "\e[30;43m";
my $match_end   = "\e[0m";
my $line_end    = "\e[0m\e[K";

NORMAL_COLOR: {
    my @files = qw( t/text/bill-of-rights.txt );
    my @args = qw( free --color );
    my @results = run_ack( @args, @files );

    ok( grep { /\e/ } @results, 'normal match highlighted' ) or diag(explain(\@results));
}

MATCH_WITH_BACKREF: {
    my @files = qw( t/text/bill-of-rights.txt );
    my @args = qw( (free).*\1 --color );
    my @results = run_ack( @args, @files );

    is( @results, 1, 'backref pattern matches once' );

    ok( grep { /\e/ } @results, 'match with backreference highlighted' );
}

BRITISH_COLOR: {
    my @files = qw( t/text/bill-of-rights.txt );
    my @args = qw( free --colour );
    my @results = run_ack( @args, @files );

    ok( grep { /\e/ } @results, 'normal match highlighted' );
}

MULTIPLE_MATCHES: {
    my @files = qw( t/text/amontillado.txt );
    my @args = qw( az.+?e|ser.+?nt -w --color );
    my @results = run_ack( @args, @files );

    is_deeply( \@results, [
        "\"A huge human foot d'or, in a field ${match_start}azure${match_end}; the foot crushes a ${match_start}serpent${match_end}$line_end",
    ] );
}


ADJACENT_CAPTURE_COLORING: {
    my @files = qw( t/text/raven.txt );
    my @args = qw( (Temp)(ter) --color );
    my @results = run_ack( @args, @files );

    # The double end + start is kinda weird; this test could probably be more robust.
    is_deeply( \@results, [
        "Whether ${match_start}Temp${match_end}${match_start}ter${match_end} sent, or whether tempest tossed thee here ashore,",
    ] );
}
