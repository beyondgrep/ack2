#!/usr/bin/perl

use warnings;
use strict;

# https://metacpan.org/module/Test::Whitespaces
use Test::Whitespaces {
    dirs   => [ qw( lib bin t xt ) ],
    ignore => [ qr/\.ackrc$/, qr/swamp/, qr/etc/, qr/~$/ ],
};
