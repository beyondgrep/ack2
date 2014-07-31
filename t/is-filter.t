#!perl -T

use strict;
use warnings;
use lib 't';

use FilterTest;
use Test::More tests => 1;

use App::Ack::Filter::Is;

filter_test(
    [ is => 'Makefile' ],
    [ 't/swamp/Makefile' ],
    'Only Makefile should be matched'
);
