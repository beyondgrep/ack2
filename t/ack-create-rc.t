use strict;
use warnings;

use lib 't';

use Test::More tests => 2;
use Util;

prep_environment();

my @expected = App::Ack::ConfigDefault::options();
my @output   = run_ack( 'ack', '--create-ackrc' );

lists_match(\@output, \@expected, 'lines in output should match the default options');
