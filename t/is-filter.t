#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More skip_all => 'for now';
use FilterTest;

use_ok 'App::Ack::Filter::Is';

filter_test(
    [ is => 'Makefile' ], [
        't/swamp/Makefile',
    ], 'only Makefile should be matched'
);
