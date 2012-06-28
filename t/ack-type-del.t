use strict;
use warnings;

use Test::More tests => 7;
use lib 't';
use Util;

prep_environment();

my ( $stdout, $stderr );

# sanity check
( $stdout, $stderr ) = run_ack_with_stderr('--perl', '-f', 't/swamp');
is scalar(@$stdout), 10;
is scalar(@$stderr), 0;

( $stdout, $stderr ) = run_ack_with_stderr('--type-del=perl', '--perl', '-f', 't/swamp');
is scalar(@$stdout), 0;
ok scalar(@$stderr) > 0;
like $stderr->[0], qr/Unknown option: perl/;

( $stdin, $stdout ) = run_ack_with_stderr('--type-del=perl', '--perl', '-f', 't/swamp');
is scalar(@$stdin), 0;
ok scalar(@$stdout) > 0;
like $stdout->[0], qr/Unknown option: perl/;
