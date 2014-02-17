#!perl -T

use strict;
use warnings;
use lib 't';

use File::Temp;
use File::Next;
use Test::More tests => 3;
use Util;

prep_environment();


subtest 'Basic reading from files, no switches' => sub {
    plan tests => 2;

    my $target_file = File::Next::reslash( 't/swamp/options.pl' );
    my @expected = split( /\n/, <<"EOF" );
$target_file:2:use strict;
EOF

    my $tempfile = fill_temp_file( qw( t/swamp/options.pl t/swamp/pipe-stress-freaks.F ) );

    ack_lists_match( [ '--files-from=' . $tempfile->filename, 'strict' ], \@expected, 'Looking for strict in multiple files' );

    unlink $tempfile->filename;
};


subtest 'Non-existent file specified' => sub {
    plan tests => 3;

    my @args = qw( strict );
    my ( $stdout, $stderr ) = run_ack_with_stderr( '--files-from=non-existent-file', @args);

    is_empty_array( $stdout, 'No STDOUT for non-existent file' );
    is( scalar @{$stderr}, 1, 'One line of STDERR for non-existent file' );
    like( $stderr->[0], qr/Unable to open non-existent-file:/,
        'Correct warning message for non-existent file' );
};


subtest 'Source file exists, but non-existent files mentioned in the file' => sub {
    plan tests => 4;

    my $tempfile = fill_temp_file( qw( t/swamp/options.pl file-that-isnt-there ) );
    my ( $stdout, $stderr ) = run_ack_with_stderr( '--files-from=' . $tempfile->filename, 'CASE');

    is( scalar @{$stdout}, 1, 'One hit found' );
    like( $stdout->[0], qr/THIS IS ALL IN UPPER CASE/, 'Find the one line in the file' );

    is( scalar @{$stderr}, 1, 'One line of STDERR for non-existent file' );
    like( $stderr->[0], qr/file-that-isnt-there: No such file/, 'Correct warning message for non-existent file' );
};


sub fill_temp_file {
    my @lines = @_;

    my $tempfile = File::Temp->new;
    print {$tempfile} "$_\n" for @lines;
    close $tempfile;

    return $tempfile;
}
