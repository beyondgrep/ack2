package App::Ack::Filter::Collection;

use strict;
use warnings;
use base 'App::Ack::Filter';

sub new {
    my ( $class ) = @_;

    return bless {
        groups => {},
        ungrouped => [],
    }, $class;
}

sub filter {
    my ( $self, $resource ) = @_;

    for my $group (values %{$self->{'groups'}}) {
        if ($group->filter($resource)) {
            return 1;
        }
    }

    for my $filter (@{$self->{'ungrouped'}}) {
        if ($filter->filter($resource)) {
            return 1;
        }
    }

    return 0;
}

sub add {
    my ( $self, $filter ) = @_;

    if (exists $filter->{'groupname'}) {
        my $group = ($self->{groups}->{$filter->{groupname}} ||= $filter->create_group());
        $group->add($filter);
    }
    else {
        push @{$self->{'ungrouped'}}, $filter;
    }

    return;
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . " - $self";
}

sub to_string {
    my ( $self ) = @_;

    my $ungrouped = $self->{'ungrouped'};

    return join(', ', map { "($_)" } @{$ungrouped});
}

1;
