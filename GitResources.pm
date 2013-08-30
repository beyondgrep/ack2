package App::Ack::GitResources;

use App::Ack;
use Carp ();
use File::Spec ();

use strict;
use warnings;

=head1 SYNOPSIS

This is a Resources class that uses git-ls-files to build a file list instead of File::Next.

=head1 METHODS

=head2 from_argv( \%opt, \@starting_points )

L<App::Ack::Resources/from_argv>

=head1 SEE ALSO

L<App::Ack::Resources>

=cut

sub from_argv {
    my ( $class, $opt, $start ) = @_;

    my $self = bless {}, $class;

    my $pipe;
    open $pipe, '-|', 'git', '--git-dir=' . $start->[0] . '/.git', '--work-tree=' . $start->[0], 'ls-files' or Carp::croak "Unable to open pipe to git-ls-files: $!";

    my $file_filter = $opt->{file_filter};

    $self->{iter} = sub {
        while(defined(my $filename = <$pipe>)) {
            chomp $filename;

            $filename = File::Spec->catfile($start->[0], $filename);

            local $File::Next::name = $filename;

            next unless $file_filter->();

            return $filename;
        }
        close $pipe;

        return;
    };

    return $self;
}

# XXX copied this over for now; proper relationships will need to be established
sub next {
    my $self = shift;

    my $file = $self->{iter}->() or return;

    return App::Ack::Resource::Basic->new( $file );
}

1;
