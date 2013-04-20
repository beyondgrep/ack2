package App::Ack::Filter;

use strict;
use warnings;
use overload
    '""' => 'to_string';

use App::Ack::Filter::Inverse ();
use Carp 1.04 ();

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

    BEGIN {
        App::Ack::Filter->register_filter('mine' => __PACKAGE__);
    }

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

    return;
}

=head2 $filter->filter($resource)

Must be implemented by filter implementations.  Returns
true if the filter passes, false otherwise.  This method
must B<not> alter the passed-in C<$resource> object.

=head2 $filter->invert()

Returns a filter whose L</filter> method returns the opposite of this filter.

=cut

sub invert {
    my ( $self ) = @_;

    return App::Ack::Filter::Inverse->new( $self );
}

=head2 $filter->is_inverted()

Returns true if this filter is an inverted filter; false otherwise.

=cut

sub is_inverted {
    return 0;
}

=head2 $filter->to_string

Converts the filter to a string.  This method is also
called implicitly by stringification.

=cut

sub to_string {
    my ( $self ) = @_;

    return '(unimplemented to_string)';
}

=head2 $filter->inspect

Prints a human-readable debugging string for this filter.  Useful for,
you guessed it, debugging.

=cut

sub inspect {
    my ( $self ) = @_;

    return ref($self);
}

1;
