#!perl -T

use warnings;
use strict;

use Test::More tests => 15;

use lib 't';
use Util;

prep_environment();

G_NO_PRINT0: {
    my @expected = qw(
        t/text/amontillado.txt
        t/text/bill-of-rights.txt
        t/text/constitution.txt
        t/text/ozymandias.txt
    );

    my $filename_regex = 'i';
    my @files = qw( t/text/ );
    my @args = ( '-g', $filename_regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, 'Files found with -g and without --print0' );
    is_empty_array( [ grep { /\0/ } @results ], ' ... no null byte in output' );
}

G_PRINT0: {
    my $expected = join( "\0", map { reslash($_) } qw(
        t/text/amontillado.txt
        t/text/bill-of-rights.txt
        t/text/constitution.txt
        t/text/ozymandias.txt
    ) ) . "\0"; # string of filenames separated and concluded with null byte

    my $filename_regex = 'i';
    my @files = qw( t/text );
    my @args = ( '-g', $filename_regex, '--sort-files', '--print0' );
    my @results = run_ack( @args, @files );

    is_deeply( \@results, [$expected], 'Files found with -g and with --print0' );
}

F_PRINT0: {
    my @files = qw( t/text/ );
    my @args = qw( -f --print0 );
    my @results = run_ack( @args, @files );

    # Checking for exact files is fragile, so just see whether we have \0 in output.
    is( scalar @results, 1, 'Only one line of output with -f and --print0' );
    is_nonempty_array( [ grep { /\0/ } @results ], ' ... and null bytes in output' );
}

L_PRINT0: {
    my $regex = 'of';
    my @files = qw( t/text/ );
    my @args = ( '-l', '--print0', $regex );
    my @results = run_ack( @args, @files );

    # Checking for exact files is fragile, so just see whether we have \0 in output.
    is( scalar @results, 1, 'Only one line of output with -l and --print0' );
    is_nonempty_array( [ grep { /\0/ } @results ], ' ... and null bytes in output' );
}

COUNT_PRINT0: {
    my $regex = 'of';
    my @files = qw( t/text/ );
    my @args = ( '--count', '--print0', $regex );
    my @results = run_ack( @args, @files );

    # Checking for exact files is fragile, so just see whether we have \0 in output.
    is( scalar @results, 1, 'Only one line of output with --count and --print0' );
    is_nonempty_array( [ grep { /\0/ } @results ], ' ... and null bytes in output' );
    is_nonempty_array( [ grep { /:\d+/ } @results ], ' ... and ":\d+" in output, so the counting also works' );
}
