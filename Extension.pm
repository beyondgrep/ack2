package App::Ack::Filter::Extension;

use strict;
use warnings;
use base 'App::Ack::Filter';

sub new {
    my ( $class, @extensions ) = @_;

    my $exts = join('|', map { "\Q$_\E"} @extensions);
    my $re   = qr/[.](?:$exts)$/i;

    return bless {
        extensions => \@extensions,
        regex      => $re,
    }, $class;
};

sub filter {
    my ( $self, $resource ) = @_;

    my $re = $self->{'regex'};

    return $resource->name =~ /$re/;
}

sub inspect {
    my ( $self ) = @_;

    my $re = $self->{'regex'};

    return ref($self) . " - $re";
}

sub to_string {
    my ( $self ) = @_;

    my $exts = $self->{'extensions'};

    return join(' ', map { ".$_" } @{$exts});
}

BEGIN {
    App::Ack::Filter->register_filter(ext => __PACKAGE__);
}

1;
