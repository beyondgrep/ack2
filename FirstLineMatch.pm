package App::Ack::Filter::FirstLineMatch;

use strict;
use warnings;
use base 'App::Ack::Filter';

sub new {
    my ( $class, $re ) = @_;
    $re =~ s!^/|/$!!g; # XXX validate?
    $re = qr/$re/i;

    return bless \$re, $class;
}

sub filter {
    my ( $self, $resource ) = @_;

    my $re         = $$self;

    local $_;
    $resource->next_text;

    return /$re/;
}

BEGIN {
    App::Ack::Filter->register_filter(firstlinematch => __PACKAGE__);
}

1;
