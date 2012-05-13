#!perl

use strict;
use warnings;
use lib 't';

use FilterTest;
use Test::More tests => 1;

use App::Ack::Filter::Extension;

filter_test(
    [ ext => qw/pl pod pm t/ ], [
        't/swamp/Makefile.PL',
        't/swamp/blib/ignore.pm',
        't/swamp/blib/ignore.pod',
        't/swamp/options.pl',
        't/swamp/perl-test.t',
        't/swamp/perl.pl',
        't/swamp/perl.pm',
        't/swamp/perl.pod',
    ], 'only the given extensions should be matched'
);
