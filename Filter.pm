package App::Ack::Filter;

use strict;
use warnings;

use Carp ();

my %filter_types;

sub create_filter {
    my ( undef, $type, @args ) = @_;

    if(my $package = $filter_types{$type}) {
        return $package->new(@args);
    } else {
        Carp::croak "Unknown filter type '$type'";
    }
}

sub register_filter {
    my ( undef, $type, $package ) = @_;

    $filter_types{$type} = $package;
}

1;
