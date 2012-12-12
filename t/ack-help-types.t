#!perl

use strict;
use warnings;

use List::Util qw(sum);
use Test::More;

use lib 't';
use Util;

prep_environment();

my @types = (
    perl   => [qw{.pl .pod .pl .t}],
    python => [qw{.py}],
    ruby   => [qw{.rb Rakefile}],
);

my @options = ('--help-types', '--help=types');

plan tests => @options * (sum(map { ref($_) ? scalar(@$_) : 1 } @types) + 1);

foreach my $option ( @options ) {
    my @output = run_ack($option);

    for(my $i = 0; $i < @types; $i += 2) {
        my ( $type, $checks ) = @types[ $i , $i + 1 ];

        my ( $matching_line ) = grep { /--\[no\]$type/ } @output;

        ok $matching_line, "A match should be found for --$type in the output for $option";;

        foreach my $check (@{$checks}) {
            like $matching_line, qr/\Q$check\E/, "Line for --$type in output for $option contains $check";
        }
    }
}
