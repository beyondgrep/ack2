package App::Ack::Filter::Size;

use strict;
use warnings;
use base 'App::Ack::Filter';

use Carp 'croak';

use App::Ack::Filter ();

sub _parse_size {
    my $s = $_[0] || return 0;

    if ( $s =~ m/^\s*(\d+(?:\.\d+)?)(?:\s*([KMGT]?)(?:(i?)B)?)?\s*$/i ) {
        my $n = $1;
        if ($2) {
            my $u = lc $2;
            my $i = $3 ? 1024 : 1000; # 1KiB = 1024B; 1KB = 1000B
            $n *= $i while $u =~ tr/tgmk/gmk/d;
        }
        return int $n;
    }
    else {
        Carp::croak('Invalid size');
    }
}

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

    my $size = (-s _) || 0; # paranoid?

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
