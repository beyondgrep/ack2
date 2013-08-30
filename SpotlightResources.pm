package App::Ack::SpotlightResources;

use App::Ack;

use warnings;
use strict;

use base 'App::Ack::Resources';

=head1 SYNOPSIS

This is the base class for App::Ack::Resources, an iterator factory
for App::Ack::Resource objects.

=head1 METHODS

=head2 from_argv( \%opt, \@starting_points )

Return an iterator that does the file finding for us.

=cut

sub from_argv {
    my $class = shift;
    my $opt   = shift;
    my $start = shift;

    my $self = bless {
        pipe    => undef,
    }, $class;

    $self->{iter} = sub {
        while (@{$start}) {
            unless ($self->{pipe}) {
                # Stolen from GARU's Data::Printer ;)
                my ($modifiers, $regex) = ("$opt->{regex}" =~ m{
                    \(
                    \?\^?([uladxismpogce]*)
                    (?:\-[uladxismpogce]+)?
                    :(.*)
                    \)}sx
                );
                my $match = ($modifiers eq '' and $regex =~ m{^\(\?i\)(\w+)$}x)
                    ? $1
                    : '(-wCjouHSy)'; # MAGICK!!!

                my $opened = open(
                    $self->{pipe}, '-|',
                    qw(mdfind -onlyin),
                    $start->[0],
                    $match,
                );
            }

            while (my $filename = readline($self->{pipe})) {
                chomp $filename;

                local $File::Next::name = $filename;
                next unless $opt->{file_filter}->();

                return $filename;
            }
            close $self->{pipe};
        } continue {
            undef $self->{pipe};
            shift @{$start};
        }

        return;
    };

    return $self;
}

1;
