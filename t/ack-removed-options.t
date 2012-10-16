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


plan tests => 2 + (2 * @options);

foreach my $option (@options) {
    my @args = ref($option) ? @$option : ( $option );
    $option  = $option->[0] if ref($option);
    push @args, 'the', 't/text';

    my ( $stdout, $stderr ) = run_ack_with_stderr( @args );

    is scalar(@$stdout), 0;
    like $stderr->[0], qr/Option '$option' is not valid in ack 2/;
    like $stderr->[1], qr/-k/ if '-a' eq $option or '--all' eq $option;
}
