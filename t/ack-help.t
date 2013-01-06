use strict;
use warnings;

use Test::More;
use lib 't';
use Util;

{
    my $usage;
    sub option_in_usage {
        my $opt = shift;

        unless( $usage ) {
            ( $usage, undef ) = run_ack_with_stderr( '--help' );
            $usage            = join( "\n", @{$usage} );
        }

        local $Test::Builder::Level = $Test::Builder::Level + 1;
        return ok( $usage =~ qr/\Q$opt\E\b/s, "Found $opt in usage" );
    }
}

my @other_long_opts = qw(
    --passthru
    --output
    --match
    -m
    --max-count
    --with-filename
    --no-filename
    --count
    --column
    --after-context
    --before-context
    --context
    --print0
    --pager
    --nopager
    --[no]heading
    --[no]break
    --group
    --nogroup
    --[no]color
    --[no]colour
    --color-filename
    --color-match
    --color-lineno
    --flush
    --sort-files
    --show-types
    --[no]ignore-dir
    --recurse
    --no-recurse
    --type
    --type-set
    --type-add
    --type-del
    --[no]follow
    --noenv
    --ackrc
    --man
    --thpppt
    --bar
    --dump
    --ignore-ack-defaults
    -s
    --help
    --version
    -i
    --ignore-case
    --[no]smart-case
    -v
    --invert-match
    -w
    --word-regexp
    -Q
    --literal
    -l
    --files-with-matches
    -L
    --files-without-matches
    --line
);

plan tests => scalar(@other_long_opts);

foreach my $option ( @other_long_opts ) {
    option_in_usage( $option );
}
