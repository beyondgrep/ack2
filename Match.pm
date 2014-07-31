package App::Ack::Filter::Match;

use strict;
use warnings;
use base 'App::Ack::Filter';

use File::Spec 3.00;

sub new {
    my ( $class, $re ) = @_;

    $re =~ s{^/|/$}{}g; # XXX validate?
    $re = qr/$re/i;

    return bless {
        regex => $re,
    }, $class;
}

sub filter {
    my ( $self, $resource ) = @_;

    my $re   = $self->{'regex'};
    my $base = (File::Spec->splitpath($resource->name))[2];

    return $base =~ /$re/;
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
