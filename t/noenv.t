use strict;
use warnings;

use Test::More;

use App::Ack;
use Cwd qw(getcwd realpath);
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
    local @ARGV = ('-f', 'lib/');
    local $ENV{'ACK_OPTIONS'} = '--perl';

    my @sources = App::Ack::retrieve_arg_sources();

    is_deeply [ realpath($sources[-6]), @sources[-5..-1] ], [
        realpath(File::Spec->catfile($tempdir->dirname, '.ackrc')),
        [ '--type-add=perl,ext,pl,t,pm' ],
        'ACK_OPTIONS',
        '--perl',
        'ARGV',
        ['-f', 'lib/'],
    ];
};

do {
    local @ARGV = ('--noenv', '-f', 'lib/');
    local $ENV{'ACK_OPTIONS'} = '--perl';

    my @sources = App::Ack::retrieve_arg_sources();

    is_deeply \@sources, [
        'ARGV',
        ['-f', 'lib/'],
    ];
};

chdir $wd;

done_testing;
