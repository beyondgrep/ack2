#!perl -T

use strict;
use warnings;
use lib 't';

use File::Next;
use Util;
use Test::More tests => 12;

prep_environment();

NO_SWITCHES_ONE_FILE: {
    my @expected = split( /\n/, <<'EOF' );
use strict;
EOF

    my @files = qw( t/swamp/options.pl );
    my @args = qw( strict );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Looking for strict in one file' );
}


NO_SWITCHES_MULTIPLE_FILES: {
    my $target_file = File::Next::reslash( 't/swamp/options.pl' );
    my @expected = split( /\n/, <<"EOF" );
$target_file:2:use strict;
EOF

    my @files = qw( t/swamp/options.pl t/swamp/pipe-stress-freaks.F );
    my @args = qw( strict );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Looking for strict in multiple files' );
}


WITH_SWITCHES_ONE_FILE: {
    my $target_file = File::Next::reslash( 't/swamp/options.pl' );
    for my $opt ( qw( -H --with-filename ) ) {
        my @expected = split( /\n/, <<"EOF" );
$target_file:2:use strict;
EOF

        my @files = qw( t/swamp/options.pl );
        my @args = ( $opt, qw( strict ) );
        my @results = run_ack( @args, @files );

        lists_match( \@results, \@expected, "Looking for strict in one file with $opt" );
    }
}


WITH_SWITCHES_MULTIPLE_FILES: {
    for my $opt ( qw( -h --no-filename ) ) {
        my @expected = split( /\n/, <<"EOF" );
use strict;
EOF

        my @files = qw( t/swamp/options.pl t/swamp/crystallography-weenies.f );
        my @args = ( $opt, qw( strict ) );
        my @results = run_ack( @args, @files );

        lists_match( \@results, \@expected, "Looking for strict in multiple files with $opt" );
    }
}
