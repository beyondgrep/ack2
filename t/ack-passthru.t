#!perl -T

use warnings;
use strict;

use Test::More tests => 6;
use File::Next ();

use lib 't';
use Util;

prep_environment();

my @full_lyrics = <DATA>;
chomp @full_lyrics;

NORMAL: {
    my @expected = split( /\n/, <<'EOF' );
Painting a picture of you
And I'm looking at you
Looking at me, telling me you love me,
And you're happy to be with me on the 4th of July
If you ain't got no one
To keep you hanging on
And there you were
Like a queen in your nightgown
And I'm singing to you
And I'm lookin' for you
EOF

    my @files = qw( t/text/4th-of-july.txt );
    my @args = qw( you );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, q{I'm lookin' for you} );
}

DASH_C: {
    my @expected = @full_lyrics;

    my @files = qw( t/text/4th-of-july.txt );
    my @args = qw( you --passthru );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, q{Still lookin' for you, in passthru mode} );
}

SKIP: {
    skip 'Input options have not been implemented for Win32 yet', 2 if is_windows();

    my @ack_args = qw( July --passthru --color );
    my @results = pipe_into_ack( 't/text/4th-of-july.txt', @ack_args );

    is( scalar @results, scalar @full_lyrics, 'Got all the lines back' );

    my @escaped_lines = grep { /\e/ } @results;
    is( scalar @escaped_lines, 2, 'Only two lines are highlighted' );
}

__DATA__
Alone with the morning burning red
On the canvas in my head
Painting a picture of you
And me driving across country
In a dusty old RV
Just the road and its majesty
And I'm looking at you
With the world in the rear view

Chorus:
You were pretty as can be, sitting in the front seat
Looking at me, telling me you love me,
And you're happy to be with me on the 4th of July
We sang "Stranglehold" to the stereo
Couldn't take no more of that rock and roll
So we put on a little George Jones and just sang along

Those white lines
Get drawn into the sun
If you ain't got no one
To keep you hanging on
And there you were
Like a queen in your nightgown
Riding shotgun from town to town
Staking a claim on the world we found
And I'm singing to you
You're singing to me
You were out of the blue to a boy like me

Chorus

And I'm lookin' for you
In the silence that we shared

Chorus

    -- "4th of July", Shooter Jennings
