package App::Ack::Filter::Is;

use strict;
use warnings;
use base 'App::Ack::Filter';

use File::Spec 3.00 ();
use App::Ack::Filter::IsGroup;

sub new {
    my ( $class, $filename ) = @_;

    return bless {
        filename => $filename,
        groupname => 'IsGroup',
    }, $class;
}

sub create_group {
    return App::Ack::Filter::IsGroup->new();
}

sub filter {
    my ( $self, $resource ) = @_;

    my $filename = $self->{'filename'};
    my $base     = (File::Spec->splitpath($resource->name))[2];

    return $base eq $filename;
}

sub inspect {
    my ( $self ) = @_;

    my $filename = $self->{'filename'};

    return ref($self) . " - $filename";
}

sub to_string {
    my ( $self ) = @_;

    my $filename = $self->{'filename'};

    return $filename;
}

BEGIN {
    App::Ack::Filter->register_filter(is => __PACKAGE__);
}

1;
