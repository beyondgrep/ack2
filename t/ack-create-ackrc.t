#!perl -T

use strict;
use warnings;

use lib 't';

use Test::More tests => 5;
use Util;
use App::Ack ();
use App::Ack::ConfigDefault ();

prep_environment();

my @commented   = App::Ack::ConfigDefault::options();
my @uncommented = App::Ack::ConfigDefault::options_clean();

cmp_ok( scalar @commented, '>', scalar @uncommented, 'There are fewer lines in the uncommented options.' );

my @output      = run_ack( 'ack', '--create-ackrc' );

ok(scalar(grep { $_ eq '--ignore-ack-defaults' } @output), '--ignore-ack-defaults should be present in output');
@output = grep { $_ ne '--ignore-ack-defaults' } @output;

lists_match(\@output, \@commented, 'lines in output should match the default options');

my @versions = grep { /\Qack version $App::Ack::VERSION/ } @commented;
is( scalar @versions, 1, 'Got exactly one version line' );
