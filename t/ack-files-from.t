use strict;
use warnings;
use lib 't';

use File::Temp;
use Test::More tests => 5;
use Util;

prep_environment();

NO_SWITCHES_MULTIPLE_FILES: {
    my $tempfile = File::Temp->new;
    my $target_file = File::Next::reslash( 't/swamp/options.pl' );
    my @expected = split( /\n/, <<"EOF" );
$target_file:2:use strict;
EOF

    my @files = qw( t/swamp/options.pl t/swamp/pipe-stress-freaks.F );
    print $tempfile "$_\n" foreach @files;
    close $tempfile;

    my @args = qw( strict );
    my @results = run_ack( '--files-from=' . $tempfile->filename, @args );

    lists_match( \@results, \@expected, 'Looking for strict in multiple files' );
}

NON_EXISTENT_FILE: {
    my @args = qw( strict );
    my ( $stdout, $stderr ) = run_ack_with_stderr( "--files-from=t/foo/non-existent", @args);

    is( scalar @{$stdout}, 0, 'No STDOUT for non-existent file' );
    is( scalar @{$stderr}, 1, 'One line of STDERR for non-existent file' );
    like( $stderr->[0], qr/non-existent: No such file or directory/,
        'Correct warning message for non-existent file' );
}
