#!/usr/bin/env perl

# https://github.com/petdance/ack2/issues/276

use strict;
use warnings;

use lib 't';
use Util;
use Test::More;

plan tests => 6;

prep_environment();

my $match_start = "\e[30;43m";
my $match_end   = "\e[0m";

TODO: {
    local $TODO = "input options have not been implemented for Win32 yet" if is_win32;

    my ( $stdout, $stderr ) = pipe_into_ack_with_stderr(\'foobar', '--color',
        '((foo)bar)');

    is scalar(@$stdout), 1, 'Verify that exactly one line is printed to standard output';
    is scalar(@$stderr), 0, 'Verify that no lines are printed to standard error';
    is $stdout->[0], "${match_start}foobar${match_end}", 'Verify that the single match is properly colored';

    ( $stdout, $stderr ) = pipe_into_ack_with_stderr(\'foobar', '--color',
        '((foo)(bar))');

    is scalar(@$stdout), 1, 'Verify that exactly one line is printed to standard output';
    is scalar(@$stderr), 0, 'Verify that no lines are printed to standard error';
    is $stdout->[0], "${match_start}foobar${match_end}", 'Verify that the single match is properly colored';
}
