package App::Ack::Filter::FirstLineMatch;

use strict;
use warnings;
use base 'App::Ack::Filter';

sub new {
    my ( $class, $re ) = @_;

    $re =~ s{^/|/$}{}g; # XXX validate?
    $re = qr{$re}i;

    return bless {
        regex => $re,
    }, $class;
}

# This test reads the first 250 characters of a file, then just uses the
# first line found in that. This prevents reading something  like an entire
# .min.js file (which might be only one "line" long) into memory.

sub filter {
    my ( $self, $resource ) = @_;

    my $re = $self->{'regex'};

    my $line = $resource->firstliney;

    return $line =~ /$re/;
}

sub inspect {
    my ( $self ) = @_;

    my $re = $self->{'regex'};

    return ref($self) . " - $re";
}

sub to_string {
    my ( $self ) = @_;

    (my $re = $self->{regex}) =~ s{\([^:]*:(.*)\)$}{$1};

    return "first line matches /$re/";
}

BEGIN {
    App::Ack::Filter->register_filter(firstlinematch => __PACKAGE__);
}

1;
