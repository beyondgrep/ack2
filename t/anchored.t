#!perl -T

# Make sure beginning-of-line anchor works

use strict;
use warnings;

use Test::More tests => 5;
use lib 't';
use Util;

prep_environment();

my @files = qw( t/text/constitution.txt );

FRONT_ANCHORED: {
    my @args  = qw( --sort-files -h -i ^congress );

    my @expected = line_split( <<'HERE' );
Congress prior to the Year one thousand eight hundred and eight, but
HERE

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for front-anchored "congress"' );
}

BACK_ANCHORED: {
    my @args  = qw( --sort-files -h -i congress$ );

    my @expected = line_split( <<'HERE' );
All legislative Powers herein granted shall be vested in a Congress
Fact, with such Exceptions, and under such Regulations as the Congress
Records, and judicial Proceedings of every other State. And the Congress
HERE

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for back-anchored "congress"' );
}

UNANCHORED: {
    my @args  = qw( --sort-files -h -i congress );

    my @expected = line_split( <<'HERE' );
All legislative Powers herein granted shall be vested in a Congress
the first Meeting of the Congress of the United States, and within
thereof; but the Congress may at any time by Law make or alter such
The Congress shall assemble at least once in every Year, and such
Neither House, during the Session of Congress, shall, without the Consent
a Law, in like Manner as if he had signed it, unless the Congress by
The Congress shall have Power To lay and collect Taxes, Duties, Imposts
the discipline prescribed by Congress;
particular States, and the Acceptance of Congress, become the Seat of
Congress prior to the Year one thousand eight hundred and eight, but
the Consent of the Congress, accept of any present, Emolument, Office,
No State shall, without the Consent of the Congress, lay any Imposts or
subject to the Revision and Control of the Congress.
No State shall, without the Consent of Congress, lay any Duty of Tonnage,
and Representatives to which the State may be entitled in the Congress:
The Congress may determine the Time of chusing the Electors, and the
Office, the Same shall devolve on the Vice President, and the Congress may
be established by Law: but the Congress may by Law vest the Appointment
He shall from time to time give to the Congress Information on the State
Court, and in such inferior Courts as the Congress may from time to
Fact, with such Exceptions, and under such Regulations as the Congress
shall be at such Place or Places as the Congress may by Law have directed.
The Congress shall have Power to declare the Punishment of Treason, but
Records, and judicial Proceedings of every other State. And the Congress
New States may be admitted by the Congress into this Union; but no new
concerned as well as of the Congress.
The Congress shall have Power to dispose of and make all needful Rules and
The Congress, whenever two thirds of both Houses shall deem it necessary,
Ratification may be proposed by the Congress; Provided that no Amendment
HERE

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for unanchored congress' );
}

done_testing();
