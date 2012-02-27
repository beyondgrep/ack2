package App::Ack::Filter::Is;

use strict;
use warnings;
use base 'App::Ack::Filter';

use File::Spec ();

sub new {
    my ( $class, $filename ) = @_;

    return bless \$filename, $class;
}

sub filter {
    my ( $self, $resource ) = @_;

    my $filename = ${$self};
    my $base     = (File::Spec->splitpath($resource->name))[2];

    return $base eq $filename;
}

BEGIN {
    App::Ack::Filter->register_filter(is => __PACKAGE__);
}

1;
