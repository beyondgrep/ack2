#!perl -T

use strict;
use warnings;

=head1 DESCRIPTION

This tests whether ack's command line options work as expected.

=cut

use Test::More;
use File::Next (); # For the reslash() function

# --no-recurse is inconsistent w/--nogroup

plan tests => 38;

use lib 't';
use Util;

prep_environment();

my $swamp = 't/swamp';
my $ack   = './ack';

# Help
for my $arg ( qw( --help ) ) {
    my @args = ($arg);
    my $results = run_ack( @args );
    like(
        $results,
        qr{ ^Usage: .* Example: }xs,
        qq{$arg output is correct}
    );
}

# Version
for my $arg ( qw( --version ) ) {
    my @args = ($arg);
    my $results = run_ack( @args );
    like(
        $results,
        qr{ ^ack .* Copyright }xs,
        qq{$arg output is correct}
    );
}

# Ignore case
for my $arg ( qw( -i --ignore-case ) ) {
    my @args    = ( $arg, 'upper case' );
    my @files   = ( 't/swamp/options.pl' );
    my $results = run_ack( @args, @files );
    like(
        $results,
        qr{UPPER CASE},
        qq{$arg works correctly for ascii}
    );
}

SMART_CASE: {
    my @files = 't/swamp/options.pl';
    my $opt = '--smart-case';
    like(
        +run_ack( $opt, 'upper case', @files ),
        qr{UPPER CASE},
        qq{$opt turn on ignore-case when PATTERN has no upper}
    );
    unlike(
        +run_ack( $opt, 'Upper case', @files ),
        qr{UPPER CASE},
        qq{$opt does nothing when PATTERN has upper}
    );

    like(
        +run_ack( $opt, '-i', 'UpPer CaSe', @files ),
        qr{UPPER CASE},
        qq{-i overrides $opt, forcing ignore case, even when PATTERN has upper}
    );
}

# Invert match
#   This test was changed from using unlike to using like because
#   old versions of Test::More::unlike (before 0.48_2) cannot
#   work with multiline output (which ack produces in this case).
for my $arg ( qw( -v --invert-match ) ) {
    my @args    = ( $arg, 'use warnings' );
    my @files   = qw( t/swamp/options.pl );
    my $results = run_ack( @args, @files );
    like(
        $results,
        qr{use strict;\n\n=head1 NAME}, # no 'use warnings' in between here
        qq{$arg works correctly}
    );
}

# Word regexp
for my $arg ( qw( -w --word-regexp ) ) {
    my @args    = ( $arg, 'word' );
    my @files   = qw( t/swamp/options.pl );
    my $results = run_ack( @args, @files );
    like(
        $results,
        qr{ word },
        qq{$arg ignores non-words}
    );
    unlike(
        $results,
        qr{notaword},
        qq{$arg ignores non-words}
    );
}

# Literal
for my $arg ( qw( -Q --literal ) ) {
    my @args    = ( $arg, '[abc]' );
    my @files   = qw( t/swamp/options.pl );
    my $results = run_ack( @args, @files );
    like(
        $results,
        qr{\Q[abc]\E},
        qq{$arg matches a literal string}
    );
}

my $expected = File::Next::reslash( 't/swamp/options.pl' );

# Files with matches
for my $arg ( qw( -l --files-with-matches ) ) {
    my @args    = ( $arg, 'use strict' );
    my @files   = qw( t/swamp/options.pl );
    my $results = run_ack( @args, @files );
    like(
        $results,
        qr{\Q$expected},
        qq{$arg prints matching files}
    );
}

# Files without match
for my $arg ( qw( -L --files-without-matches ) ) {
    my @args    = ( $arg, 'use snorgledork' );
    my @files   = qw( t/swamp/options.pl );
    my $results = run_ack( @args, @files );
    like(
        $results,
        qr{\Q$expected},
        qq{$arg prints matching files}
    );
}

LINE: {
    my @files = 't/swamp/options.pl';
    my $opt   = '--line=1';
    my @lines = run_ack( $opt, @files );

    is_deeply( \@lines, ['#!/usr/bin/env perl'], 'Only one matching line should be a shebang' );
}
