use strict;
use warnings;

use Test::More tests => 5;
use lib 't';
use Util;

prep_environment();

my ( $stdin, $stdout );

# sanity check
( $stdin, $stdout ) = run_ack_with_stderr('--perl', '-f', 't/swamp');
is scalar(@$stdin), 10;
is scalar(@$stdout), 0;

( $stdin, $stdout ) = run_ack_with_stderr('--type-del=perl', '--perl', '-f', 't/swamp');
is scalar(@$stdin), 0;
ok scalar(@$stdout) > 0;
like $stdout->[0], qr/Unknown option: perl/;
