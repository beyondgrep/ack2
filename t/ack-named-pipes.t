#!perl -T

use strict;
use warnings;
use lib 't';

use File::Temp;
use Test::More;
use Util;
use POSIX ();

local $SIG{'ALRM'} = sub {
    fail 'Timeout';
    exit;
};

prep_environment();

my $tempdir = File::Temp->newdir;
mkdir "$tempdir/foo";
my $rc = eval { POSIX::mkfifo( "$tempdir/foo/test.pipe", oct(660) ) };
if ( !$rc ) {
    dir_cleanup( $tempdir );
    plan skip_all => $@ ? $@ : q{I can't run a mkfifo, so cannot run this test.};
}

plan tests => 2;

touch( "$tempdir/foo/bar.txt" );

alarm 5; # Should be plenty of time.

my @results = run_ack( '-f', $tempdir );

is_deeply( \@results, [
    "$tempdir/foo/bar.txt",
], 'Acking should not find the fifo' );

dir_cleanup( $tempdir );

done_testing();

sub dir_cleanup {
    my $tempdir = shift;

    unlink "$tempdir/foo/bar.txt";
    rmdir "$tempdir/foo";
    rmdir $tempdir;

    return;
}


sub touch {
    my $filename = shift;

    my $fh;
    open $fh, '>>', $filename or die "Unable to append to $filename: $!";
    close $fh;

    return;
}
