#!perl

use strict;
use warnings;

use Test::More;

use lib 't';

use App::Ack::Index;

my @cases = (
    ''           => [],
    'x'          => [],
    'aBc'        => [qw( ab bc )],
    'AbCd'       => [qw( ab bc cd )],
    'a bcd'      => [qw( bc cd )],
    'efghijk-lm' => [qw( ef fg gh hi ij jk lm )],

    # Deduping and ignoring case
    'xxx'        => [qw( xx )],
    'XxXxXxy'    => [qw( xx xy )],
);

plan tests => scalar @cases / 2;


while ( my ($str,$expected) = splice( @cases, 0, 2 ) ) {
    my $actual = App::Ack::Index::ngrams( $str );

    is_deeply( [sort @{$actual}], [sort @{$expected}], $str );
}
