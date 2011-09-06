package App::Ack::ConfigLoader;

=head1 App::Ack::ConfigLoader

=cut

use strict;
use warnings;

use Carp ();

=head1 METHODS

=head2 new

Creates a new config loader.

=cut

sub new {
    my ( $class, %opts ) = @_;

    my $finder = $opts{'finder'} || Carp::croak "option finder required";

    return bless {
        _finder => $finder,
    }, $class;
}

=head2 options

Returns a hash reference of options from scanning the configuration sources.

The possible options are:

=over

=item after_context

=item before_context

=item *** FLESH ME OUT ***

=back

=cut

sub options {
    my ( $self ) = @_;

    return {};
}

=head2 targets

Returns an array reference of search targets from scanning the configuration
sources.

=cut

sub targets {
    my ( $self ) = @_;

    return [];
}

1;
