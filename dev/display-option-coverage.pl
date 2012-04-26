#!/usr/bin/env perl

use strict;
use warnings;
use lib 'blib/lib';

use App::Ack::ConfigLoader ();

my $arg_spec = App::Ack::ConfigLoader::get_arg_spec({});

my $fh;
open $fh, '<', 'opts.coverage' or die $!;

while ( <$fh> ) {
    chomp;

    delete $arg_spec->{$_};
}

close $fh;

if ( keys %{$arg_spec} ) {
    print "The following options were not used in the test suite:\n\n";
    print "  $_\n" foreach sort keys %{$arg_spec};
}
else {
    print "All options were used in the test suite\n";
}
