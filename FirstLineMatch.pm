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

# XXX This test checks the first "line" of the file, but we need
# it to be less piggy.  If it's something like a .min.js file, then
# the "line" could be the entire file.  Instead, it should read the
# first, say, 100 characters of the first line.

sub filter {
    my ( $self, $resource ) = @_;

    my $re = $self->{'regex'};

    local $_;
    return unless $resource->next_text;

    return /$re/;
}

sub inspect {
    my ( $self ) = @_;

    my $re = $self->{'regex'};

    return ref($self) . " - $re";
}

sub to_string {
    my ( $self ) = @_;

    my $re = $self->{'regex'};

    return "first line matches $re";
}

BEGIN {
    App::Ack::Filter->register_filter(firstlinematch => __PACKAGE__);
}

1;
