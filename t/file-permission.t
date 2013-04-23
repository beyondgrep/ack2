#!perl

# Make sure ack can handle files it can't read.

use warnings;
use strict;

use Test::More;

use lib 't';
use Util;

use File::Spec;

use constant NTESTS => 14;

plan skip_all => q{Can't be checked under Win32} if is_win32;
plan skip_all => q{Can't be run as root}         if $> == 0;

plan tests => NTESTS;

prep_environment();

my $program = $0;

# change permissions of this file to unreadable
my $old_mode;
(undef, undef, $old_mode) = stat($program);
my $nchanged = chmod 0000, $program;

SKIP: {
    skip q{Unable to modify test program's permissions}, NTESTS unless $nchanged;

    is( $nchanged, 1, sprintf( 'chmodded %s to 0000 from %o', $program, $old_mode ) );

    # execute a search on this file
    check_with( 'regex', $program );

    # --count takes a different execution path
    check_with( 'regex', '--count', $program, {
        expected_stdout => 1,
    } );

    my($volume,$path) = File::Spec->splitpath($program);

    # Run another test on the directory containing the read only file
    check_with( 'notinthere', $volume . $path );

    # change permissions back
    chmod $old_mode, $program;
    is( $nchanged, 1, sprintf( 'chmodded %s back to %o', $program, $old_mode ) );
}

sub check_with {
    my ( @args ) = @_;

    my $opts = {};
    foreach my $arg ( @args ) {
        if ( ref($arg) eq 'HASH' ) {
            $opts = $arg;
        }
    }
    @args = grep { ref($_) ne 'HASH' } @args;

    my $expected_stdout = $opts->{expected_stdout} || 0;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ($stdout, $stderr) = run_ack_with_stderr( @args );
    is( get_rc(), 1, 'Search normal: exit code ONE for no output for grep compatibility' );
            ## XXX Should be TWO for best grep compatibility since there was an error ...
            ##      but we agreed that wasn't required
    is( scalar @{$stdout}, $expected_stdout, 'Search normal: no normal output' );
    is( scalar @{$stderr}, 1, 'Search normal: one line of stderr output' ) || diag(explain($stderr));
    # don't check for exact text of warning, the message text depends on LC_MESSAGES
    like( $stderr->[0], qr/file-permission[.]t:/, 'Search normal: warning message ok' );

    return;
}
