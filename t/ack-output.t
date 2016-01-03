#!perl -T

use warnings;
use strict;

use Test::More tests => 24;

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

ARG_MULTIPLE_FILES: {
    my @expected = split( /\n/, <<'HERE' );
And there you were
He stood there lookin' at me and I saw him smile.
And I knew I wouldn't be there to help ya along.
In the case of Christianity and Judaism there exists the belief
HERE

    my @files = qw( t/text );
    my @args = qw( there --sort-files -h --output=$_ );
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

MATCH_MULTIPLE_FILES: {
    my @expected = split( /\n/, <<'HERE' );
t/text/4th-of-july.txt:22:there
t/text/boy-named-sue.txt:48:there
t/text/boy-named-sue.txt:52:there
t/text/science-of-myth.txt:3:there
HERE

    my @files = qw ( t/text );
    my @args = qw( there --sort-files --output=$& );
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

PREMATCH_MULTIPLE_FILES: {

# No HEREDOC here since we do not want our editor/IDE messing with trailing whitespace.
    my @expected = (
    "And ",
    "He stood ",
    "And I knew I wouldn't be ",
    "In the case of Christianity and Judaism " );

    my @files = qw( t/text/);
    my @args = qw( there -h --sort-files --output=$` );
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

POSTMATCH_MULTIPLE_FILES: {
    my @expected = split( /\n/, <<'HERE' );
 you were
 lookin' at me and I saw him smile.
 to help ya along.
 exists the belief
HERE

    my @files = qw( t/text/ );
    my @args = qw( there -h --sort-files --output=$' );
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

SUBPATTERN_MATCH_MULTIPLE_FILES: {
    my @expected = split( /\n/, <<'HERE' );
And-there-you
stood-there-lookin
be-there-to
Judaism-there-exists
HERE

    my @files = qw( t/text/ );
    my @args = qw( (\w+)\s(there)\s(\w+) -h --sort-files --output=$1-$2-$3 );
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

INPUT_LINE_NUMBER_MULTIPLE_FILES: {
    my @expected = split( /\n/, <<'HERE' );
t/text/4th-of-july.txt:22:line:22
t/text/boy-named-sue.txt:48:line:48
t/text/boy-named-sue.txt:52:line:52
t/text/science-of-myth.txt:3:line:3
HERE

    my @files = qw( t/text/ );
    my @args = qw( there --sort-files --output=line:$. );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Line number' );
}
