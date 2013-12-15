#! /usr/bin/perl
#---------------------------------------------------------------------
# Run tests for ack
#
# Windows makes it hard to temporarily set environment variables, and
# has horrible quoting rules, so what should be a one-liner gets its
# own script.
#---------------------------------------------------------------------

use ExtUtils::Command::MM;

$ENV{PERL_DL_NONLAZY} = 1;
$ENV{ACK_TEST_STANDALONE} = shift;

# Make sure the tests' standard input is *never* a pipe (messes with ack's filter detection).
open STDIN, '<', '/dev/null';

printf("Running tests on %s\n",
       $ENV{ACK_TEST_STANDALONE} ? 'ack-standalone' : 'blib/script/ack');
test_harness(shift, shift, shift);
