package App::Ack::Filter::Default;

use strict;
use warnings;
use base 'App::Ack::Filter';

sub new {
    my ( $class ) = @_;

    return bless {}, $class;
}

sub filter {
    my ( $self, $resource ) = @_;

    return -T $resource->name;
}

1;
