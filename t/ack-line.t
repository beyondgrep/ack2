#!perl -T

use warnings;
use strict;

use Test::More;

use lib 't';
use Util;

if ( not has_io_pty() ) {
    plan skip_all => q{You need to install IO::Pty to run this test};
    exit(0);
}

plan tests => 16;

prep_environment();

LINE_6_AND_3: {
    my @expected = line_split( <<'HERE' );
and to petition the Government for a redress of grievances.
Congress shall make no law respecting an establishment of religion,
HERE

    my @files = qw( t/text/bill-of-rights.txt );
    my @args = qw( --lines=6 --lines=3 );

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for lines 1 and 5' );
}

LINES_WITH_A_COMMA: {
    my @expected = line_split( <<'HERE' );
Congress shall make no law respecting an establishment of religion,
and to petition the Government for a redress of grievances.
HERE

    my @files = qw( t/text/bill-of-rights.txt );
    my @args = ( '--lines=3,6' );

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for lines with a comma' );
}

LINES_WITH_A_RANGE: {
    my @expected = line_split( <<'HERE' );
Congress shall make no law respecting an establishment of religion,
or prohibiting the free exercise thereof; or abridging the freedom of
speech, or of the press; or the right of the people peaceably to assemble,
and to petition the Government for a redress of grievances.
HERE

    my @files = qw( t/text/bill-of-rights.txt );
    my @args = qw( --lines=3-6 );

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for lines 3 to 6' );
}

LINES_WITH_CONTEXT: {
    my @expected = line_split( <<'HERE' );
of that House shall agree to pass the Bill, it shall be sent, together
with the Objections, to the other House, by which it shall likewise be
reconsidered, and if approved by two thirds of that House, it shall become
a Law. But in all such Cases the Votes of both Houses shall be determined
by Yeas and Nays, and the Names of the Persons voting for and against
the Bill shall be entered on the Journal of each House respectively. If
any Bill shall not be returned by the President within ten Days (Sundays
HERE

    my @files = qw( t/text/constitution.txt );
    my @args = qw( --lines=156 -C3 );

    ack_lists_match( [ @files, @args ], \@expected, 'Looking for line 3 with two lines of context' );
}

LINES_THAT_MAY_BE_NON_EXISTENT: {
    my @expected = line_split( <<'HERE' );
"For the love of God, Montresor!"
"A mason," I replied.
HERE

    my @files = qw( t/text/amontillado.txt );
    my @args = ( '--lines=309,200,1000' );

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for non existent line' );
}

LINE_AND_PASSTHRU: {
    my @expected = line_split( <<'HERE' );
=head1 Dummy document

=head2 There's important stuff in here!
HERE

    my @files = qw( t/swamp/perl.pod );
    my @args = qw( --lines=2 --passthru );

    ack_lists_match( [ @args, @files ], \@expected, 'Checking --passthru behaviour with --line' );
}


LINE_1_MULTIPLE_FILES: {
    my @target_file = map { reslash( $_ ) } qw(
        t/swamp/c-header.h
        t/swamp/c-source.c
    );
    my @expected = line_split( <<"HERE" );
$target_file[0]:1:/*    perl.h
$target_file[1]:1:/*  A Bison parser, made from plural.y
HERE

    my @files = qw( t/swamp/ );
    my @args = qw( --cc --lines=1 );

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for first line in multiple files' );
}


LINE_1_CONTEXT: {
    my @target_file = map { reslash( $_ ) } qw(
        t/swamp/c-header.h
        t/swamp/c-source.c
    );
    my @expected = line_split( <<"HERE" );
$target_file[0]:1:/*    perl.h
$target_file[0]-2- *
$target_file[0]-3- *    Copyright (C) 1993, 1994, 1995, 1996, 1997, 1998, 1999,
$target_file[0]-4- *    2000, 2001, 2002, 2003, 2004, 2005, 2006, by Larry Wall and others
--
$target_file[1]:1:/*  A Bison parser, made from plural.y
$target_file[1]-2-    by GNU Bison version 1.28  */
$target_file[1]-3-
$target_file[1]-4-#define YYBISON 1  /* Identify Bison output.  */
HERE

    my @files = qw( t/swamp/ );
    my @args = qw( --cc --lines=1 --after=3 --sort );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for first line in multiple files' );
}

LINE_NO_WARNINGS: {
    my @expected = (
        'Well, my daddy left home when I was three',
    );

    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( --lines=1 );

    my @output = run_ack_interactive( @args, @files );
    is scalar(@output), 1, 'There must be exactly one line of output (with no warnings)';
}

LINE_WITH_REGEX: {
    # Specifying both --line and a regex should result in an error.
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( --lines=1 --match Sue );

    my ($stdout, $stderr) = run_ack_with_stderr( @args, @files );
    isnt( get_rc(), 0, 'Specifying both --line and --match must lead to an error RC' );
    is_empty_array( $stdout, 'No normal output' );
    is( scalar @{$stderr}, 1, 'One line of stderr output' );
    like( $stderr->[0], qr/\Q(Sue)/, 'Error message must contain "(Sue)"' );
}

done_testing();
