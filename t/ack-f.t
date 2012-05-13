#!perl

use warnings;
use strict;

use Test::More tests => 5;

use lib 't';
use Util;

prep_environment();

DEFAULT_DIR_EXCLUSIONS: {
    my @expected = ( qw(
        t/swamp/0
        t/swamp/c-header.h
        t/swamp/c-source.c
        t/swamp/crystallography-weenies.f
        t/swamp/example.R
        t/swamp/file.bar
        t/swamp/file.foo
        t/swamp/groceries/another_subdir/fruit
        t/swamp/groceries/another_subdir/junk
        t/swamp/groceries/another_subdir/meat
        t/swamp/groceries/fruit
        t/swamp/groceries/junk
        t/swamp/groceries/meat
        t/swamp/groceries/subdir/fruit
        t/swamp/groceries/subdir/junk
        t/swamp/groceries/subdir/meat
        t/swamp/html.htm
        t/swamp/html.html
        t/swamp/incomplete-last-line.txt
        t/swamp/javascript.js
        t/swamp/Makefile
        t/swamp/Makefile.PL
        t/swamp/notaMakefile
        t/swamp/notaRakefile
        t/swamp/options.pl
        t/swamp/parrot.pir
        t/swamp/perl-test.t
        t/swamp/perl-without-extension
        t/swamp/perl.cgi
        t/swamp/perl.pl
        t/swamp/perl.pm
        t/swamp/perl.pod
        t/swamp/pipe-stress-freaks.F
        t/swamp/Rakefile
        t/swamp/sample.rake
        t/swamp/stuff.cmake
        t/swamp/CMakeLists.txt
        ),
        't/swamp/not-an-#emacs-workfile#',
    );

    my @args = qw( --ackrc=./ackrc -f t/swamp );
    my @results = run_ack( @args );

    sets_match( \@results, \@expected );
}

COMBINED_FILTERS: {
    my @expected = qw(
        t/swamp/0
        t/swamp/perl.pm
        t/swamp/Rakefile
        t/swamp/options.pl
        t/swamp/perl-without-extension
        t/swamp/perl.cgi
        t/swamp/Makefile.PL
        t/swamp/perl-test.t
        t/swamp/perl.pl
        t/swamp/perl.pod
    );

    my @args = qw( --ackrc=./ackrc -f t/swamp --perl --rake );
    my @results = run_ack ( @args );

    sets_match( \@results, \@expected );
}

subtest '-f with a regex is an error' => sub {
    # specifying both -f and a regex should result in an error
    my @files = qw( t/text );
    my @args = qw( -f --match Sue );

    my ($stdout, $stderr) = run_ack_with_stderr( @args, @files );
    isnt( get_rc(), 0, 'Specifying both -f and --match must lead to an error RC' );
    is( scalar @{$stdout}, 0, 'No normal output' );
    is( scalar @{$stderr}, 1, 'One line of stderr output' );
    like( $stderr->[0], qr/\Q(Sue)/, 'Error message must contain "(Sue)"' );
}
