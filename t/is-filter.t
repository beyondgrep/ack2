#!perl

use strict;
use warnings;
use lib 't';

use FilterTest;
use Test::More tests => 1;

filter_test(
    [ is => 'Makefile' ], [
        't/swamp/Makefile',
    ], 'only Makefile should be matched'
);
