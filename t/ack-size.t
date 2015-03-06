#!perl -T

use strict;
use warnings;

use Test::More tests => 12;
use lib 't';
use Util;

prep_environment();

my ( $stdout, $stderr );
my $help_types_output;

# sanity check
( $stdout, $stderr ) = run_ack_with_stderr('--perl', '-f', 't/swamp');
is( scalar(@{$stdout}), 11, 'Found initial 11 files' );
is_empty_array( $stderr, 'Nothing in stderr' );

( $stdout, $stderr ) = run_ack_with_stderr('--perl', '--max-file-size=0', '-f', 't/swamp');
is( scalar(@{$stdout}), 11, 'Found initial 11 files (max of 0 has no effect)' );
is_empty_array( $stderr, 'Nothing in stderr' );

( $stdout, $stderr ) = run_ack_with_stderr('--perl', '--max-file-size=100', '-f', 't/swamp');
is( scalar(@{$stdout}), 3, 'Found 3 files <= 100 bytes large' );
is_empty_array( $stderr, 'Nothing in stderr' );

( $stdout, $stderr ) = run_ack_with_stderr('--perl', '--max-file-size=101', '-f', 't/swamp');
is( scalar(@{$stdout}), 3, 'Found 8 files >= 101 bytes large' );
is_empty_array( $stderr, 'Nothing in stderr' );

( $stdout, $stderr ) = run_ack_with_stderr('--perl', '--min-file-size=101', '--max-file-size=150', '-f', 't/swamp');
is( scalar(@{$stdout}), 1, 'Found 1 file where 101 <= size <= 150' );
is_empty_array( $stderr, 'Nothing in stderr' );

( $stdout, $stderr ) = run_ack_with_stderr('--perl', '--max-file-size=100', '--min-file-size=101', '-f', 't/swamp');
is( scalar(@{$stdout}), 0, 'Found no files when max and min conflict' );
is_empty_array( $stderr, 'Nothing in stderr' );

# done testing
