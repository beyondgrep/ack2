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
Well, my daddy left home when I was three
--
But the meanest thing that he ever did
Was before he left, he went and named me Sue.
EOF

    my $regex = 'left';
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = ( '-B1', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - before" );
}

BEFORE_WITH_LINE_NO: {
    my $target_file = File::Next::reslash( 't/text/boy-named-sue.txt' );
    my @expected = split( /\n/, <<"EOF" );
$target_file-7-
$target_file-8-Well, he must have thought that it was quite a joke
$target_file:9:And it got a lot of laughs from a' lots of folks,
$target_file-10-It seems I had to fight my whole life through.
$target_file-11-Some gal would giggle and I'd turn red
$target_file:12:And some guy'd laugh and I'd bust his head,
--
$target_file-44-But I really can't remember when,
$target_file-45-He kicked like a mule and he bit like a crocodile.
$target_file:46:I heard him laugh and then I heard him cuss,
EOF

    my $regex = 'laugh';
    my @files = qw( t/text );
    my @args = ( '--sort-files', '-B2', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - before with line numbers" );
}

# Checks also end of file.
AFTER: {
    my @expected = split( /\n/, <<"EOF" );
I tell ya, life ain't easy for a boy named Sue.

Well, I grew up quick and I grew up mean,
--
    -- "A Boy Named Sue", Johnny Cash
EOF

    my $regex = '[nN]amed Sue';
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = ( '-A2', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - after" );
}

# Context defaults to 2.
CONTEXT_DEFAULT: {
    my @expected = split( /\n/, <<"EOF" );
And it got a lot of laughs from a' lots of folks,
It seems I had to fight my whole life through.
Some gal would giggle and I'd turn red
And some guy'd laugh and I'd bust his head,
I tell ya, life ain't easy for a boy named Sue.
EOF

    my $regex = 'giggle';
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = ( '-C', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - context defaults to 2" );
}

# Try context 1.
CONTEXT_ONE: {
    my @expected = split( /\n/, <<"EOF" );
It seems I had to fight my whole life through.
Some gal would giggle and I'd turn red
And some guy'd laugh and I'd bust his head,
EOF

    my $regex = 'giggle';
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = ( '-C', 1, $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - context=1" );
}

# --context=0 means no context.
CONTEXT_ONE: {
    my @expected = split( /\n/, <<"EOF" );
Some gal would giggle and I'd turn red
EOF

    my $regex = 'giggle';
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = ( '-C', 0, $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - context=0" );
}

# -1 must not stop the ending context from displaying.
CONTEXT_DEFAULT: {
    my @expected = split( /\n/, <<"EOF" );
And it got a lot of laughs from a' lots of folks,
It seems I had to fight my whole life through.
Some gal would giggle and I'd turn red
And some guy'd laugh and I'd bust his head,
I tell ya, life ain't easy for a boy named Sue.
EOF

    my $regex = 'giggle';
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = ( '-1', '-C', $regex );

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
#    ("give _ya_ that name" in the last line)
CONTEXT_MAX_COUNT: {
    my @expected = split( /\n/, <<"EOF" );
And some guy'd laugh and I'd bust his head,
I tell ya, life ain't easy for a boy named Sue.

--

I tell ya, I've fought tougher men
But I really can't remember when,
--
And if a man's gonna make it, he's gotta be tough
And I knew I wouldn't be there to help ya along.
So I give ya that name and I said goodbye
EOF

    my $regex = 'ya';

    my @files = qw( t/text/boy-named-sue.txt );
    my @args = ( '-m3', '-C1', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex with -m3" );
}

# Highlighting works with context.
HIGHLIGHTING: {
    my @ack_args = qw( July -C5 --color );
    my @results = pipe_into_ack( 't/text/4th-of-july.txt', @ack_args );
    my @escaped_lines = grep { /\e/ } @results;
    is( scalar @escaped_lines, 2, 'Only two lines are highlighted' );
    is( scalar @results, 18, 'Expecting altogether 18 lines back' );
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
    my @target_file = map { File::Next::reslash($_) } qw(
        t/text/boy-named-sue.txt
        t/text/me-and-bobbie-mcgee.txt
        t/text/science-of-myth.txt
    );
    my @expected = split( /\n/, <<"EOF" );
$target_file[0]
1:Well, my daddy left home when I was three
--
5-But the meanest thing that he ever did
6:Was before he left, he went and named me Sue.

$target_file[1]
10-
11:    Freedom's just another word for nothing left to lose
--
25-
26:    Freedom's just another word for nothing left to lose

$target_file[2]
18-Consider the case of the woman whose faith helped her make it through
19:When she was raped and cut up, left for dead in her trunk, her beliefs held true
20-It doesn't matter if it's real or not
21:'cause some things are better left without a doubt
EOF

    my $regex = 'left';
    my @files = qw( t/text/ );
    my @args = ( '--group', '-B1', '--sort-files', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex in multiple files with grouping" );
}

# See https://github.com/petdance/ack2/issues/326 and links there for details.
WITH_COLUMNS_AND_CONTEXT: {
    my @files = qw( t/text/freedom-of-choice.txt );
    my @expected = split( /\n/, <<"EOF" );
$files[0]-2-Nobody ever said life was free
$files[0]-3-Sink, swim, go down with the ship
$files[0]:4:15:But use your freedom of choice
$files[0]-5-
$files[0]-6-I'll say it again in the land of the free
$files[0]:7:11:Use your freedom of choice
$files[0]:8:7:Your freedom of choice
$files[0]-9-
$files[0]-10-In ancient Rome
--
$files[0]-17-He dropped dead
$files[0]-18-
$files[0]:19:2:Freedom of choice
$files[0]-20-Is what you got
$files[0]:21:2:Freedom of choice!
$files[0]-22-
$files[0]-23-Then if you've got it, you don't want it
--
$files[0]-27-
$files[0]-28-I'll say it again in the land of the free
$files[0]:29:11:Use your freedom of choice
$files[0]:30:2:Freedom of choice
$files[0]-31-
$files[0]:32:2:Freedom of choice
$files[0]-33-Is what you got
$files[0]:34:2:Freedom of choice!
$files[0]-35-
$files[0]-36-In ancient Rome
--
$files[0]-43-He dropped dead
$files[0]-44-
$files[0]:45:2:Freedom of choice
$files[0]-46-Is what you got
$files[0]:47:2:Freedom from choice
$files[0]-48-Is what you want
$files[0]-49-
$files[0]:50:10:    -- "Freedom Of Choice", Devo
EOF

    my $regex = 'reedom';
    my @args = ( '--column', '-C2', '-H', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex in file $files[0] with columns and context" );
}
