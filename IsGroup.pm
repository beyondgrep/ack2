package App::Ack::Filter::IsGroup;

use strict;
use warnings;
use base 'App::Ack::Filter';

use File::Spec 3.00 ();

sub new {
    my ( $class ) = @_;

    return bless {
        data => {},
    }, $class;
}

sub add {
    my ( $self, $filter ) = @_;

    $self->{data}->{ $filter->{filename} } = 1;

    return;
}

sub filter {
    my ( $self, $resource ) = @_;

    my $data = $self->{'data'};
    my $base = (File::Spec->splitpath($resource->name))[2];

    return exists $data->{$base};
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . " - $self";
}

sub to_string {
    my ( $self ) = @_;

    return join(' ', keys %{$self->{data}});
}

1;
