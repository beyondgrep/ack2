use strict;
use warnings;
use lib 't';

use Test::More tests => 2;
use Util;

prep_environment();

my @expected = (
    't/swamp/Makefile.PL',
    't/swamp/options.pl',
    't/swamp/perl.pl',
);

local $TODO = 'broken for now';
# XXX the /dev/null thing isn't portable!
my @args  = ( '--ackrc=/dev/null', '--type-add=perl,ext,pl', '--perl', '-f' );
my @files = ( 't/swamp' );

ack_sets_match( [ @args, @files ], \@expected );

done_testing();
