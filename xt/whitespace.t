#!/usr/bin/perl

use warnings;
use strict;

use Test::More;

# https://metacpan.org/module/Test::Whitespaces
eval {
    require Test::Whitespaces;
    Test::Whitespaces->import({
        dirs   => [ qw( lib bin t xt ) ],
        ignore => [ qr/\.ackrc$/, qr/swamp/, qr/etc/, qr/~$/ ],
    });
    1;
} or plan skip_all => 'Test::Whitespaces required for this test';
