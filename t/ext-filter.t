use strict;
use warnings;

use Test::More tests => 2;

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

ok $filter, 'creating an "ext" filter should succeed';

my @matches = $filter->filter(@test_files);

is_deeply @matches, [
    'test.pl',
    'test.pod',
    't/filter.t',
];
