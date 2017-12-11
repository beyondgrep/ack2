#!perl -T

use warnings;
use strict;

use Test::More tests => 24;

use lib 't';
use Util;

prep_environment();

ARG: {
    my @expected = line_split( <<'HERE' );
shall have a new birth of freedom -- and that government of the people,
HERE

    my @files = qw( t/text/gettysburg.txt );
    my @args = qw( free --output=$_ );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Matching line' );
}

ARG_MULTIPLE_FILES: {
    # Note the first line is there twice because it matches twice.
    my @expected = line_split( <<'HERE' );
or prohibiting the free exercise thereof; or abridging the freedom of
or prohibiting the free exercise thereof; or abridging the freedom of
A well regulated Militia, being necessary to the security of a free State,
Number of free Persons, including those bound to Service for a Term
shall have a new birth of freedom -- and that government of the people,
HERE

    my @files = qw( t/text );
    my @args = qw( free --sort-files -h --output=$_ );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Matching line' );
}

MATCH: {
    my @expected = (
        'free'
    );

    my @files = qw( t/text/gettysburg.txt );
    my @args = qw( free --output=$& );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Part of a line matching pattern' );
}

MATCH_MULTIPLE_FILES: {
    my @expected = line_split( <<'HERE' );
t/text/bill-of-rights.txt:4:free
t/text/bill-of-rights.txt:4:free
t/text/bill-of-rights.txt:10:free
t/text/constitution.txt:32:free
t/text/gettysburg.txt:23:free
HERE

    my @files = qw ( t/text );
    my @args = qw( free --sort-files --output=$& );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Part of a line matching pattern' );
}

PREMATCH: {
    # No HEREDOC here since we do not want our editor/IDE messing with trailing whitespace.
    my @expected = (
        'shall have a new birth of '
    );

    my @files = qw( t/text/gettysburg.txt );
    my @args = qw( freedom --output=$` );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Part of a line preceding match' );
}

PREMATCH_MULTIPLE_FILES: {
    # No HEREDOC here since we do not want our editor/IDE messing with trailing whitespace.
    my @expected = (
        'or prohibiting the free exercise thereof; or abridging the ',
        'shall have a new birth of '
    );

    my @files = qw( t/text/);
    my @args = qw( freedom -h --sort-files --output=$` );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Part of a line preceding match' );
}

POSTMATCH: {
    my @expected = line_split( <<'HERE' );
 -- and that government of the people,
HERE

    my @files = qw( t/text/gettysburg.txt );
    my @args = qw( freedom --output=$' );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Part of a line that follows match' );
}

POSTMATCH_MULTIPLE_FILES: {
    my @expected = line_split( <<'HERE' );
 of
 -- and that government of the people,
HERE

    my @files = qw( t/text/ );
    my @args = qw( freedom -h --sort-files --output=$' );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Part of a line that follows match' );
}

SUBPATTERN_MATCH: {
    my @expected = (
        'love-God-Montresor'
    );

    my @files = qw( t/text/amontillado.txt );
    my @args = qw( (love).+(God).+(Montresor) --output=$1-$2-$3 );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Capturing parentheses match' );
}

SUBPATTERN_MATCH_MULTIPLE_FILES: {
    my @expected = line_split( <<'HERE' );
the-free-exercise
a-free-State
of-free-Persons
HERE

    my @files = qw( t/text/ );
    my @args = qw( (\w+)\s(free)\s(\w+) -h --sort-files --output=$1-$2-$3 );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Capturing parentheses match' );
}

INPUT_LINE_NUMBER: {
    my @expected = (
      'line:15'
    );

    my @files = qw( t/text/bill-of-rights.txt );
    my @args = qw( quartered --output=line:$. );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Line number' );
}

INPUT_LINE_NUMBER_MULTIPLE_FILES: {
    my @expected = line_split( <<'HERE' );
t/text/bill-of-rights.txt:4:line:4
t/text/bill-of-rights.txt:4:line:4
t/text/bill-of-rights.txt:10:line:10
t/text/constitution.txt:32:line:32
t/text/gettysburg.txt:23:line:23
HERE

    my @files = qw( t/text/ );
    my @args = qw( free --sort-files --output=line:$. );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Line number' );
}
