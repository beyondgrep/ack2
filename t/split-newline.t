#!perl -T

use strict;
use warnings;
use lib 't';

use File::Next;
use Util;
use Test::More tests => 12;

prep_environment();

SINGLE_STRING: {
    my @expected = split( /\n/, <<'EOF' );
One day up near Salinas, Lord, I let her slip away
EOF

    my @files = qw( t/text/me-and-bobbie-mcgee.txt );
    my @results = run_ack( "Salinas", @files );

    lists_match( \@results, \@expected, 'A single string pattern' );
}

SINGLE_REGEX: {
    my @expected = split( /\n/, <<'EOF' );
From the Kentucky coal mines to the California sun
Bobbie baby kept me from the cold
EOF

    my @files = qw( t/text/me-and-bobbie-mcgee.txt );
    my @results = run_ack( "co(?:ld|al)", @files );

    lists_match( \@results, \@expected, 'A single pattern' );
}

SINGLE_QUOTED_REGEX: {
    my @expected = split( /\n/, <<'EOF' );
EOF

    my @files = qw( t/text/me-and-bobbie-mcgee.txt );
    my @results = run_ack( "-Q", "co(?:ld|al)", @files );

    lists_match( \@results, \@expected, 'A single quoted pattern (no match)' );
}

MULTIPLE_STRINGS: {
    my @expected = split( /\n/, <<'EOF' );
From the Kentucky coal mines to the California sun
One day up near Salinas, Lord, I let her slip away
EOF

    my @files = qw( t/text/me-and-bobbie-mcgee.txt );
    my @results = run_ack( "Salinas\nKentucky", @files );

    lists_match( \@results, \@expected, 'Multiple strings' );
}

MULTIPLE_REGEXES: {
    my @expected = split( /\n/, <<'EOF' );
I was playin' soft while Bobbie sang the blues
From the Kentucky coal mines to the California sun
Bobbie shared the secrets of my soul
Bobbie baby kept me from the cold
One day up near Salinas, Lord, I let her slip away
EOF

    my @files = qw( t/text/me-and-bobbie-mcgee.txt );
    my @results = run_ack( "co(?:ld|al)\nso(?:ft|ul)\nSalinas", @files );

    lists_match( \@results, \@expected, 'Multiple regexes' );
}

MULTIPLE_QUOTED_REGEXES: {
    my @expected = split( /\n/, <<'EOF' );
One day up near Salinas, Lord, I let her slip away
EOF

    my @files = qw( t/text/me-and-bobbie-mcgee.txt );
    my @results = run_ack( "-Q", "co(?:ld|al)\nso(?:ft|ul)\nSalinas", @files );

    lists_match( \@results, \@expected, 'Multiple quoted regexes' );
}
