#!perl

use warnings;
use strict;

use Test::More tests => 20;
use File::Next 0.34; # for reslash function

use lib 't';
use Util;

prep_environment();

# checks also beginning of file
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
    my @args = ( '-B2', $regex );

    ack_lists_match( [ @args, @files ], \@expected, "Looking for $regex - before with line numbers" );
}

# checks also end of file
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

# context defaults to 2
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

# -1 must not stop the ending context from displaying
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

# highlighting works with context
HIGHLIGHTING: {
    my @ack_args = qw( July -C5 --color );
    my @results = pipe_into_ack( 't/text/4th-of-july.txt', @ack_args );
    my @escaped_lines = grep { /\e/ } @results;
    is( scalar @escaped_lines, 2, 'Only two lines are highlighted' );
    is( scalar @results, 18, 'Expecting altogether 18 lines back' );
}

# grouping works with context (single file)
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


# grouping works with context and multiple files
# i.e. a separator line between different matches in the same file and no separator between files
GROUPING_MULTIPLE_FILES: {
    my @target_file = (
        File::Next::reslash( 't/text/boy-named-sue.txt' ),
        File::Next::reslash( 't/text/me-and-bobbie-mcgee.txt' ),
        File::Next::reslash( 't/text/science-of-myth.txt' ),
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

# ack -o disables context
WITH_O: {
    my @files = qw( t/text/boy-named-sue.txt );
    my @args = qw( the\\s+\\S+ -o -C2 );
    my @expected = split( /\n/, <<'EOF' );
        the meanest
        the moon
        the honky-tonks
        the dirty,
        the eyes
        the wall
        the street
        the mud
        the blood
        the beer.
        the name
        the right
        the gravel
        the spit
        the son-of-a-bitch
EOF
    s/^\s+// for @expected;

    ack_lists_match( [ @args, @files ], \@expected, 'Context is disabled with -o' );
}
