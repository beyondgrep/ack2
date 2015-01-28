#!perl -T

# https://github.com/petdance/ack2/issues/522

use strict;
use warnings;
use Test::More tests => 4;

use lib 't';
use Util;

prep_environment();

my @stdout;

@stdout = run_ack("use strict;\nuse warnings", 't/swamp');

is scalar(@stdout), 0, 'an embedded newline in the search regex should never match anything';

@stdout = run_ack('-A', '1', "use strict;\nuse warnings", 't/swamp');

is scalar(@stdout), 0, 'an embedded newline in the search regex should never match anything, even with context';
