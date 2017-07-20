package App::Ack::Filter::IsPathGroup;


=head1 NAME

App::Ack::Filter::IsPathGroup

=head1 DESCRIPTION

The App::Ack::Filter::IsPathGroup class optimizes multiple ::IsPath
calls into one container.  See App::Ack::Filter::IsGroup for details.

=cut


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

    $self->{data}->{ $filter->{filename} } = 1;

    return;
}

sub filter {
    my ( $self, $resource ) = @_;

    my $data = $self->{'data'};

    return exists $data->{$resource->name};
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
