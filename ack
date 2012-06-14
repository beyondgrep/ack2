#!/usr/bin/perl

use strict;
use warnings;

use 5.8.0;

use App::Ack ();
use App::Ack::ConfigLoader ();
use App::Ack::Resources;
use App::Ack::Resource::Basic ();

# XXX Don't make this so brute force
use App::Ack::Filter ();
use App::Ack::Filter::Default;
use App::Ack::Filter::Extension;
use App::Ack::Filter::FirstLineMatch;
use App::Ack::Filter::Inverse;
use App::Ack::Filter::Is;
use App::Ack::Filter::Match;

use Carp ();

our $VERSION = '2.00a01';
# Check http://betterthangrep.com/ for updates

# These are all our globals.

MAIN: {
    if ( $App::Ack::VERSION ne $main::VERSION ) {
        App::Ack::die( "Program/library version mismatch\n\t$0 is $main::VERSION\n\t$INC{'App/Ack.pm'} is $App::Ack::VERSION" );
    }

    # Do preliminary arg checking;
    my $env_is_usable = 1;
    for ( @ARGV ) {
        last if ( $_ eq '--' );

        # Get the --thpppt and --bar checking out of the way.
        /^--th[pt]+t+$/ && App::Ack::_thpppt($_);
        /^--bar$/ && App::Ack::_bar();

        # See if we want to ignore the environment. (Don't tell Al Gore.)
        if ( /^--(no)?env$/ ) {
            $env_is_usable = defined $1 ? 0 : 1;
        }
    }
    @ARGV = grep { defined() } @ARGV; # filter out options we discarded
    if ( !$env_is_usable ) {
        my @keys = ( 'ACKRC', grep { /^ACK_/ } keys %ENV );
        delete @ENV{@keys};
    }
    App::Ack::load_colors();

    if ( !@ARGV ) {
        App::Ack::show_help();
        exit 1;
    }

    main();
}

sub _compile_descend_filter {
    my ( $opt ) = @_;

    my $idirs = $opt->{idirs};
    return unless $idirs && @{$idirs};

    my %ignore_dirs;

    foreach my $idir (@{$idirs}) {
        if ( $idir =~ /^(\w+):(.*)/ ) {
            if ( $1 eq 'is') {
                $ignore_dirs{$2} = 1;
            }
            else {
                Carp::croak( 'Non-is filters are not yet supported for --ignore-dir' );
            }
        }
        else {
            Carp::croak( qq{Invalid filter specification "$_"} );
        }
    }

    return sub {
        return !exists $ignore_dirs{$_} && !exists $ignore_dirs{$File::Next::dir};
    };
}

sub _compile_file_filter {
    my ( $opt, $start ) = @_;

    my $ifiles = $opt->{ifiles};
    $ifiles  ||= [];

    my @ifiles_filters = map {
        my $filter;

        if ( /^(\w+):(.+)/ ) {
            my ($how,$what) = ($1,$2);
            $filter = App::Ack::Filter->create_filter($how, split(/,/, $what));
        }
        else {
            Carp::croak( qq{Invalid filter specification "$_"} );
        }
        $filter
    } @{$ifiles};

    my $filters         = $opt->{'filters'} || [];
    my $inverse_filters = [ grep {  $_->is_inverted() } @{$filters} ];
    @{$filters}         =   grep { !$_->is_inverted() } @{$filters};

    my %is_member_of_starting_set = map { ($_ => 1) } @{$start};

    return sub {
        return 1 if $is_member_of_starting_set{ $File::Next::name };

        foreach my $filter (@ifiles_filters) {
            my $resource = App::Ack::Resource::Basic->new($File::Next::name);
            return 0 if ! $resource || $filter->filter($resource);
        }
        my $match_found = 1;
        if ( @{$filters} ) {
            $match_found = 0;

            foreach my $filter (@{$filters}) {
                my $resource = App::Ack::Resource::Basic->new($File::Next::name);
                return 0 if ! $resource;
                if ($filter->filter($resource)) {
                    $match_found = 1;
                    last;
                }
            }
        }
        # Don't bother invoking inverse filters unless we consider the current resource a match
        if ( $match_found && @{$inverse_filters} ) {
            foreach my $filter ( @{$inverse_filters} ) {
                my $resource = App::Ack::Resource::Basic->new($File::Next::name);
                return 0 if ! $resource;
                if ( not $filter->filter( $resource ) ) {
                    $match_found = 0;
                    last;
                }
            }
        }
        return $match_found;
    };
}

sub main {
    my @arg_sources = App::Ack::retrieve_arg_sources();

    my $opt = App::Ack::ConfigLoader::process_args( @arg_sources );

    if ( $opt->{flush} ) {
        $| = 1;
    }

    if ( not defined $opt->{color} ) {
        $opt->{color} = !App::Ack::output_to_pipe() && !$App::Ack::is_windows;
    }
    if ( not defined $opt->{heading} and not defined $opt->{break}  ) {
        $opt->{heading} = $opt->{break} = !App::Ack::output_to_pipe();
    }

    if ( defined($opt->{H}) || defined($opt->{h}) ) {
        $opt->{show_filename}= $opt->{H} && !$opt->{h};
    }

    my $resources;
    if ( $App::Ack::is_filter_mode ) {
        $resources    = App::Ack::Resources->from_stdin( $opt );
        my $regex = $opt->{regex};
        $regex = shift @ARGV if not defined $regex;
        $opt->{regex} = App::Ack::build_regex( $regex, $opt );
    }
    else {
        if ( $opt->{f} || $opt->{lines} ) {
            if ( $opt->{regex} ) {
                App::Ack::warn( "regex ($opt->{regex}) specified with -f or --lines" );
                App::Ack::exit_from_ack( 0 ); # XXX the 0 is misleading
            }
        }
        else {
            my $regex = $opt->{regex};
            $regex = shift @ARGV if not defined $regex;
            $opt->{regex} = App::Ack::build_regex( $regex, $opt );
        }
        my @start;
        if ( not defined $opt->{files_from} ) {
            @start = @ARGV;
        }
        if ( !exists($opt->{show_filename}) ) {
            unless(@start == 1 && !(-d $start[0])) {
                $opt->{show_filename} = 1;
            }
        }

        if ( defined $opt->{files_from} ) {
            $resources = App::Ack::Resources->from_file( $opt, $opt->{files_from} );
            exit 1 unless $resources;
        }
        else {
            @start = ('.') unless @start;
            foreach my $target (@start) {
                if ( not -e $target ) {
                    App::Ack::warn( "$target: No such file or directory" );
                }
            }

            $opt->{file_filter}    = _compile_file_filter($opt, \@start);
            $opt->{descend_filter} = _compile_descend_filter($opt);

            $resources = App::Ack::Resources->from_argv( $opt, \@start );
        }
    }
    App::Ack::set_up_pager( $opt->{pager} ) if defined $opt->{pager};

    my $print_filenames = $opt->{show_filename};
    my $max_count       = $opt->{m};
    my $ors             = $opt->{print0} ? "\0" : "\n";
    my $only_first      = $opt->{1};

    my $nmatches = 0;
RESOURCES:
    while ( my $resource = $resources->next ) {
        # XXX this variable name combined with what we're trying
        # to do makes no sense.
        if ( $opt->{f} ) {
            # XXX printing should probably happen inside of App::Ack
            print $resource->name, $ors;
            ++$nmatches;
            last RESOURCES if defined($max_count) && $nmatches >= $max_count;
        }
        elsif ( $opt->{g} ) {
            my $is_match = ( $resource->name =~ /$opt->{regex}/o );
            if ( $opt->{v} ? !$is_match : $is_match ) {
                print $resource->name, $ors;
                ++$nmatches;
                last RESOURCES if defined($max_count) && $nmatches >= $max_count;
            }
        }
        elsif ( $opt->{lines} ) {
            my $print_filename = $opt->{show_filename};
            my $passthru       = $opt->{passthru};

            my %line_numbers;
            foreach my $line ( @{ $opt->{lines} } ) {
                my @lines             = split /,/, $line;
                @lines                = map {
                    /^(\d+)-(\d+)$/
                        ? ( $1 .. $2 )
                        : $_
                } @lines;
                @line_numbers{@lines} = (1) x @lines;
            }

            my $filename = $resource->name;

            App::Ack::iterate($resource, $opt, sub {
                chomp;

                if ( $line_numbers{$.} ) {
                    App::Ack::print_line_with_context($opt, $filename, $_, $.);
                }
                elsif ( $passthru ) {
                    App::Ack::print_line_with_options($opt, $filename, $_, $., ':');
                }
                return 1;
            });
        }
        elsif ( $opt->{count} ) {
            my $matches_for_this_file = App::Ack::count_matches_in_resource( $resource, $opt );
            if ( !$opt->{l} || $matches_for_this_file > 0) {
                if ( $print_filenames ) {
                    # XXX printing should probably happen inside of App::Ack
                    print $resource->name, ':', $matches_for_this_file, $ors;
                }
                else {
                    # XXX printing should probably happen inside of App::Ack
                    print $matches_for_this_file, $ors;
                }
            }
        }
        elsif ( $opt->{l} ) {
            my $is_match = App::Ack::resource_has_match( $resource, $opt );

            if ( $opt->{v} ? !$is_match : $is_match ) {
                # XXX printing should probably happen inside of App::Ack
                print $resource->name, $ors;
                ++$nmatches;
            }
        }
        else {
            $nmatches += App::Ack::print_matches_in_resource( $resource, $opt );
            if ( $nmatches && $only_first ) {
                last RESOURCES;
            }
        }
    }

    close $App::Ack::fh;
    App::Ack::exit_from_ack( $nmatches );
}


=head1 AUTHOR

Andy Lester, C<< <andy at petdance.com> >>

=head1 BUGS

Please report any bugs or feature requests to the issues list at
Github: L<https://github.com/petdance/ack/issues>

=head1 ENHANCEMENTS

All enhancement requests MUST first be posted to the ack-users
mailing list at L<http://groups.google.com/group/ack-users>.  I
will not consider a request without it first getting seen by other
ack users.  This includes requests for new filetypes.

There is a list of enhancements I want to make to F<ack> in the ack
issues list at Github: L<https://github.com/petdance/ack/issues>

Patches are always welcome, but patches with tests get the most
attention.

=head1 SUPPORT

Support for and information about F<ack> can be found at:

=over 4

=item * The ack homepage

L<http://betterthangrep.com/>

=item * The ack-users mailing list

L<http://groups.google.com/group/ack-users>

=item * The ack issues list at Github

L<https://github.com/petdance/ack/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ack>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ack>

=item * Search CPAN

L<http://search.cpan.org/dist/ack>

=item * Git source repository

L<https://github.com/petdance/ack>

=back

=head1 ACKNOWLEDGEMENTS

How appropriate to have I<ack>nowledgements!

Thanks to everyone who has contributed to ack in any way, including
Ryan Olson,
Shlomi Fish,
Karen Etheridge,
Olivier Mengue,
Matthew Wild,
Scott Kyle,
Nick Hooey,
Bo Borgerson,
Mark Szymanski,
Marq Schneider,
Packy Anderson,
JR Boyens,
Dan Sully,
Ryan Niebur,
Kent Fredric,
Mike Morearty,
Ingmar Vanhassel,
Eric Van Dewoestine,
Sitaram Chamarty,
Adam James,
Richard Carlsson,
Pedro Melo,
AJ Schuster,
Phil Jackson,
Michael Schwern,
Jan Dubois,
Christopher J. Madsen,
Matthew Wickline,
David Dyck,
Jason Porritt,
Jjgod Jiang,
Thomas Klausner,
Uri Guttman,
Peter Lewis,
Kevin Riggle,
Ori Avtalion,
Torsten Blix,
Nigel Metheringham,
GE<aacute>bor SzabE<oacute>,
Tod Hagan,
Michael Hendricks,
E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason,
Piers Cawley,
Stephen Steneker,
Elias Lutfallah,
Mark Leighton Fisher,
Matt Diephouse,
Christian Jaeger,
Bill Sully,
Bill Ricker,
David Golden,
Nilson Santos F. Jr,
Elliot Shank,
Merijn Broeren,
Uwe Voelker,
Rick Scott,
Ask BjE<oslash>rn Hansen,
Jerry Gay,
Will Coleda,
Mike O'Regan,
Slaven ReziE<0x107>,
Mark Stosberg,
David Alan Pisoni,
Adriano Ferreira,
James Keenan,
Leland Johnson,
Ricardo Signes
and Pete Krawczyk.

=head1 COPYRIGHT & LICENSE

Copyright 2005-2012 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

=cut
