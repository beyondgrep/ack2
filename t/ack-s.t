#!perl

use strict;
use warnings;

use Test::More tests => 3;
use lib 't';
use Util;

prep_environment();

WITHOUT_S: {
    my @files = qw( non-existent-file.txt );
    my @args  = qw( search-term );
    my (undef, $stderr) = run_ack_with_stderr( @args, @files );

    is( @{$stderr}, 1 );
    like( $stderr->[0], qr/\Qnon-existent-file.txt: No such file or directory\E/, q{Error if there's no file} );
}

WITH_S: {
    my @files = qw( non-existent-file.txt );
    my @args  = qw( search-term -s );
    my (undef, $stderr) = run_ack_with_stderr( @args, @files );

    is_empty_array( $stderr );
}
