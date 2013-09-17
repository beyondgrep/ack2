use strict;
use warnings;

use Test::More tests => 13;
use lib 't';
use Util;

prep_environment();

my ( $stdout, $stderr );
my $help_types_output;

# sanity check
( $stdout, $stderr ) = run_ack_with_stderr('--perl', '-f', 't/swamp');
is( scalar(@{$stdout}), 11 );
is( scalar(@{$stderr}), 0 );

( $stdout, $stderr ) = run_ack_with_stderr('--type-del=perl', '--perl', '-f', 't/swamp');
is( scalar(@{$stdout}), 0 );
ok( scalar(@{$stderr}) > 0 );
like $stderr->[0], qr/Unknown option: perl/;

( $stdout, $stderr ) = run_ack_with_stderr('--type-del=perl', '--type-add=perl:ext:pm', '--perl', '-f', 't/swamp');
is( scalar(@{$stdout}), 1 );
is( scalar(@{$stderr}), 0 );

# more sanity checking
$help_types_output = run_ack( '--help-types' );
like( $help_types_output, qr/\Q--[no]perl/ );

$help_types_output = run_ack( '--type-del=perl', '--help-types' );
unlike( $help_types_output, qr/\Q--[no]perl/ );

DUMP: {
    my @dump_output = run_ack( '--type-del=perl', '--dump' );
    # discard everything up to the ARGV section
    while(@dump_output && $dump_output[0] ne 'ARGV') {
        shift @dump_output;
    }
    shift @dump_output; # discard ARGV
    shift @dump_output; # discard header
    foreach my $line (@dump_output) {
        $line =~ s/^\s+|\s+$//g;
    }
    lists_match( \@dump_output, ['--type-del=perl'], '--type-del should show up in --dump output' );
}
