package App::Ack::Resources;

=head1 NAME

App::Ack::Resources

=head1 SYNOPSIS

A factory object for creating a stream of L<App::Ack::Resource> objects.

=cut

use App::Ack;
use App::Ack::Resource;

use File::Next 1.16;
use Errno qw(EACCES);

use warnings;
use strict;

sub _generate_error_handler {
    my $opt = shift;

    if ( $opt->{dont_report_bad_filenames} ) {
        return sub {
            my $msg = shift;
            if ( $! == EACCES ) {
                return;
            }
            App::Ack::warn( $msg );
        };
    }
    else {
        return sub {
            my $msg = shift;
            App::Ack::warn( $msg );
        };
    }
}

=head1 METHODS

=head2 from_argv( \%opt, \@starting_points )

Return an iterator that does the file finding for us.

=cut

sub from_argv {
    my $class = shift;
    my $opt   = shift;
    my $start = shift;

    my $self = bless {}, $class;

    my $file_filter    = undef;
    my $descend_filter = $opt->{descend_filter};

    if( $opt->{n} ) {
        $descend_filter = sub {
            return 0;
        };
    }

    $self->{iter} =
        File::Next::files( {
            file_filter     => $opt->{file_filter},
            descend_filter  => $descend_filter,
            error_handler   => _generate_error_handler($opt),
            warning_handler => sub {},
            sort_files      => $opt->{sort_files},
            follow_symlinks => $opt->{follow},
        }, @{$start} );

    return $self;
}

=head2 from_file( \%opt, $filename )

Return an iterator that reads the list of files to search from a
given file.  If I<$filename> is '-', then it reads from STDIN.

=cut

sub from_file {
    my $class = shift;
    my $opt   = shift;
    my $file  = shift;

    my $iter =
        File::Next::from_file( {
            error_handler   => _generate_error_handler($opt),
            warning_handler => _generate_error_handler($opt),
            sort_files      => $opt->{sort_files},
        }, $file ) or return undef;

    return bless {
        iter => $iter,
    }, $class;
}

# This is for reading input lines from STDIN, not the list of files from STDIN
sub from_stdin {
    my $class = shift;
    my $opt   = shift;

    my $self  = bless {}, $class;

    my $has_been_called = 0;

    $self->{iter} = sub {
        if ( !$has_been_called ) {
            $has_been_called = 1;
            return '-';
        }
        return;
    };

    return $self;
}

sub next {
    my $self = shift;

    my $file = $self->{iter}->() or return;

    return App::Ack::Resource->new( $file );
}

1;
