package App::Ack::Filter::Match;

use strict;
use warnings;
use base 'App::Ack::Filter';

use File::Spec;

sub new {
    my ( $class, $re ) = @_;

    $re =~ s{^/|/$}{}g; # XXX validate?
    $re = qr/$re/i;

    return bless \$re, $class;
}

sub filter {
    my ( $self, $resource ) = @_;

    my $re   = ${$self};
    my $base = (File::Spec->splitpath($resource->name))[2];

    return $base =~ /$re/;
}

BEGIN {
    App::Ack::Filter->register_filter(match => __PACKAGE__);
}

1;
