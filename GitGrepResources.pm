package App::Ack::GitGrepResources;

use App::Ack;

use Cwd;
use File::Spec;

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

    my $self = bless { pipe => undef }, $class;

    $self->{iter} = sub {
        while (@{$start}) {
            unless ($self->{pipe}) {
                # Stolen from GARU's Data::Printer ;)
                my (undef, $regex) = ("$opt->{regex}" =~ m{
                    \(
                    \?\^?([uladxismpogce]*)
                    (?:\-[uladxismpogce]+)?
                    :(.*)
                    \)}sx
                );

                my $cwd = cwd();
                chdir($start->[0]) or next;
                open(
                    $self->{pipe}, '-|',
                    qw(git grep -P -l),
                    ($opt->{i} ? '-i' : ()),
                    ($opt->{v} ? '-v' : ()),
                    $regex,
                ) or next;
                chdir($cwd);
            }

            while (my $filename = readline($self->{pipe})) {
                chomp $filename;
                $filename = File::Spec->catfile($start->[0], $filename);

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
