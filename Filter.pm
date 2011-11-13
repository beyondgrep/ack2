package App::Ack::Filter;

use strict;
use warnings;

use Carp ();

my %filter_types;

=head1 NAME

App::Ack::Filter - Filter objects to filter files

=head1 SYNOPSIS

    # filter implementation
    package MyFilter;

    use strict;
    use warnings;
    use base 'App::Ack::Filter';

    sub filter {
        my ( $self, $resource ) = @_;
    }

    App::Ack::Filter->register_filter('mine' => __PACKAGE__);

    1;

    # users
    App::Ack::Filter->create_filter('mine', @args);


=head1 DESCRIPTION

App::Ack::Filter implementations are responsible for filtering filenames
to be searched.

=head1 METHODS

=head2 App::Ack:Filter->create_filter($type, @args)

Creates a filter implementation, registered as C<$type>.  C<@args>
are provided as additional arguments to the implementation's constructor.

=cut

sub create_filter {
    my ( undef, $type, @args ) = @_;

    if ( my $package = $filter_types{$type} ) {
        return $package->new(@args);
    }
    Carp::croak "Unknown filter type '$type'";
}

=head2 App::Ack:Filter->register_filter($type, $package)

Registers a filter implementation package C<$package> under
the name C<$type>.

=cut

sub register_filter {
    my ( undef, $type, $package ) = @_;

    $filter_types{$type} = $package;
}

=head2 $filter->filter($resource)

Must be implementated by filter implementations.  Returns
true if the filter passes, false otherwise.

=cut

1;
