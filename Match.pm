package App::Ack::Filter::Match;

use strict;
use warnings;
use base 'App::Ack::Filter';

use File::Spec 3.00;
use App::Ack::Filter::MatchGroup ();

sub new {
    my ( $class, $re ) = @_;

    $re =~ s{^/|/$}{}g; # XXX validate?
    $re = qr/$re/i;

    return bless {
        regex => $re,
        groupname => 'MatchGroup',
    }, $class;
}

sub create_group {
    return App::Ack::Filter::MatchGroup->new;
}

sub filter {
    my ( $self, $resource ) = @_;

    my $re = $self->{'regex'};

    return $resource->basename =~ /$re/;
}

sub inspect {
    my ( $self ) = @_;

    my $re = $self->{'regex'};

    print ref($self) . " - $re";

    return;
}

sub to_string {
    my ( $self ) = @_;

    my $re = $self->{'regex'};

    return "filename matches $re";
}

BEGIN {
    App::Ack::Filter->register_filter(match => __PACKAGE__);
}

1;
