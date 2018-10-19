#!perl -T

use strict;
use warnings;

=head1 DESCRIPTION

This tests whether ack's command line options work as expected.

=cut

use Test::More;

# --no-recurse is inconsistent w/--nogroup

plan tests => 66;

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
    my $re = qr/ALL IN UPPER CASE/;

    like(
        +run_ack( $opt, 'all in upper case', @files ),
        $re,
        qq{$opt turn on ignore-case when PATTERN has no upper}
    );
    unlike(
        +run_ack( $opt, 'all in UPPER case', @files ),
        $re,
        qq{$opt does nothing when PATTERN has upper}
    );
    like(
        +run_ack( $opt, '-i', 'AlL In UpPer CaSe', @files ),
        $re,
        qq{-i overrides $opt, forcing ignore case, even when PATTERN has upper}
    );

    # Uppercase characters that aren't really uppercase.
    like(
        +run_ack( $opt, '\Sll\Win\Dup\Bper\N{0,1}cas\N', @files ),
        $re,
        qq{$opt ignores upper in meta-characters}
    );
    like(
        +run_ack( $opt, 'a\x6Cl i\x{006E} \N{U+0075}pper[^\cJ]cas\N{LATIN SMALL LETTER E}', @files ),
        $re,
        qq{$opt ignores upper in character escapes}
    );
    like(
        +run_ack( $opt, '\pLll\p{PosixSpace}in\PNupper\P{PosixDigit}case', @files ),
        $re,
        qq{$opt ignores upper in Unicode properties}
    );
    like(
        +run_ack( $opt, q[a(?<L>l)\k{L}(?<SPACE> )in\k'SPACE'u(?'P'p)\g{P}(?P<E>e)r(?P=SPACE)cas\k{E}], @files ),
        $re,
        qq{$opt ignores upper in named captures}
    );

    # Uppercase characters may have been escaped.
    unlike(
        +run_ack( $opt, '\x41ll in upper case', @files ),
        $re,
        qq{$opt sees upper "A" in hex escape}
    );
    unlike(
        +run_ack( $opt, 'all \x{0049}n upper case', @files ),
        $re,
        qq{$opt sees upper "I" in bracketed hex escape}
    );
    unlike(
        +run_ack( $opt, 'all in \125pper case', @files ),
        $re,
        qq{$opt sees upper "U" in octal escape}
    );
    unlike(
        +run_ack( $opt, 'all in uppe\o{122} case', @files ),
        $re,
        qq{$opt sees upper "R" in octal escape with brackets}
    );
    unlike(
        +run_ack( $opt, 'all in upper \N{U+0043}ase', @files ),
        $re,
        qq{$opt sees upper "CU" in numbered Unicode character}
    );
    unlike(
        +run_ack( $opt, 'all in upper cas\N{LATIN CAPITAL LETTER E}', @files ),
        $re,
        qq{$opt sees upper "E" in named Unicode character}
    );

    # \120 is either back-reference to 120th capture or the letter "P".
    my $start = '(' x 119;
    my $end   = ')' x 120;
    unlike(
        +run_ack( $opt, 'all in u(((p)))\120er case', @files ),
        $re,
        qq{$opt sees upper "P" in octal escape}
    );
    like(
        +run_ack( $opt, "all in u$start(p$end\\120er case", @files ),
        $re,
        qq{$opt sees back-reference to 120th capture}
        );
    unlike(
        +run_ack( $opt, "all in u$start(?:p$end\\120er case", @files ),
        $re,
        qq{$opt sees 119 capture groups - (?:non-capturing)}
        );
    like(
        +run_ack( $opt, "all in u$start(?<NAME>p$end\\120er case", @files ),
        $re,
        qq{$opt sees 120 capture groups - (?<NAME>capturing)}
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

my $expected = reslash( 't/swamp/options.pl' );

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
