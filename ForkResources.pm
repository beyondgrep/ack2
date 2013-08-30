package App::Ack::ForkResources;

use App::Ack;
use Carp ();

use strict;
use warnings;

sub from_argv {
    my $class = shift;
    my $opt   = shift;
    my $start = shift;

    my ( $read, $write );

    pipe ( $read, $write ) or Carp::croak "Unable to create pipe: $!";
    my $pid = fork();

    unless(defined $pid) {
        close $read;
        close $write;
        Carp::croak "Unable to fork child: $!";
    }

    if($pid) {
        close $write;

        my $self = bless {}, $class;

        $self->{iter} = sub {
            my $filename = <$read>;

            if(defined $filename) {
                chomp $filename;
                return $filename;
            } else {
                close $read;
                waitpid $pid, 0;
                return;
            }
        };

        return $self;
    } else {
        close $read;
        my $descend_filter = $opt->{descend_filter};

        if( $opt->{n} ) {
            $descend_filter = sub {
                return 0;
            };
        }

        my $iter = File::Next::files( {
            file_filter     => $opt->{file_filter},
            descend_filter  => $descend_filter,
            error_handler   => sub { my $msg = shift; App::Ack::warn( $msg ) },
            sort_files      => $opt->{sort_files},
            follow_symlinks => $opt->{follow},
        }, @{$start} );

        while(defined(my $filename = $iter->())) {
            print {$write} $filename, "\n";
        }
        close $write;

        exit 0;
    }
}

# XXX copied this over for now; proper relationships will need to be established
sub next {
    my $self = shift;

    my $file = $self->{iter}->() or return;

    return App::Ack::Resource::Basic->new( $file );
}

1;
