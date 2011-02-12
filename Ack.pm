package App::Ack;

use warnings;
use strict;

use File::Next 0.40;

=head1 NAME

App::Ack - A container for functions for the ack program

=head1 VERSION

Version 2.00a01

=cut

our $VERSION;
our $COPYRIGHT;
BEGIN {
    $VERSION = '2.00a01';
    $COPYRIGHT = 'Copyright 2005-2011 Andy Lester.';
}

our $fh;

BEGIN {
    $fh = *STDOUT;
}


our %types;
our %type_wanted;
our %mappings;
our %ignore_dirs;

our $input_from_pipe;
our $output_to_pipe;

our $dir_sep_chars;
our $is_cygwin;
our $is_windows;

use File::Spec ();
use File::Glob ':glob';
use Getopt::Long ();

BEGIN {
    # These have to be checked before any filehandle diddling.
    $output_to_pipe  = not -t *STDOUT;
    $input_from_pipe = -p STDIN;

    $is_cygwin       = ($^O eq 'cygwin');
    $is_windows      = ($^O =~ /MSWin32/);
    $dir_sep_chars   = $is_windows ? quotemeta( '\\/' ) : quotemeta( File::Spec->catfile( '', '' ) );
}

=head1 SYNOPSIS

If you want to know about the F<ack> program, see the F<ack> file itself.

No user-serviceable parts inside.  F<ack> is all that should use this.

=head1 FUNCTIONS

=head2 read_ackrc

Reads the contents of the .ackrc file and returns the arguments.

=cut

sub read_ackrc {
    my @files = ( $ENV{ACKRC} );
    my @dirs =
        $is_windows
            ? ( $ENV{HOME}, $ENV{USERPROFILE} )
            : ( '~', $ENV{HOME} );
    for my $dir ( grep { defined } @dirs ) {
        for my $file ( '.ackrc', '_ackrc' ) {
            push( @files, bsd_glob( "$dir/$file", GLOB_TILDE ) );
        }
    }
    for my $filename ( @files ) {
        if ( defined $filename && -e $filename ) {
            open( my $fh, '<', $filename ) or App::Ack::die( "$filename: $!\n" );
            my @lines = grep { /./ && !/^\s*#/ } <$fh>;
            chomp @lines;
            close $fh or App::Ack::die( "$filename: $!\n" );

            # get rid of leading and trailing whitespaces and comments
            for ( @lines ) {
               s/^\s+//;
               s/\s+$//;
               s/#.*//;
            }

            @lines = grep { /./ } @lines;

            return @lines;
        }
    }

    return;
}

=head2 get_command_line_options()

Gets command-line arguments and does the Ack-specific tweaking.

=cut

sub get_command_line_options {
    my %opt = (
        pager => $ENV{ACK_PAGER_COLOR} || $ENV{ACK_PAGER},
    );

    my $getopt_specs = {
        'env!'       => sub { }, # ignore this option, it is handled beforehand
        f            => \$opt{f},

        'version'    => sub { print_version_statement(); exit; },
        'help|?:s'   => sub { shift; show_help(@_); exit; },
        'help-types' => sub { show_help_types(); exit; },
        'man'        => sub {
            require Pod::Usage;
            Pod::Usage::pod2usage({
                -verbose => 2,
                -exitval => 0,
            });
        }, # man sub
    };

    # Stick any default switches at the beginning, so they can be overridden
    # by the command line switches.
    unshift @ARGV, split( ' ', $ENV{ACK_OPTIONS} ) if defined $ENV{ACK_OPTIONS};

    # first pass through options, looking for type definitions
    def_types_from_ARGV();

    for my $i ( filetypes_supported() ) {
        $getopt_specs->{ "$i!" } = \$type_wanted{ $i };
    }


    my $parser = Getopt::Long::Parser->new();
    $parser->configure( 'bundling', 'no_ignore_case', );
    $parser->getoptions( %{$getopt_specs} ) or
        App::Ack::die( 'See ack --help, ack --help-types or ack --man for options.' );

    my $to_screen = not output_to_pipe();
    my %defaults = (
        all            => 0,
        color          => $to_screen,
        follow         => 0,
        break          => $to_screen,
        heading        => $to_screen,
        before_context => 0,
        after_context  => 0,
    );
    if ( $is_windows && $defaults{color} && not $ENV{ACK_PAGER_COLOR} ) {
        if ( $ENV{ACK_PAGER} || not eval { require Win32::Console::ANSI } ) {
            $defaults{color} = 0;
        }
    }
    if ( $to_screen && $ENV{ACK_PAGER_COLOR} ) {
        $defaults{color} = 1;
    }

    while ( my ($key,$value) = each %defaults ) {
        if ( not defined $opt{$key} ) {
            $opt{$key} = $value;
        }
    }

    if ( defined $opt{m} && $opt{m} <= 0 ) {
        App::Ack::die( '-m must be greater than zero' );
    }

    for ( qw( before_context after_context ) ) {
        if ( defined $opt{$_} && $opt{$_} < 0 ) {
            App::Ack::die( "--$_ may not be negative" );
        }
    }

    if ( defined( my $val = $opt{output} ) ) {
        $opt{output} = eval qq[ sub { "$val" } ];
    }
    if ( defined( my $l = $opt{lines} ) ) {
        # --line=1 --line=5 is equivalent to --line=1,5
        my @lines = split( /,/, join( ',', @{$l} ) );

        # --line=1-3 is equivalent to --line=1,2,3
        @lines = map {
            my @ret;
            if ( /-/ ) {
                my ($from, $to) = split /-/, $_;
                if ( $from > $to ) {
                    App::Ack::warn( "ignoring --line=$from-$to" );
                    @ret = ();
                }
                else {
                    @ret = ( $from .. $to );
                }
            }
            else {
                @ret = ( $_ );
            };
            @ret
        } @lines;

        if ( @lines ) {
            my %uniq;
            @uniq{ @lines } = ();
            $opt{lines} = [ sort { $a <=> $b } keys %uniq ];   # numerical sort and each line occurs only once!
        }
        else {
            # happens if there are only ignored --line directives
            App::Ack::die( 'All --line options are invalid.' );
        }
    }

    return \%opt;
}

=head2 def_types_from_ARGV

Go through the command line arguments and look for
I<--type-set foo=.foo,.bar> and I<--type-add xml=.rdf>.
Remove them from @ARGV and add them to the supported filetypes,
i.e. into %mappings, etc.

=cut

sub def_types_from_ARGV {
    my @typedef;

    my $parser = Getopt::Long::Parser->new();
        # pass_through   => leave unrecognized command line arguments alone
        # no_auto_abbrev => otherwise -c is expanded and not left alone
    $parser->configure( 'no_ignore_case', 'pass_through', 'no_auto_abbrev' );
    $parser->getoptions(
        'type-set=s' => sub { shift; push @typedef, ['c', shift] },
        'type-add=s' => sub { shift; push @typedef, ['a', shift] },
    ) or App::Ack::die( 'See ack --help or ack --man for options.' );

    for my $td (@typedef) {
        my ($type, $ext) = split /=/, $td->[1];

        if ( $td->[0] eq 'c' ) {
            # type-set
            if ( exists $mappings{$type} ) {
                # can't redefine types 'make', 'skipped', 'text' and 'binary'
                App::Ack::die( qq{--type-set: Builtin type "$type" cannot be changed.} )
                    if ref $mappings{$type} ne 'ARRAY';

                delete_type($type);
            }
        }
        else {
            # type-add

            # can't append to types 'make', 'skipped', 'text' and 'binary'
            App::Ack::die( qq{--type-add: Builtin type "$type" cannot be changed.} )
                if exists $mappings{$type} && ref $mappings{$type} ne 'ARRAY';

            App::Ack::warn( qq{--type-add: Type "$type" does not exist, creating with "$ext" ...} )
                unless exists $mappings{$type};
        }

        my @exts = split /,/, $ext;
        s/^\.// for @exts;

        if ( !exists $mappings{$type} || ref($mappings{$type}) eq 'ARRAY' ) {
            push @{$mappings{$type}}, @exts;
            for my $e ( @exts ) {
                push @{$types{$e}}, $type;
            }
        }
        else {
            App::Ack::die( qq{Cannot append to type "$type".} );
        }
    }

    return;
}

=head2 remove_dir_sep( $path )

This functions removes a trailing path separator, if there is one, from its argument

=cut

sub remove_dir_sep {
    my $path = shift;
    $path =~ s/[$dir_sep_chars]$//;

    return $path;
}

=head2 build_regex( $str, \%opts )

Returns a regex object based on a string and command-line options.

Dies when the regex $str is undefinied (i.e. not given on command line).

=cut

sub build_regex {
    my $str = shift;
    my $opt = shift;

    defined $str or App::Ack::die( 'No regular expression found.' );

    $str = quotemeta( $str ) if $opt->{Q};
    if ( $opt->{w} ) {
        $str = "\\b$str" if $str =~ /^\w/;
        $str = "$str\\b" if $str =~ /\w$/;
    }

    my $regex_is_lc = $str eq lc $str;
    if ( $opt->{i} || ($opt->{smart_case} && $regex_is_lc) ) {
        $str = "(?i)$str";
    }

    return $str;
}

=head2 check_regex( $regex_str )

Checks that the $regex_str can be compiled into a perl regular expression.
Dies with the error message if this is not the case.

No return value.

=cut

sub check_regex {
    my $regex = shift;

    return unless defined $regex;

    eval { qr/$regex/ };
    if ($@) {
        (my $error = $@) =~ s/ at \S+ line \d+.*//;
        chomp($error);
        App::Ack::die( "Invalid regex '$regex':\n  $error" );
    }

    return;
}



=head2 warn( @_ )

Put out an ack-specific warning.

=cut

sub warn { ## no critic (ProhibitBuiltinHomonyms)
    return CORE::warn( _my_program(), ': ', @_, "\n" );
}

=head2 die( @_ )

Die in an ack-specific way.

=cut

sub die { ## no critic (ProhibitBuiltinHomonyms)
    return CORE::die( _my_program(), ': ', @_, "\n" );
}

sub _my_program {
    require File::Basename;
    return File::Basename::basename( $0 );
}


=head2 filetypes_supported()

Returns a list of all the types that we can detect.

=cut

sub filetypes_supported {
    return keys %mappings;
}

sub _get_thpppt {
    my $y = q{_   /|,\\'!.x',=(www)=,   U   };
    $y =~ tr/,x!w/\nOo_/;
    return $y;
}

sub _thpppt {
    my $y = _get_thpppt();
    App::Ack::print( "$y ack $_[0]!\n" );
    exit 0;
}

=head2 show_help()

Dumps the help page to the user.

=cut

sub show_help {
    my $help_arg = shift || 0;

#   return show_help_types() if $help_arg =~ /^types?/;

    App::Ack::print( <<"END_OF_HELP" );
Usage: ack [OPTION]... PATTERN [FILE]

Search for PATTERN in each source file in the tree from cwd on down.
If [FILES] is specified, then only those files/directories are checked.
ack may also search STDIN, but only if no FILE are specified, or if
one of FILES is "-".

Default switches may be specified in ACK_OPTIONS environment variable or
an .ackrc file. If you want no dependency on the environment, turn it
off with --noenv.

Example: ack -i select

Searching:

Search output:

File presentation:

File finding:

File inclusion/exclusion:

Miscellaneous:
  --noenv               Ignore environment variables and ~/.ackrc
  --help                This help
  --man                 Man page
  --version             Display version & copyright
  --thpppt              Bill the Cat

Exit status is 0 if match, 1 if no match.

This is version $VERSION of ack.
END_OF_HELP

    return;
 }


=head2 show_help_types()

Display the filetypes help subpage.

=cut

sub show_help_types {
    App::Ack::print( <<'END_OF_HELP' );
Usage: ack [OPTION]... PATTERN [FILES]

The following is the list of filetypes supported by ack.  You can
specify a file type with the --type=TYPE format, or the --TYPE
format.  For example, both --type=perl and --perl work.

Note that some extensions may appear in multiple types.  For example,
.pod files are both Perl and Parrot.

END_OF_HELP

    my @types = filetypes_supported();
    my $maxlen = 0;
    for ( @types ) {
        $maxlen = length if $maxlen < length;
    }
    for my $type ( sort @types ) {
        next if $type =~ /^-/; # Stuff to not show
        my $ext_list = $mappings{$type};

        if ( ref $ext_list ) {
            $ext_list = join( ' ', map { ".$_" } @{$ext_list} );
        }
        App::Ack::print( sprintf( "    --[no]%-*.*s %s\n", $maxlen, $maxlen, $type, $ext_list ) );
    }

    return;
}

sub _listify {
    my @whats = @_;

    return '' if !@whats;

    my $end = pop @whats;
    my $str = @whats ? join( ', ', @whats ) . " and $end" : $end;

    no warnings 'once';
    require Text::Wrap;
    $Text::Wrap::columns = 75;
    return Text::Wrap::wrap( '', '    ', $str );
}

=head2 get_version_statement

Returns the version information for ack.

=cut

sub get_version_statement {
    require Config;

    my $copyright = get_copyright();
    my $this_perl = $Config::Config{perlpath};
    if ($^O ne 'VMS') {
        my $ext = $Config::Config{_exe};
        $this_perl .= $ext unless $this_perl =~ m/$ext$/i;
    }
    my $ver = sprintf( '%vd', $^V );

    return <<"END_OF_VERSION";
ack $VERSION
Running under Perl $ver at $this_perl

$copyright

This program is free software.  You may modify or distribute it
under the terms of the Artistic License v2.0.
END_OF_VERSION
}

=head2 print_version_statement

Prints the version information for ack.

=cut

sub print_version_statement {
    App::Ack::print( get_version_statement() );

    return;
}

=head2 get_copyright

Return the copyright for ack.

=cut

sub get_copyright {
    return $COPYRIGHT;
}

=head2 load_colors

Set default colors, load Term::ANSIColor

=cut

sub load_colors {
    eval 'use Term::ANSIColor ()';

    $ENV{ACK_COLOR_MATCH}    ||= 'black on_yellow';
    $ENV{ACK_COLOR_FILENAME} ||= 'bold green';
    $ENV{ACK_COLOR_LINENO}   ||= 'bold yellow';

    return;
}


# print subs added in order to make it easy for a third party
# module (such as App::Wack) to redefine the display methods
# and show the results in a different way.
sub print                   { print {$fh} @_ }
sub print_first_filename    { App::Ack::print( $_[0], "\n" ) }
sub print_blank_line        { App::Ack::print( "\n" ) }
sub print_separator         { App::Ack::print( "--\n" ) }
sub print_filename          { App::Ack::print( $_[0], $_[1] ) }
sub print_line_no           { App::Ack::print( $_[0], $_[1] ) }
sub print_column_no         { App::Ack::print( $_[0], $_[1] ) }
sub print_count {
    my $filename = shift;
    my $nmatches = shift;
    my $ors = shift;
    my $count = shift;
    my $show_filename = shift;

    if ($show_filename) {
        App::Ack::print( $filename );
        App::Ack::print( ':', $nmatches ) if $count;
    }
    else {
        App::Ack::print( $nmatches ) if $count;
    }
    App::Ack::print( $ors );
}

sub print_count0 {
    my $filename = shift;
    my $ors = shift;
    my $show_filename = shift;

    if ($show_filename) {
        App::Ack::print( $filename, ':0', $ors );
    }
    else {
        App::Ack::print( '0', $ors );
    }
}

sub set_up_pager {
    my $command = shift;

    return if App::Ack::output_to_pipe();

    my $pager;
    if ( not open( $pager, '|-', $command ) ) {
        App::Ack::die( qq{Unable to pipe to pager "$command": $!} );
    }
    $fh = $pager;

    return;
}

=head2 input_from_pipe()

Returns true if ack's input is coming from a pipe.

=cut

sub input_from_pipe {
    return $input_from_pipe;
}


=head2 output_to_pipe()

Returns true if ack's input is coming from a pipe.

=cut

sub output_to_pipe {
    return $output_to_pipe;
}

=head2 exit_from_ack

Exit from the application with the correct exit code.

Returns with 0 if a match was found, otherwise with 1. The number of matches is
handed in as the only argument.

=cut

sub exit_from_ack {
    my $nmatches = shift;

    my $rc = $nmatches ? 0 : 1;
    exit $rc;
}


=head1 COPYRIGHT & LICENSE

Copyright 2005-2011 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

=cut

1; # End of App::Ack
