#!perl -T

# This file validates behaviors of specifying files on the command line.

use warnings;
use strict;

use Test::More tests => 4;

use lib 't';
use Util;
use File::Next ();

prep_environment();

my @source_files = qw(
    t/swamp/options-crlf.pl
    t/swamp/options.pl
    t/swamp/options.pl.bak
);

$_ = File::Next::reslash($_) for @source_files;

JUST_THE_DIR: {
    my @expected = split( /\n/, <<"EOF" );
$source_files[0]:19:notawordhere
$source_files[1]:19:notawordhere
EOF

    my @files = qw( t/swamp );
    my @args = qw( notaword );

    ack_sets_match( [ @args, @files ], \@expected, q{One hit for specifying a dir} );
}

# Even a .bak file gets searched if you specify it on the command line.
SPECIFYING_A_BAK_FILE: {
    my @expected = split( /\n/, <<"EOF" );
$source_files[1]:19:notawordhere
$source_files[2]:19:notawordhere
EOF

    my @files = qw( t/swamp/options.pl t/swamp/options.pl.bak );
    my @args = qw( notaword );

    ack_sets_match( [ @args, @files ], \@expected, q{Two hits for specifying the file} );
}

FILE_NOT_THERE: {
    my $file = File::Next::reslash( 't/swamp/perl.pod' );

    my @expected_stderr;

    # I don't care for this, but it's the least of the evils I could think of
    if ( $ENV{'ACK_TEST_STANDALONE'} ) {
        @expected_stderr = split( /\n/, <<'EOF' );
ack-standalone: non-existent-file.txt: No such file or directory
EOF
    }
    else {
        @expected_stderr = split( /\n/, <<'EOF' );
ack: non-existent-file.txt: No such file or directory
EOF
    }

    my @expected_stdout = split( /\n/, <<"EOF" );
${file}:3:=head2 There's important stuff in here!
EOF

    my @files = ( 'non-existent-file.txt', $file );
    my @args = qw( head2 );
    my ($stdout, $stderr) = run_ack_with_stderr( @args, @files );

    lists_match( $stderr, \@expected_stderr, q{Error if there's no file} );
    lists_match( $stdout, \@expected_stdout, 'Find the one file that has a hit' );
}
