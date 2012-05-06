use strict;
use warnings;
use lib 't';

use Test::More;
use Util;

my @expected = ( '#!/usr/bin/env perl' );

prep_environment();

system 'bash', '-c', 'exit';
if ( $? ) {
    plan skip_all => 'You need bash to run this test';
    exit;
}

plan tests => 1;

my ( $read, $write );

pipe( $read, $write );

my $pid = fork();

my @output;

if ( $pid ) {
    close $write;
    while(<$read>) {
        chomp;
        push @output, $_;
    }
    waitpid $pid, 0;
}
else {
    close $read;
    open STDOUT, '>&', $write;
    open STDERR, '>&', $write;
    exec 'bash', '-c', './ack --nocolor perl <(cat t/swamp/options.pl)';
}

lists_match( \@output, \@expected );
