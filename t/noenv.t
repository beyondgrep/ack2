use strict;
use warnings;

use Test::More;

use App::Ack;
use Cwd qw(getcwd);
use File::Spec;
use File::Temp;

my $wd      = getcwd;
my $tempdir = File::Temp->newdir;

chdir $tempdir->dirname;

my $fh;
open $fh, '>', '.ackrc';
print $fh <<ACKRC;
--type-add=perl,ext,pl,t,pm
ACKRC
close $fh;

do {
    local @ARGV;

    my @sources = App::Ack::retrieve_arg_sources();

    is_deeply [ @sources[-4..-1] ], [
        File::Spec->catfile($tempdir->dirname, '.ackrc'),
        [ '--type-add=perl,ext,pl,t,pm' ],
        'ARGV',
        [],
    ];
};

do {
    local @ARGV = ('--noenv');

    my @sources = App::Ack::retrieve_arg_sources();

    is_deeply \@sources, [
        'ARGV',
        [],
    ];
};

chdir $wd;

done_testing;
