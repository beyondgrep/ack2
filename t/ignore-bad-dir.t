use strict;
use warnings;
use lib 't';

use Test::More tests => 2;
use Util;

IGNORE_DIR_NO_PERMS: {
    mkdir 't/swamp/.ignoreme';
    chmod 000, 't/swamp/.ignoreme';

    my @args  = ( '--ignore-directory=is,.ignoreme', '-l', 'FOO' );
    my @files = 't/swamp';

    my ( $stdout, $stderr ) = run_ack_with_stderr( @args, @files );
    rmdir 't/swamp/.ignoreme';
    is @{$stderr}, 1 or diag(explain($stderr));
    like $stderr->[0], qr!ack: t/swamp/.ignoreme:!;
}
