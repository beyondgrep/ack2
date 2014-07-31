#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More tests => 1;
use Util;

prep_environment();

my @expected = (
    't/swamp/Makefile.PL',
    't/swamp/options-crlf.pl',
    't/swamp/options.pl',
    't/swamp/perl.pl',
);

my @args  = ( '--ignore-ack-defaults', '--type-add=perl:ext:pl', '--perl', '-f' );
my @files = ( 't/swamp' );

ack_sets_match( [ @args, @files ], \@expected, __FILE__ );

done_testing();
