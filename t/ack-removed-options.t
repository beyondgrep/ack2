#!perl -T

use strict;
use warnings;

use Test::More;
use lib 't';
use Util;

prep_environment();

my @options = (qw{
    -a
    --all
    -u
}, ['-G', 'sue']);


plan tests => scalar @options;

foreach my $option (@options) {
    my @args = ref($option) ? @{$option} : ( $option );
    $option  = $option->[0] if ref($option);
    push @args, 'the', 't/text';

    my ( $stdout, $stderr ) = run_ack_with_stderr( @args );

    subtest "options = @args" => sub {
        is_empty_array( $stdout, 'Nothing in stdout' );
        like( $stderr->[0], qr/Option '$option' is not valid in ack 2/, 'Found error message' );
        if ( '-a' eq $option or '--all' eq $option ) {
            like( $stderr->[1], qr/-k/, 'Error mentions -k' );
        }
    };
}
