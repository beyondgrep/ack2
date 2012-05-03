#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More skip_all => 'for now';
use FilterTest;

use_ok 'App::Ack::Filter::Match';

filter_test(
    [ match => '/^.akefile/' ], [
        't/swamp/Makefile',
        't/swamp/Makefile.PL',
        't/swamp/Rakefile',
    ], 'only files matching /^.akefile/ should be matched',
);
