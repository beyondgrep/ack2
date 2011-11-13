use strict;
use warnings;
use lib 't';

use App::Ack::Resource::Basic;
use File::Find;
use Util;
use Test::More tests => 3;

use_ok 'App::Ack::Filter::Extension';

my @swamp_files;

find(sub {
    push @swamp_files, $File::Find::name if -f;
}, 't/swamp');

my $filter = eval {
    App::Ack::Filter->create_filter('ext', 'pl', 'pod', 'pm', 't');
};

ok($filter, 'creating an "ext" filter should succeed') or diag($@);

my @matches = map {
    $_->name
} grep {
    $filter->filter($_)
} map {
    App::Ack::Resource::Basic->new($_)
} @swamp_files;

sets_match(\@matches, [
    't/swamp/Makefile.PL',
    't/swamp/blib/ignore.pm',
    't/swamp/blib/ignore.pod',
    't/swamp/options.pl',
    't/swamp/perl-test.t',
    't/swamp/perl.pl',
    't/swamp/perl.pm',
    't/swamp/perl.pod',
], 'only the given extensions should be matched');
