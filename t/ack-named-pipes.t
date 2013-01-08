#!perl

use strict;
use warnings;
use lib 't';

use File::Temp;
use Test::More;
use Util;

sub has_mkfifo {
    system 'which mkfifo >/dev/null 2>/dev/null';
    return $? == 0;
}

sub mkfifo {
    my ( $filename ) = @_;

    system 'mkfifo', $filename;
}

sub touch {
    my ( $filename ) = @_;
    my $fh;
    open $fh, '>>', $filename;
    close $fh;
}

prep_environment();

unless ( has_mkfifo() ) {
    plan skip_all => q{You need the 'mkfifo' command to be able to run this test};
}

plan tests => 2;

local $SIG{'ALRM'} = sub {
    fail 'Timeout';
    exit;
};

alarm 5; # should be plenty of time

my $tempdir = File::Temp->newdir;
mkdir "$tempdir/foo";
mkfifo "$tempdir/foo/test.pipe";
touch "$tempdir/foo/bar.txt";

my @results = run_ack( '-f', $tempdir );

is_deeply \@results, [
    "$tempdir/foo/bar.txt",
];
