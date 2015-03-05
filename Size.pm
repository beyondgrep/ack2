package App::Ack::Filter::Size;

use strict;
use warnings;
use base 'App::Ack::Filter';

use App::Ack::Filter ();

sub new {
    my ( $class, $min, $max ) = @_;
    return bless {
        min => $min,
        max => $max,
    }, $class;
}

sub filter {
    my ( $self, $resource ) = @_;

    my $min = $self->{'min'} || 0;
    my $max = $self->{'max'};

    my $file = $resource->name;

    return 1 if $file eq '-';

    my $size = (-s $file) || 0; # paranoid?

    return 0 if $max and $size > $max;
    return $size >= $min;
}

sub inspect {
    my ( $self ) = @_;

    my $min = $self->{'min'} || 0;
    my $max = $self->{'max'} || '*';

    return ref($self) . " - $min..$max";
}

sub to_string {
    shift->inspect;
}

BEGIN {
    App::Ack::Filter->register_filter(size => __PACKAGE__);
}

1;
