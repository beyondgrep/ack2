package App::Ack::Filter::MatchGroup;

=head1 NAME

App::Ack::Filter::MatchGroup

=head1 DESCRIPTION

The App::Ack::Filter::MatchGroup class optimizes multiple ::Match calls
into one container.  See App::Ack::Filter::IsGroup for details.

=cut

use strict;
use warnings;
use base 'App::Ack::Filter';

sub new {
    my ( $class ) = @_;

    return bless {
        matches => [],
        big_re  => undef,
    }, $class;
}

sub add {
    my ( $self, $filter ) = @_;

    push @{ $self->{matches} }, $filter->{regex};

    my $re = join('|', map { "(?:$_)" } @{ $self->{matches} });
    $self->{big_re} = qr/$re/;

    return;
}

sub filter {
    my ( $self, $resource ) = @_;

    my $re = $self->{big_re};

    return $resource->basename =~ /$re/;
}

sub inspect {
    my ( $self ) = @_;

    # XXX Needs an explicit return.
}

sub to_string {
    my ( $self ) = @_;

    # XXX Needs an explicit return.
}

1;
