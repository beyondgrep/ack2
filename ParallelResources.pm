package App::Ack::ParallelResources;

use strict;
use warnings;

use Carp ();

sub _parent_iterator {
    my ( $self, $opt, $start, $workers ) = @_;

    my $descend_filter = $opt->{descend_filter};

    if( $opt->{n} ) {
        $descend_filter = sub {
            return 0;
        };
    }

    my $file_iterator =
        File::Next::files( {
            file_filter     => $opt->{file_filter},
            descend_filter  => $descend_filter,
            error_handler   => sub { my $msg = shift; App::Ack::warn( $msg ) },
            sort_files      => $opt->{sort_files},
            follow_symlinks => $opt->{follow},
        }, @{$start} );

    my $worker_index = 0;
    $self->{iter} = sub {
        while ( defined(my $filename = $file_iterator->()) ) {
            # XXX round-robin basically works; we can do better, though
            my $pipe       = $workers->[ $worker_index++ ]{write_pipe};
            $worker_index %= @$workers;
            print { $pipe } $filename, "\n";
        }

        foreach my $worker ( @$workers ) {
            close $worker->{write_pipe};
        }

        foreach my $worker ( @$workers ) {
            waitpid $worker->{pid}, 0;
        }

        return;
    };

    return $self;
}

sub _handle_error {
    my ( $self ) = @_;

    # XXX stick with current # of workers?
    # XXX fallback to default resources object?
    Carp::croak "Unable to create worker: $!";
}

sub _create_worker {
    my ( $self, $opt ) = @_;

    my ( $read, $write );

    if ( !pipe($read, $write) ) {
        $self->_handle_error;
    }

    my $pid = fork();

    if ( !defined($pid) ) {
        $self->_handle_error;
    }

    if ( $pid ) {
        close $read;

        return {
            pid        => $pid,
            write_pipe => $write,
        };
    }
    else {
        # XXX worker processes should have a custom STDOUT/STDERR or something
        #     so that their output isn't interleaved
        $self->{iter} = sub {
            if ( defined(my $filename = <$read>) ) {
                chomp $filename;

                return $filename;
            }

            close $read;

            exit 0;
        };

        close $write;
        return;
    }
}

sub from_argv {
    my ( $class, $opt, $start ) = @_;

    my $self = bless {}, $class;

    my @workers;

    # XXX should we lazily allocate workers?
    for ( 1 .. 4 ) { # XXX hardcoded number of workers
        my $worker = $self->_create_worker( $opt );

        if ( $worker ) {
            push @workers, $worker;
        }
        else {
            return $self;
        }
    }

    return $self->_parent_iterator($opt, $start, \@workers);
}

# XXX copied from Resources.pm; we need a way to do this more cleanly
sub next {
    my ( $self ) = @_;

    my $file = $self->{iter}->() or return;

    return App::Ack::Resource::Basic->new( $file );
}

1;
