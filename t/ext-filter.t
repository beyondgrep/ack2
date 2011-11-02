use strict;
use warnings;
use lib 't';

use MockResource;
use Test::More tests => 3;

use_ok 'App::Ack::Filter::Extension';

my @test_files = (
    'test.pl',
    'test.pod',
    't/filter.t',
    'foo',
    'testpl',
    'test.txt',
    'test.pl.txt',
);

my $filter = eval {
    App::Ack::Filter->create_filter('ext', 'pl', 'pod', 't');
};

ok $filter, 'creating an "ext" filter should succeed' or diag($@);

my @matches = map {
    $_->name
} grep {
    $filter->filter($_)
} map {
    MockResource->new($_)
} @test_files;

is_deeply \@matches, [
    'test.pl',
    'test.pod',
    't/filter.t',
], 'only the given extensions should be matched';
