use strict;
use warnings;

use Cwd qw(getcwd);
use File::Temp;
use Test::More tests => 12;
use lib 't';
use Util;

prep_environment();

my $wd = getcwd();

my $tempdir = File::Temp->newdir;

chdir $tempdir->dirname;
write_file '.ackrc', "--frobnicate\n";

my $output;

$output = run_ack( '--env', '--help' );
like $output, qr/Usage: ack/;

{
    local $TODO = '--help-types is painful to work with';

    $output = run_ack( '--env', '--help-types' );
    like $output, qr/Usage: ack/;
}

$output = run_ack( '--env', '--man' );
like $output, qr/ACK(?:-STANDALONE)?\Q(1)\E/;

$output = run_ack( '--env', '--thpppt' );
like $output, qr/ack --thpppt/;

$output = run_ack( '--env', '--bar' );
like $output, qr/It's a grep/;

$output = run_ack( '--env', '--version' );
like $output, qr/ack 2[.]\d+/;

chdir $wd;
