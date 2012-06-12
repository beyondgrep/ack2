#!/usr/bin/perl

# Make sure beginning-of-line anchor works

use strict;
use warnings;

use Test::More tests => 6;
use lib 't';
use Util;

prep_environment();

my @files = qw( t/text );

FRONT_ANCHORED: {
    my @args  = qw( -h -i ^science );

    my @expected = split( /\n/, <<'EOF' );
Science and religion are not mutually exclusive
EOF

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for front-anchored "science"' );
}

BACK_ANCHORED: {
    my @args  = qw( -h -i done$ );

    my @expected = split( /\n/, <<'EOF' );
Through all kinds of weather and everything we done
And if it works, then it gets the job done
EOF

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for back-anchored "done"' );
}

UNANCHORED: {
    my @args  = qw( -h -i science );

    my @expected = split( /\n/, <<'EOF' );
Science and religion are not mutually exclusive
In fact, for better understanding we take the facts of science and apply them
    -- "The Science Of Myth", Screeching Weasel
EOF

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for unanchored science' );
}

done_testing();
