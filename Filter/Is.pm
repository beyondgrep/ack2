package App::Ack::Filter::Is;

use strict;
use warnings;
use base 'App::Ack::Filter';

use File::Spec 3.00 ();

sub new {
    my ( $class, $filename ) = @_;

    return bless {
        filename => $filename,
    }, $class;
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
}

BEGIN {
    App::Ack::Filter->register_filter(is => __PACKAGE__);
}

1;
