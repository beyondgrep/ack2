#!perl -T

use strict;
use warnings;

use lib 't';

use Test::More tests => 3;
use Util;
use App::Ack::ConfigDefault ();

prep_environment();

my @expected = App::Ack::ConfigDefault::options();
my @output   = run_ack( 'ack', '--create-ackrc' );

ok(scalar(grep { $_ eq '--ignore-ack-defaults' } @output), '--ignore-ack-defaults should be present in output');
@output = grep { $_ ne '--ignore-ack-defaults' } @output;

lists_match(\@output, \@expected, 'lines in output should match the default options');
