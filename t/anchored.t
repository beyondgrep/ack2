#!/usr/bin/perl

# Make sure beginning-of-line anchor works

use strict;
use warnings;

use Test::More tests => 6;
use lib 't';
use Util;

prep_environment();

FRONT_ANCHORED: {
    my @files = qw( t/text );
    my @args = qw( -h -i ^science );
    my @results = run_ack( @args, @files );

    my @expected = split( /\n/, <<'EOF' );
Science and religion are not mutually exclusive
EOF

    lists_match( \@results, \@expected, 'Looking for front-anchored "science"' );
}

BACK_ANCHORED: {
    my @files = qw( t/text );
    my @args = qw( -h -i done$ );
    my @results = run_ack( @args, @files );

    my @expected = split( /\n/, <<'EOF' );
Through all kinds of weather and everything we done
And if it works, then it gets the job done
EOF

    sets_match( \@results, \@expected, 'Looking for back-anchored "done"' );
}

UNANCHORED: {
    my @files = qw( t/text );
    my @args = qw( -h -i science );
    my @results = run_ack( @args, @files );

    my @expected = split( /\n/, <<'EOF' );
Science and religion are not mutually exclusive
In fact, for better understanding we take the facts of science and apply them
    -- "The Science Of Myth", Screeching Weasel
EOF

    lists_match( \@results, \@expected, 'Looking for unanchored science' );
}

done_testing();
