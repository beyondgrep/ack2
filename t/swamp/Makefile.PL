#!perl -T

use warnings;
use strict;
use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Ack' );
}

diag( "Testing App::Ack $App::Ack::VERSION, Perl $], $^X" );
