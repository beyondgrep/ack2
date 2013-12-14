#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More tests => 2;
use Util;

prep_environment();

my @expected = qw(
    t/swamp/MasterPage.master
    t/swamp/Sample.ascx
    t/swamp/Sample.asmx
    t/swamp/sample.aspx
    t/swamp/service.svc
);

my @args    = qw( --aspx -f );
my @results = run_ack(@args);

sets_match( \@results, \@expected, __FILE__ );
