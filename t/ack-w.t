#!perl -T

use warnings;
use strict;

use Test::More tests => 16;

use lib 't';
use Util;

prep_environment();

TRAILING_PUNC: {
    my @expected = split( /\n/, <<'HERE' );
Respite-respite and nepenthe from thy memories of Lenore!"
Clasp a rare and radiant maiden whom the angels name Lenore!"
HERE

    my @files = qw( t/text );
    my @args = qw( Lenore! -w -h --sort-files );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for Lenore!' );
}

TRAILING_METACHAR_BACKSLASH_W: {
    my @expected = split( /\n/, <<'HERE' );
be a Majority of the whole Number of Electors appointed; and if there be
President. But if there should remain two or more who have equal Votes,
HERE

    my @files = qw( t/text/constitution.txt );
    my @args = qw( ther\w -w --sort-files );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for ther\\w, with -w, so no thereofs or thereins' );
}


TRAILING_METACHAR_DOT: {
    # Because the . at the end of the regular expression is not a word
    # character, a word boundary is not required after the match.
    my @expected = split( /\n/, <<'HERE' );
speech, or of the press; or the right of the people peaceably to assemble,
the right of the people to keep and bear Arms, shall not be infringed.
The right of the people to be secure in their persons, houses, papers,
In all criminal prosecutions, the accused shall enjoy the right to a
twenty dollars, the right of trial by jury shall be preserved, and no
The enumeration in the Constitution, of certain rights, shall not be
limited Times to Authors and Inventors the exclusive Right to their
HERE

    my @files = qw( t/text );
    my @args = ( 'right.', qw( -i -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for right.' );
}

BEGINS_AND_ENDS_WITH_WORD_CHAR: {
    # Normal case of whole word match.
    my @expected = split( /\n/, <<'HERE' );
Each House shall be the Judge of the Elections, Returns and Qualifications
shall judge necessary and expedient; he may, on extraordinary Occasions,
HERE

    my @files = qw( t/text );
    my @args = ( 'judge', qw( -w -h -i --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for two "judge" as whole word, not five "judge/judges"' );
}

BEGINS_BUT_NOT_ENDS_WITH_WORD_CHAR: {
    # The last character of the regexp is not a word, disabling the word boundary check at the end of the match.
    my @expected = split( /\n/, <<'HERE' );
All legislative Powers herein granted shall be vested in a Congress
and shall have the sole Power of Impeachment.
The Senate shall have the sole Power to try all Impeachments. When
The Congress shall have Power To lay and collect Taxes, Duties, Imposts
Execution the foregoing Powers, and all other Powers vested by this
or Compact with another State, or with a foreign Power, or engage in War,
The executive Power shall be vested in a President of the United States
Resignation, or Inability to discharge the Powers and Duties of the said
and he shall have Power to Grant Reprieves and Pardons for Offences
He shall have Power, by and with the Advice and Consent of the Senate,
The President shall have Power to fill up all Vacancies that may happen
The judicial Power of the United States, shall be vested in one supreme
The judicial Power shall extend to all Cases, in Law and Equity,
The Congress shall have Power to declare the Punishment of Treason, but
The Congress shall have Power to dispose of and make all needful Rules and
HERE

    my @files = qw( t/text/constitution.txt );
    my @args = ( 'pow()', qw( -w -h -i ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for "pow()" with word flag, but regexp does not end with word char' );
}

ENDS_BUT_NOT_BEGINS_WITH_WORD_CHAR: {
    # The first character of the regexp is not a word, disabling the word boundary check at the start of the match.
    my @expected = split( /\n/, <<'HERE' );
each State shall have the Qualifications requisite for Electors of the
Providence Plantations one, Connecticut five, New-York six, New Jersey
The Times, Places and Manner of holding Elections for Senators and
Regulations, except as to the Places of chusing Senators.
Each House shall be the Judge of the Elections, Returns and Qualifications
return it, with his Objections to that House in which it shall have
originated, who shall enter the Objections at large on their Journal,
with the Objections, to the other House, by which it shall likewise be
and House of Representatives, according to the Rules and Limitations
To regulate Commerce with foreign Nations, and among the several States,
and Offences against the Law of Nations;
suppress Insurrections and repel Invasions;
Appropriations made by Law; and a regular Statement and Account of the
Fact, with such Exceptions, and under such Regulations as the Congress
Regulations respecting the Territory or other Property belonging to the
by Conventions in three fourths thereof, as the one or the other Mode of
The Ratification of the Conventions of nine States, shall be sufficient
HERE

    my @files = qw( t/text/constitution.txt );
    my @args = ( '()tions', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for "()tions" with word flag, but regexp does not begin with word char' );
}

NEITHER_BEGINS_NOR_ENDS_WITH_WORD_CHAR: {
    # Because the regular expression doesn't begin or end with a word character, the 'words mode' doesn't affect the match.
    my @expected = split( /\n/, <<'HERE' );
Each House shall be the Judge of the Elections, Returns and Qualifications
Session of their respective Houses, and in going to and returning from
return it, with his Objections to that House in which it shall have
any Bill shall not be returned by the President within ten Days (Sundays
their Adjournment prevent its Return, in which Case it shall not be a Law.
HERE

    my @files = qw( t/text/constitution.txt );
    my @args = ( '(return)', qw( -w -i -h ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for "return" with word flag, but regexp does not begin or end with word char' );
}

# Test for issue #443
ALTERNATING_NUMBERS: {
    my @expected = ();

    my @files = qw( t/text/number.txt );

    my @args = ( '650|660|670|680', '-w' );

    ack_lists_match( [ @args, @files ], \@expected, 'Alternations should also respect boundaries when using -w' );
}

done_testing();
