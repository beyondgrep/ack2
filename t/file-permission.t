#!perl -T

# Make sure ack can handle files it can't read.

use warnings;
use strict;

use Test::More;

use lib 't';
use Util;

use File::Spec;
use File::Copy;
use File::Temp;

use constant NTESTS => 6;

plan skip_all => q{Can't be checked under Win32} if is_windows();
plan skip_all => q{Can't be run as root}         if $> == 0;

plan tests => NTESTS;

prep_environment();

my $temp_dir = File::Temp::newdir('temp.XXXX', CLEANUP => 1, EXLOCK => 0, TMPDIR => 1);
my $target   = File::Spec->catfile( $temp_dir, 'foo' );

copy( $0, $target ) or die "Can't copy $0 to $target";

# Change permissions of this file to unreadable.
my (undef, undef, $old_mode) = stat($target);
chmod 0000, $target;
my (undef, undef, $new_mode) = stat($target);

sub o { return sprintf '%o', shift }

SKIP: {
    skip q{Unable to modify test program's permissions}, NTESTS if $old_mode eq $new_mode;
    skip q{Program readable despite permission changes}, NTESTS if -r $target;

    isnt( o($new_mode), o($old_mode), "chmodded $target to be unreadable" );

    # Execute a search on this file.
    check_with( 'regex 1', $target );

    # --count takes a different execution path
    check_with( 'regex 2', '--count', $target, {
        expected_stdout => 1,
    } );

    my($volume,$path) = File::Spec->splitpath($target);

    # Run another test on the directory containing the read only file.
    check_with( 'notinthere', $volume . $path );

    # Change permissions back.
    my $rc = chmod $old_mode, $target;
    ok( $rc, "Succeeded chmodding $target to " . o($old_mode) );
    my (undef, undef, $back_mode) = stat($target);
    is( o($back_mode), o($old_mode), "${target}'s are back to what we expect" );
}

done_testing();

sub check_with {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ( @args ) = @_;

    return subtest "check_with( $args[0] )" => sub {
        plan tests => 4;

        my $opts = {};
        foreach my $arg ( @args ) {
            if ( ref($arg) eq 'HASH' ) {
                $opts = $arg;
            }
        }
        @args = grep { ref ne 'HASH' } @args;

        my $expected_stdout = $opts->{expected_stdout} || 0;

        my ($stdout, $stderr) = run_ack_with_stderr( @args );
        is( get_rc(), 1, 'Exit code 1 for no output for grep compatibility' );
        # Should be 2 for best grep compatibility since there was an error but we agreed that wasn't required.

        is( scalar @{$stdout}, $expected_stdout, 'No normal output' ) or diag(explain($stdout));
        is( scalar @{$stderr}, 1, 'One line of stderr output' ) or diag(explain($stderr));
        # Don't check for exact text of warning, the message text depends on LC_MESSAGES
        like( $stderr->[0], qr/\Q$target\E:/, 'Warning message OK' );
    };
}
