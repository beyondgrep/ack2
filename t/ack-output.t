#!perl -T

use warnings;
use strict;

use Test::More tests => 12;

use lib 't';
use Util;
use File::Next;

prep_environment();

ARG: {
    my @expected = (
      'Sink, swim, go down with the ship'
    );

    my @files = qw( t/text/freedom-of-choice.txt );
    my @args = qw( swim --output=$_ );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Matching line' );
}

MATCH: {
    my @expected = (
      'swim'
    );

    my @files = qw( t/text/freedom-of-choice.txt );
    my @args = qw( swim --output=$& );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Part of a line matching pattern' );
}

PREMATCH: {
    my @expected = (
      'Sink, '
    );

    my @files = qw( t/text/freedom-of-choice.txt );
    my @args = qw( swim --output=$` );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Part of a line preceding match' );
}

POSTMATCH: {
    my @expected = (
      ', go down with the ship'
    );

    my @files = qw( t/text/freedom-of-choice.txt );
    my @args = qw( swim --output=$' );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Part of a line that follows match' );
}

SUBPATTERN_MATCH: {
    my @expected = (
      'Sink-swim-ship'
    );

    my @files = qw( t/text/freedom-of-choice.txt );
    my @args = qw( ^(Sink).+(swim).+(ship)$ --output=$1-$2-$3 );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Capturing parentheses match' );
}

INPUT_LINE_NUMBER: {
    my @expected = (
      'line:3'
    );

    my @files = qw( t/text/freedom-of-choice.txt );
    my @args = qw( swim --output=line:$. );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Line number' );
}
