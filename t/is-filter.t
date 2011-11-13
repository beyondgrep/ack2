use strict;
use warnings;
use lib 't';

use FilterTest;
use Test::More tests => 2;

use_ok 'App::Ack::Filter::Is';

filter_test(
    [ is => 'Makefile' ], [
        't/swamp/Makefile',
    ], 'only Makefile should be matched'
);
