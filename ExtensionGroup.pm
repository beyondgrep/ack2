package App::Ack::Filter::ExtensionGroup;

use strict;
use warnings;
use base 'App::Ack::Filter';

sub new {
    my ( $class ) = @_;

    return bless {
        data => {},
    }, $class;
}

sub add {
    my ( $self, $filter ) = @_;

    foreach my $ext (@{$filter->{extensions}}) {
        $self->{data}->{lc $ext} = 1;
    }

    return;
}

sub filter {
    my ( $self, $resource ) = @_;

    if ($resource->name =~ /[.]([^.]*)$/) {
        return exists $self->{'data'}->{lc $1};
    }

    return 0;
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . " - $self";
}

sub to_string {
    my ( $self ) = @_;

    return join(' ', map { ".$_" } sort keys %{$self->{data}});
}

1;
