package App::Ack::Filter::ExtensionGroup;

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
    my $extensions = $filter->{'extensions'};

    foreach my $ext (@{$extensions}) {
        $data->{lc $ext} = 1;
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
