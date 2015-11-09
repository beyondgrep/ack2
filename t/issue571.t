#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More tests => 2;
use File::Temp;
use Util;

prep_environment();

my $tempfile = File::Temp->new();
print {$tempfile} <<'END_OF_FILE';
fo

oo
END_OF_FILE
close $tempfile;

my @results = run_ack('-l', 'fo\s+oo', $tempfile->filename);

lists_match(\@results, [], '\s+ should never match across line boundaries');
