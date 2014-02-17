#!perl -T

use strict;
use warnings;
use lib 't';
use Test::More tests => 1;
use Util;

prep_environment();

ack_sets_match( [ '--lua', '-f', 't/swamp' ], [ 't/swamp/lua-shebang-test' ],
    'Lua files should be detected by shebang' );
