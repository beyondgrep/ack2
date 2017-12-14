#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More tests => 2;
use File::Temp;
use Util;

prep_environment();

my $tempfile = File::Temp->new();
print {$tempfile} <<'HERE';



HERE
close $tempfile;

my @results = run_ack('^\s\s+$', $tempfile->filename);

lists_match(\@results, [], '^\s\s+$ should never match a sequence of empty lines');
