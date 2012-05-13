#!perl

use strict;
use warnings;
use lib 't';

use FilterTest;
use Test::More tests => 1;

use App::Ack::Filter::FirstLineMatch;

filter_test(
    [ firstlinematch => '/^#!.*perl/' ], [
        't/swamp/#emacs-workfile.pl#',
        't/swamp/0',
        't/swamp/Makefile.PL',
        't/swamp/options.pl',
        't/swamp/options.pl.bak',
        't/swamp/perl-test.t',
        't/swamp/perl-without-extension',
        't/swamp/perl.cgi',
        't/swamp/perl.pl',
        't/swamp/perl.pm',
        't/swamp/blib/ignore.pm',
        't/swamp/blib/ignore.pod',
    ], 'only files with "perl" in their first line should be matched'
);
