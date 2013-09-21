#!perl

# Make sure ack can handle files it can't read.

use warnings;
use strict;

use Test::More;

use lib 't';
use Util;

use File::Spec;

use constant NTESTS => 14;

plan skip_all => q{Can't be checked under Win32} if is_windows();
plan skip_all => q{Can't be run as root}         if $> == 0;

plan tests => NTESTS;

prep_environment();

my $program = $0;

# Change permissions of this file to unreadable.
my (undef, undef, $old_mode) = stat($program);
chmod 0000, $program;
my (undef, undef, $new_mode) = stat($program);

sub o { return sprintf '%o', shift }

SKIP: {
    skip q{Unable to modify test program's permissions}, NTESTS if $old_mode eq $new_mode;
    skip q{Program readable despite permission changes}, NTESTS if -r $program;

    isnt( o($new_mode), o($old_mode), "chmodded $program to be unreadable" );

    # Execute a search on this file.
    check_with( 'regex', $program );

    # --count takes a different execution path
    check_with( 'regex', '--count', $program, {
        expected_stdout => 1,
    } );

    my($volume,$path) = File::Spec->splitpath($program);

    # Run another test on the directory containing the read only file.
    check_with( 'notinthere', $volume . $path );

    # Change permissions back.
    chmod $old_mode, $program;
    my (undef, undef, $back_mode) = stat($program);
    is( o($back_mode), o($old_mode), "chmodded $program back to original perms" );
}

sub check_with {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ( @args ) = @_;

    my $opts = {};
    foreach my $arg ( @args ) {
        if ( ref($arg) eq 'HASH' ) {
            $opts = $arg;
        }
    }
    @args = grep { ref($_) ne 'HASH' } @args;

    my $expected_stdout = $opts->{expected_stdout} || 0;

    my ($stdout, $stderr) = run_ack_with_stderr( @args );
    is( get_rc(), 1, 'Search normal: exit code ONE for no output for grep compatibility' );
            ## XXX Should be TWO for best grep compatibility since there was an error ...
            ##      but we agreed that wasn't required
    is( scalar @{$stdout}, $expected_stdout, 'Search normal: no normal output' ) || diag(explain($stdout));
    is( scalar @{$stderr}, 1, 'Search normal: one line of stderr output' ) || diag(explain($stderr));
    # Don't check for exact text of warning, the message text depends on LC_MESSAGES
    like( $stderr->[0], qr/file-permission[.]t:/, 'Search normal: warning message ok' );

    return;
}
