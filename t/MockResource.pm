package MockResource;

use strict;
use warnings;
use parent 'App::Ack::Resource';

sub new {
    my ( $class, $filename ) = @_;

    return bless {
        filename => $filename,
    }, $class;
}

sub name {
    my ( $self ) = @_;

    return $self->{'filename'};
}

1;
