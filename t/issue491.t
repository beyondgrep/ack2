#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More tests => 4;
use File::Temp;
use Util;

prep_environment();

my $dir = File::Temp->newdir;
my $wd  = getcwd_clean();
chdir $dir->dirname;
write_file('space-newline.txt', " \n");
write_file('space-newline-newline.txt', " \n\n");

my @results = run_ack('-l', ' $', 'space-newline.txt', 'space-newline-newline.txt');

sets_match(\@results, [
    'space-newline.txt',
    'space-newline-newline.txt',
], 'both files should be in -l output');

@results = run_ack('-c', ' $', 'space-newline.txt', 'space-newline-newline.txt');

sets_match(\@results, [
    'space-newline.txt:1',
    'space-newline-newline.txt:1',
], 'both files should be in -c output with correct counts');

chdir $wd;
