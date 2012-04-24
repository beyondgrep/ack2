#!perl

use strict;
use warnings;

=head1 DESCRIPTION

This tests whether L<ack(1)>'s command line options work as expected.

=cut

use Test::More tests => 51;
use File::Next 0.34; # For the reslash() function

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
    option_in_usage( $arg );
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
    option_in_usage( $arg );
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
    option_in_usage( $arg );
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
    option_in_usage( '--[no]smart-case' );

    like(
        +run_ack( $opt, '-i', 'UpPer CaSe', @files ),
        qr{UPPER CASE},
        qq{-i overrides $opt, forcing ignore case, even when PATTERN has upper}
    );
}

# Invert match
#   this test was changed from using unlike to using like because
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
    option_in_usage( $arg );
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
    option_in_usage( $arg );
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
    option_in_usage( $arg );
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
    option_in_usage( $arg );
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
    option_in_usage( $arg );
}

my $usage;
sub option_in_usage {
    my $opt = shift;

    $usage = qx{ $^X -T $ack --help } unless $usage;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return ok( $usage =~ qr/\Q$opt\E\b/s, "Found $opt in usage" );
}
