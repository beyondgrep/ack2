package App::Ack::FindResources;

use strict;
use warnings;

use App::Ack;
use Carp ();
use File::Spec ();

sub from_argv {
    my ( $class, $opt, $start ) = @_;

    my @ignored_files;
    my @ignored_dirs;

    foreach my $file (@{ $opt->{ifiles} }) {
        if($file =~ /^is:(.*)/) {
            push @ignored_files, ['-not', '-name', $1];
            undef $file;
        } elsif($file =~ /^ext:(.*)/) {
            my @extensions = split /,/, $1;

            foreach my $ext (@extensions) {
                push @ignored_files, ['-not', '-name', '*.' . $1];
            }
            undef $file;
        } # match could probably be done with some magic
    }

    foreach my $dir (@{ $opt->{idirs} }) {
        if($dir =~ /^is:(.*)/) {
            push @ignored_dirs, ['-name', $1, '-prune'];
            undef $dir;
        } elsif($dir =~ /^ext:(.*)/) {
            my @extensions = split /,/, $1;

            foreach my $ext (@extensions) {
                push @ignored_dirs, ['-name', '*.' . $1, '-prune'];
            }
            undef $dir;
        } # match could probably be done with some magic
    }

    @{ $opt->{ifiles} } = grep {
        defined()
    } @{ $opt->{ifiles} };

    @{ $opt->{idirs} } = grep {
        defined()
    } @{ $opt->{idirs} };

    my $self = bless {}, $class;

    my @find_args = map {
        @$_, '-o'
    } @ignored_dirs;

    push @find_args, map {
        @$_, '-a'
    } @ignored_files;

    my $filter_added = 0;
    foreach my $filter (@{ $opt->{filters} }) {
        if($filter->isa('App::Ack::Filter::Extension')) {
            my @exts = @{ $filter->{extensions} };

            foreach my $ext (@exts) {
                push @find_args, '-name', '*.' . $ext, '-o';
                $filter_added = 1;
            }

            undef $filter;
        } elsif($filter->isa('App::Ack::Filter::Is')) {
            push @find_args, '-name', $filter->{filename}, '-o';
            $filter_added = 1;
            undef $filter;
        }
    }
    if($filter_added) {
        $find_args[-1] = '-a';
    }

    @{ $opt->{filters} } = grep {
        defined()
    } @{ $opt->{filters} };

    my $pipe;
    open $pipe, '-|', 'find', $start->[0], @find_args, '-type', 'f' or Carp::croak "Unable to open pipe to find: $!";

    my $file_filter = $opt->{file_filter};

    $self->{iter} = sub {
        while(defined(my $filename = <$pipe>)) {
            chomp $filename;

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
