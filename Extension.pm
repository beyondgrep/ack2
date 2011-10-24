package App::Ack::Filter::Extension;

use strict;
use warnings;
use base 'App::Ack::Filter';

sub new {
    my ( $class, @extensions ) = @_;

    my $exts = join('|', map { "\Q$_\E"} @extensions);
    my $re   = qr/\.(?:$exts)$/;

    return bless \$re, $class;
};

sub filter {
    my ( $self, @filenames ) = @_;

    my $re = $$self;

    return grep { /$re/ } @filenames;
}

App::Ack::Filter->register_filter(ext => __PACKAGE__);

1;
