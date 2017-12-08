#!perl -T

use warnings;
use strict;

use Test::More tests => 6;

use lib 't';
use Util;
use Term::ANSIColor;

prep_environment();


my @HIGHLIGHT = qw( --color --group --sort-files );

BASIC: {
    my @args  = qw( --sort-files Montresor t/text/ );

    my $expected_original = <<'END';
<t/text/amontillado.txt>
{99}:the catacombs of the (Montresor)s.
{152}:"The (Montresor)s," I replied, "were a great and numerous family."
{309}:"For the love of God, (Montresor)!"
END

    $expected_original = windows_slashify( $expected_original ) if is_windows;

    my @expected = colorize( $expected_original );

    my @results = run_ack( @args, @HIGHLIGHT );

    is_deeply( \@results, \@expected, 'Basic highlights match' );
}


METACHARACTERS: {
    my @args  = qw( --sort-files \w*rave\w* t/text/ );
    my $expected_original = <<'END';
<t/text/gettysburg.txt>
{13}:we can not hallow -- this ground. The (brave) men, living and dead, who

<t/text/ozymandias.txt>
{1}:I met a (traveller) from an antique land

<t/text/raven.txt>
{51}:By the (grave) and stern decorum of the countenance it wore,
{52}:"Though thy crest be shorn and shaven, thou," I said, "art sure no (craven),
END

    $expected_original = windows_slashify( $expected_original ) if is_windows;

    my @expected = colorize( $expected_original );

    my @results = run_ack( @args, @HIGHLIGHT );

    is_deeply( \@results, \@expected, 'Metacharacters match' );
}


CONTEXT: {
    my @args  = qw( --sort-files free -C1 t/text/ );

    my $expected_original = <<'END';
<t/text/bill-of-rights.txt>
{3}-Congress shall make no law respecting an establishment of religion,
{4}:or prohibiting the (free) exercise thereof; or abridging the (free)dom of
{5}-speech, or of the press; or the right of the people peaceably to assemble,
--
{9}-
{10}:A well regulated Militia, being necessary to the security of a (free) State,
{11}-the right of the people to keep and bear Arms, shall not be infringed.

<t/text/constitution.txt>
{31}-respective Numbers, which shall be determined by adding to the whole
{32}:Number of (free) Persons, including those bound to Service for a Term
{33}-of Years, and excluding Indians not taxed, three fifths of all other

<t/text/gettysburg.txt>
{22}-these dead shall not have died in vain -- that this nation, under God,
{23}:shall have a new birth of (free)dom -- and that government of the people,
{24}-by the people, for the people, shall not perish from the earth.
END

    $expected_original = windows_slashify( $expected_original ) if is_windows;

    my @expected = colorize( $expected_original );

    my @results = run_ack( @args, @HIGHLIGHT );

    is_deeply( \@results, \@expected, 'Context is all good' );
}
