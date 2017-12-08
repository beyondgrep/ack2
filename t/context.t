#!perl -T

use warnings;
use strict;

use Test::More tests => 36;
use File::Next (); # for reslash function

use lib 't';
use Util;

prep_environment();

# Checks also beginning of file.
BEFORE: {
    my @expected = split( /\n/, <<'EOF' );
I met a traveller from an antique land
--
Stand in the desert... Near them, on the sand,
Half sunk, a shattered visage lies, whose frown,
EOF

    my $regex = 'a';
    my @files = qw( t/text/ozymandias.txt );
    my @args = ( '-w', '-B1', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - before" );
}

BEFORE_WITH_LINE_NO: {
    my $target_file = File::Next::reslash( 't/text/ozymandias.txt' );
    my @expected = split( /\n/, <<"EOF" );
$target_file-1-I met a traveller from an antique land
$target_file-2-Who said: Two vast and trunkless legs of stone
$target_file:3:Stand in the desert... Near them, on the sand,
--
$target_file-12-Nothing beside remains. Round the decay
$target_file-13-Of that colossal wreck, boundless and bare
$target_file:14:The lone and level sands stretch far away.
EOF

    my $regex = 'sand';
    my @files = qw( t/text/ozymandias.txt t/text/bill-of-rights.txt );  # So we don't pick up constitution.txt
    my @args = ( '--sort-files', '-B2', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - before with line numbers" );
}

# Checks also end of file.
AFTER: {
    my @expected = split( /\n/, <<'EOF' );
The lone and level sands stretch far away.
EOF

    my $regex = 'sands';
    my @files = qw( t/text/ozymandias.txt );
    my @args = ( '-A2', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - after" );
}

# Context defaults to 2.
CONTEXT_DEFAULT: {
    my @expected = split( /\n/, <<'EOF' );
"Yes,"I said, "let us be gone."

"For the love of God, Montresor!"

"Yes," I said, "for the love of God!"
EOF

    my $regex = 'Montresor';
    my @files = qw( t/text/amontillado.txt );
    my @args = ( '-w', '-C', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - context defaults to 2" );
}

# Try context 1.
CONTEXT_ONE: {
    my @expected = split( /\n/, <<"EOF" );

"For the love of God, Montresor!"
EOF

    push( @expected, '' );  # Since split eats the last line.

    my $regex = 'Montresor';
    my @files = qw( t/text/amontillado.txt );
    my @args = ( '-w', '-C', 1, $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - context=1" );
}

# --context=0 means no context.
CONTEXT_ONE: {
    my @expected = split( /\n/, <<'EOF' );
"For the love of God, Montresor!"
EOF

    my $regex = 'Montresor';
    my @files = qw( t/text/amontillado.txt );
    my @args = ( '-w', '-C', 0, $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - context=0" );
}

# -1 must not stop the ending context from displaying.
CONTEXT_DEFAULT: {
    my @expected = split( /\n/, <<"EOF" );
or prohibiting the free exercise thereof; or abridging the freedom of
speech, or of the press; or the right of the people peaceably to assemble,
and to petition the Government for a redress of grievances.
EOF

    my $regex = 'right';
    my @files = qw( t/text/bill-of-rights.txt );
    my @args = ( '-1', '-C1', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex with -1" );
}

# -C with overlapping contexts (adjacent lines)
CONTEXT_OVERLAPPING: {
    my @expected = split( /\n/, <<"EOF" );
This is line 03
This is line 04
This is line 05
This is line 06
This is line 07
This is line 08
EOF

    my $regex = '05|06';
    my @files = qw( t/text/numbered-text.txt );
    my @args = ( '-C', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex with overlapping contexts" );
}

# -C with contexts that touch.
CONTEXT_ADJACENT: {
    my @expected = split( /\n/, <<"EOF" );
This is line 01
This is line 02
This is line 03
This is line 04
This is line 05
This is line 06
This is line 07
This is line 08
This is line 09
This is line 10
EOF

    my $regex = '03|08';
    my @files = qw( t/text/numbered-text.txt );
    my @args = ( '-C', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex with contexts that touch" );
}

# -C with contexts that just don't touch.
CONTEXT_NONADJACENT: {
    my @expected = split( /\n/, <<"EOF" );
This is line 01
This is line 02
This is line 03
This is line 04
This is line 05
--
This is line 07
This is line 08
This is line 09
This is line 10
This is line 11
EOF

    my $regex = '03|09';
    my @files = qw( t/text/numbered-text.txt );
    my @args = ( '-C', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex with contexts that just don't touch" );
}

CONTEXT_OVERLAPPING_COLOR: {
    my $match_start = "\e[30;43m";
    my $match_end   = "\e[0m";
    my $line_end    = "\e[0m\e[K";

    my @expected = split( /\n/, <<"EOF" );
This is line 03
This is line 04
This is line ${match_start}05${match_end}${line_end}
This is line ${match_start}06${match_end}${line_end}
This is line 07
This is line 08
EOF

    my $regex = '05|06';
    my @files = qw( t/text/numbered-text.txt );
    my @args = ( '--color', '-C', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex with overlapping contexts" );
}

CONTEXT_OVERLAPPING_COLOR_BEFORE: {
    my $match_start = "\e[30;43m";
    my $match_end   = "\e[0m";
    my $line_end    = "\e[0m\e[K";

    my @expected = split( /\n/, <<"EOF" );
This is line 03
This is line 04
This is line ${match_start}05${match_end}${line_end}
This is line ${match_start}06${match_end}${line_end}
EOF

    my $regex = '05|06';
    my @files = qw( t/text/numbered-text.txt );
    my @args = ( '--color', '-B2', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex with overlapping contexts" );
}

CONTEXT_OVERLAPPING_COLOR_AFTER: {
    my $match_start = "\e[30;43m";
    my $match_end   = "\e[0m";
    my $line_end    = "\e[0m\e[K";

    my @expected = split( /\n/, <<"EOF" );
This is line ${match_start}05${match_end}${line_end}
This is line ${match_start}06${match_end}${line_end}
This is line 07
This is line 08
EOF

    my $regex = '05|06';
    my @files = qw( t/text/numbered-text.txt );
    my @args = ( '--color', '-A2', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex with overlapping contexts" );
}

# -m3 should work properly and show only 3 matches with correct context
#    even though there is a 4th match in the after context of the third match
#    ("ratifying" in the last line)
CONTEXT_MAX_COUNT: {
    my @expected = split( /\n/, <<"EOF" );
ratified by the Legislatures of three fourths of the several States, or
by Conventions in three fourths thereof, as the one or the other Mode of
Ratification may be proposed by the Congress; Provided that no Amendment
which may be made prior to the Year One thousand eight hundred and eight
--
The Ratification of the Conventions of nine States, shall be sufficient
for the Establishment of this Constitution between the States so ratifying
EOF

    my $regex = 'ratif';

    my @files = qw( t/text/constitution.txt );
    my @args = ( '-i', '-m3', '-A1', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex with -m3" );
}

# Highlighting works with context.
HIGHLIGHTING: {
    my @ack_args = qw( wretch -i -C5 --color );
    my @results = pipe_into_ack( 't/text/raven.txt', @ack_args );
    my @escaped_lines = grep { /\e/ } @results;
    is( scalar @escaped_lines, 1, 'Only one line highlighted' );
    is( scalar @results, 11, 'Expecting altogether 11 lines back' );
}

# Grouping works with context (single file).
GROUPING_SINGLE_FILE: {
    my $target_file = File::Next::reslash( 't/etc/shebang.py.xxx' );
    my @expected = split( /\n/, <<"EOF" );
$target_file
1:#!/usr/bin/python
EOF

    my $regex = 'python';
    my @args = ( '--python', '--group', '-C', $regex );

    ack_lists_match( [ @args ], \@expected, "Looking for $regex in Python files with grouping" );
}


# Grouping works with context and multiple files.
# i.e. a separator line between different matches in the same file and no separator between files
GROUPING_MULTIPLE_FILES: {
    my @expected = split( /\n/, <<'EOF' );
t/text/amontillado.txt
258-As I said these words I busied myself among the pile of bones of
259:which I have before spoken. Throwing them aside, I soon uncovered

t/text/raven.txt
31-But the silence was unbroken, and the stillness gave no token,
32:And the only word there spoken was the whispered word, "Lenore?"
--
70-
71:Startled at the stillness broken by reply so aptly spoken,
--
114-"Get thee back into the tempest and the Night's Plutonian shore!
115:Leave no black plume as a token of that lie thy soul hath spoken!
EOF

    my $regex = 'spoken';
    my @files = qw( t/text/ );
    my @args = ( '--group', '-B1', '--sort-files', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex in multiple files with grouping" );
}

# See https://github.com/petdance/ack2/issues/326 and links there for details.
WITH_COLUMNS_AND_CONTEXT: {
    my @files = qw( t/text/ );
    my @expected = split( /\n/, <<'EOF' );
t/text/bill-of-rights.txt-1-# Amendment I
t/text/bill-of-rights.txt-2-
t/text/bill-of-rights.txt-3-Congress shall make no law respecting an establishment of religion,
t/text/bill-of-rights.txt:4:60:or prohibiting the free exercise thereof; or abridging the freedom of
t/text/bill-of-rights.txt-5-speech, or of the press; or the right of the people peaceably to assemble,
t/text/bill-of-rights.txt-6-and to petition the Government for a redress of grievances.
t/text/bill-of-rights.txt-7-
t/text/bill-of-rights.txt-8-# Amendment II
t/text/bill-of-rights.txt-9-
--
t/text/gettysburg.txt-18-fought here have thus far so nobly advanced. It is rather for us to be
t/text/gettysburg.txt-19-here dedicated to the great task remaining before us -- that from these
t/text/gettysburg.txt-20-honored dead we take increased devotion to that cause for which they gave
t/text/gettysburg.txt-21-the last full measure of devotion -- that we here highly resolve that
t/text/gettysburg.txt-22-these dead shall not have died in vain -- that this nation, under God,
t/text/gettysburg.txt:23:27:shall have a new birth of freedom -- and that government of the people,
t/text/gettysburg.txt-24-by the people, for the people, shall not perish from the earth.
EOF

    my $regex = 'freedom';
    my @args = ( '--column', '-C5', '-H', '--sort-files', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex" );
}
