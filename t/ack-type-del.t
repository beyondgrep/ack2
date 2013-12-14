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

( $stdout, $stderr ) = run_ack_with_stderr('--type-del=perl', '--type-del=perltest', '--perl', '-f', 't/swamp');
is_empty_array( $stdout, 'Nothing in stdout' );
first_line_like( $stderr, qr/Unknown option: perl/ );

( $stdout, $stderr ) = run_ack_with_stderr('--type-del=perl', '--type-del=perltest',  '--type-add=perl:ext:pm', '--perl', '-f', 't/swamp');
is( scalar(@{$stdout}), 1, 'Got one output line' );
is_empty_array( $stderr, 'Nothing in stderr' );

# more sanity checking
$help_types_output = run_ack( '--help-types' );
like( $help_types_output, qr/\Q--[no]perl/ );

$help_types_output = run_ack( '--type-del=perl', '--type-del=perltest', '--help-types' );
unlike( $help_types_output, qr/\Q--[no]perl/ );

DUMP: {
    my @dump_output = run_ack( '--type-del=perl', '--type-del=perltest', '--dump' );
    # discard everything up to the ARGV section
    while(@dump_output && $dump_output[0] ne 'ARGV') {
        shift @dump_output;
    }
    shift @dump_output; # discard ARGV
    shift @dump_output; # discard header
    foreach my $line (@dump_output) {
        $line =~ s/^\s+|\s+$//g;
    }
    lists_match( \@dump_output, ['--type-del=perl', '--type-del=perltest'], '--type-del should show up in --dump output' );
}
