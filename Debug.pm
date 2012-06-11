## no critic (RequireUseStrict)
package App::Ack::Debug;

## use critic (RequireUseStrict)
use strict;
use warnings;
use parent 'Exporter';

our @EXPORT = qw(debug_print);

my $tty;
open $tty, '>', '/dev/tty';

sub debug_print {
    my ( @args ) = @_;

    local $\ = "\n";

    print { $tty } @args;
}

1;
