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

    my $data = $self->{'data'};
    my $filename = $filter->{'filename'};

    $data->{$filename} = 1;
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

    my $data = $self->{'data'};

    return join(' ', map { "$_" } (keys $data));
}

1;
