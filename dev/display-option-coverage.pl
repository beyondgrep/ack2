#!/usr/bin/env perl

use strict;
use warnings;
use lib 'blib/lib';

use App::Ack::ConfigLoader ();

if ( ! -e 'opts.coverage' ) {
    die <<'END_DIE';
Coverage file 'opts.coverage' not found!
If you'd like to generate this file, please
set the ACK_OPTION_COVERAGE environment variable
to a truthy value and run 'make test'.
END_DIE
}

my @extra_options = (
    'type-add=s',
    'type-set=s',
    'dump',
);

my $arg_spec = App::Ack::ConfigLoader::get_arg_spec({});
foreach my $option ( @extra_options ) {
    $arg_spec->{ $option } = 1;
}

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
