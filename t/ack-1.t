#!perl -T

use warnings;
use strict;

use Test::More tests => 12;

use lib 't';
use Util;

prep_environment();

SINGLE_TEXT_MATCH: {
    my @expected = (
        'the catacombs of the Montresors.'
    );

    my @files = qw( t/text );
    my @args = qw( Montresor -1 -h --sort-files );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Looking for first instance of Montresor!' );
}


DASH_V: {
    my @expected = (
        '    Only this and nothing more."'
    );

    my @files = qw( t/text/raven.txt );
    my @args = qw( c -1 -h -v );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Looking for first non-match' );
}

DASH_F: {
    my @files = qw( t/swamp );
    my @args = qw( -1 -f );
    my @results = run_ack( @args, @files );
    my $test_path = reslash( 't/swamp/' );

    is( scalar @results, 1, 'Should only get one file back' );
    like( $results[0], qr{^\Q$test_path\E}, 'One of the files from the swamp' );
}


DASH_G: {
    my $regex = '\bMakefile\b';
    my @files = qw( t/ );
    my @args = ( '-1', '-g', $regex );
    my @results = run_ack( @args, @files );
    my $test_path = reslash( 't/swamp/Makefile' );

    is( scalar @results, 1, "Should only get one file back from $regex" );
    like( $results[0], qr{^\Q$test_path\E(?:[.]PL)?$}, 'The one file matches one of the two Makefile files' );
}

DASH_L: {
    my $target   = 'the';
    my @files    = reslash( 't/text' );
    my @args     = ( '-1', '-l', '--sort-files', $target );
    my @results  = run_ack( @args, @files );
    my $expected = reslash( 't/text/amontillado.txt' );

    is_deeply( \@results, [$expected], 'Should only get one matching file back' );
}
