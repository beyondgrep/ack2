use strict;
use warnings;
use lib 't';

use App::Ack::Resource::Basic;
use File::Find;
use Util;
use Test::More tests => 3;

use_ok 'App::Ack::Filter::FirstLineMatch';

my @swamp_files;

find(sub {
    push @swamp_files, $File::Find::name if -f;
}, 't/swamp');

my $filter = eval {
    App::Ack::Filter->create_filter('firstlinematch', '/perl');
};

ok( $filter, 'create a "firstlinematch" filter should succeed') or diag($@);

my @matches = map {
    $_->name
} grep {
    $filter->filter($_)
} map {
    App::Ack::Resource::Basic->new($_);
} @swamp_files;

sets_match( \@matches, [
    't/swamp/#emacs-workfile.pl#',
    't/swamp/0',
    't/swamp/Makefile.PL',
    't/swamp/c-header.h',
    't/swamp/options.pl',
    't/swamp/options.pl.bak',
    't/swamp/perl-test.t',
    't/swamp/perl-without-extension',
    't/swamp/perl.cgi',
    't/swamp/perl.pl',
    't/swamp/perl.pm',
    't/swamp/blib/ignore.pm',
    't/swamp/blib/ignore.pod',
], 'only files where the first line contains "perl" should be matched' );
