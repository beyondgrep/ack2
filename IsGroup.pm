package App::Ack::Filter::IsGroup;

=head1 NAME

App::Ack::Filter::IsGroup

=head1 DESCRIPTION

The App::Ack::Filter::IsGroup class optimizes multiple
App::Ack::Filter::Is calls into one container.

Let's say you have 100 C<--type-add=is:...> filters.

You could have

    my @filters = map { make_is_filter($_) } 1..100;

and then do

    if ( any { $_->filter($rsrc) } @filters ) { ... }

but that's slow, because of of method lookup overhead, function call
overhead, etc.  So ::Is filters know how to organize themselves into an
::IsGroup filter.

=cut

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
    my $base = $resource->basename;

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
