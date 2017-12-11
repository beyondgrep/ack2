#!perl -T

use warnings;
use strict;

use Test::More tests => 4;

use lib 't';
use Util;

prep_environment();

my $raven = reslash( 't/text/raven.txt' );
my @base_args = qw( nevermore -w -i --with-filename --noenv );

WITH_COLUMNS: {
    my @expected = line_split( <<'HERE' );
55:23:    Quoth the Raven, "Nevermore."
62:24:    With such name as "Nevermore."
69:26:    Then the bird said, "Nevermore."
76:18:    Of 'Never -- nevermore.'
83:24:    Meant in croaking "Nevermore."
90:26:    She shall press, ah, nevermore!
97:23:    Quoth the Raven, "Nevermore."
104:23:    Quoth the Raven, "Nevermore."
111:23:    Quoth the Raven, "Nevermore."
118:23:    Quoth the Raven, "Nevermore."
125:22:    Shall be lifted--nevermore!
HERE
    @expected = map { "${raven}:$_" } @expected;

    my @files = ( $raven );
    my @args = ( @base_args, '--column' );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Checking column numbers' );
}


WITHOUT_COLUMNS: {
    my @expected = line_split( <<'HERE' );
55:    Quoth the Raven, "Nevermore."
62:    With such name as "Nevermore."
69:    Then the bird said, "Nevermore."
76:    Of 'Never -- nevermore.'
83:    Meant in croaking "Nevermore."
90:    She shall press, ah, nevermore!
97:    Quoth the Raven, "Nevermore."
104:    Quoth the Raven, "Nevermore."
111:    Quoth the Raven, "Nevermore."
118:    Quoth the Raven, "Nevermore."
125:    Shall be lifted--nevermore!
HERE
    @expected = map { "${raven}:$_" } @expected;

    my @files = ( $raven );
    my @args = ( @base_args, '--no-column' );
    my @results = run_ack( @args, @files );

    lists_match( \@results, \@expected, 'Checking without column numbers' );
}
