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

sub retrieve_arg_sources {
    my @arg_sources;

    my @files = ( $ENV{ACKRC} );

    my @maybe_dirs;
    my @maybe_files;
    if ( $App::Ack::is_windows ) {
        @maybe_dirs  = ( $ENV{HOME}, $ENV{USERPROFILE} );
        @maybe_files = ( '.ackrc', '_ackrc' );
    }
    else {
        @maybe_dirs  = ( '~', $ENV{HOME} );
        @maybe_files = ( '.ackrc' );
    }
    CHECK_FILES: for my $maybe_dir ( grep { defined } @maybe_dirs ) {
        for my $maybe_file ( @maybe_files ) {
            my $file = "$maybe_dir/$maybe_file";
            my @lines = read_rcfile( $file );
            if ( @lines ) {
                push( @arg_sources, $file, \@lines );
                last CHECK_FILES;
            }
        }
    }

    if ( $ENV{ACK_OPTIONS} ) {
        push( @arg_sources, 'ACK_OPTIONS', $ENV{ACK_OPTIONS} );
    }

    push( @arg_sources, 'ARGV', [ @ARGV ] );

    return @arg_sources;
}

sub read_rcfile {
    my $file = shift;

    return unless defined $file && -e $file;

    my @lines;

    open( my $fh, '<', $file ) or App::Ack::die( "Unable to read $file: $!" );
    while ( my $line = <$fh> ) {
        chomp $line;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        next if $line eq '';
        next if $line =~ /^#/;

        push( @lines, $line );
    }
    close $fh;

    return @lines;
}

sub process_args {
    my @arg_sources = @_;

    # First get the argtypes

    Getopt::Long::Configure( 'no_ignore_case', 'pass_through', 'no_auto_abbrev' );
    # pass_through   => leave unrecognized command line arguments alone
    # no_auto_abbrev => otherwise -c is expanded and not left alone

    my @idirs;
    my @ifiles;
    my @types;

    my %type_arg_specs = (
        'type-add=s' => sub { shift; push @types, shift; },
        'type-set=s' => sub { shift; push @types, shift; },
    );
    my @leftovers;
    while ( @arg_sources ) {
        my ($source_name, $args) = splice( @arg_sources, 0, 2 );

        my $ret;
        if ( ref($args) ) {
            $ret = Getopt::Long::GetOptionsFromArray( $args, %type_arg_specs );
        }
        else {
            ($ret, $args) = Getopt::Long::GetOptionsFromString( $args, %type_arg_specs );
        }
        $ret || die "Return code $ret is false, but never should be";
        push( @leftovers, $source_name, $args );
    }

    Getopt::Long::Configure( 'no_pass_through' );

    my %opt;
    my %arg_specs = (
        1                   => sub { $opt{1} = $opt{m} = 1 },
        'A|after-context=i' => \$opt{after_context},
        'B|before-context=i'
                            => \$opt{before_context},
        'C|context:i'       => sub { shift; my $val = shift; $opt{before_context} = $opt{after_context} = ($val || 2) },
        'a|all-types'       => \$opt{all},
        'break!'            => \$opt{break},
        c                   => \$opt{count},
        'color|colour!'     => \$opt{color},
        'color-match=s'     => \$ENV{ACK_COLOR_MATCH},
        'color-filename=s'  => \$ENV{ACK_COLOR_FILENAME},
        'color-lineno=s'    => \$ENV{ACK_COLOR_LINENO},
        'column!'           => \$opt{column},
        count               => \$opt{count},
        'env!'              => sub { }, # ignore this option, it is handled beforehand
        f                   => \$opt{f},
        flush               => \$opt{flush},
        'follow!'           => \$opt{follow},
        'g=s'               => sub { shift; $opt{G} = shift; $opt{f} = 1 },
        'G=s'               => \$opt{G},
        'group!'            => sub { shift; $opt{heading} = $opt{break} = shift },
        'heading!'          => \$opt{heading},
        'h|no-filename'     => \$opt{h},
        'H|with-filename'   => \$opt{H},
        'i|ignore-case'     => \$opt{i},
        'ignore-directory|ignore-dir=s'
                            => sub { shift; push @idirs,  shift; },
        'ignore-file=s'     => sub { shift; push @ifiles, shift; },
        'invert-file-match' => \$opt{invert_file_match},
        'lines=s'           => sub { shift; my $val = shift; push @{$opt{lines}}, $val },
        'l|files-with-matches'
                            => \$opt{l},
        'L|files-without-matches'
                            => sub { $opt{l} = $opt{v} = 1 },
        'm|max-count=i'     => \$opt{m},
        'match=s'           => \$opt{regex},
        'n|no-recurse'      => \$opt{n},
        o                   => sub { $opt{output} = '$&' },
        'output=s'          => \$opt{output},
        'pager=s'           => \$opt{pager},
        'nopager'           => sub { $opt{pager} = undef },
        'passthru'          => \$opt{passthru},
        'print0'            => \$opt{print0},
        'Q|literal'         => \$opt{Q},
        'r|R|recurse'       => sub { $opt{n} = 0 },
        'show-types'        => \$opt{show_types},
        'smart-case!'       => \$opt{smart_case},
        'sort-files'        => \$opt{sort_files},
        'u|unrestricted'    => \$opt{u},
        'v|invert-match'    => \$opt{v},
        'w|word-regexp'     => \$opt{w},

        'version'           => sub { App::Ack::print_version_statement(); exit; },
        'help|?:s'          => sub { shift; App::Ack::show_help(@_); exit; },
        'help-types'        => sub { App::Ack::show_help_types(); exit; },
        'man'               => sub {
            require Pod::Usage;
            Pod::Usage::pod2usage({
                -verbose => 2,
                -exitval => 0,
            });
        }, # man sub
    );

    while ( @leftovers ) {
        my ($source_name, $args) = splice( @leftovers, 0, 2 );

        my $ret;
        if ( ref($args) ) {
            $ret = Getopt::Long::GetOptionsFromArray( $args, %arg_specs );
        }
        else {
            $ret = Getopt::Long::GetOptionsFromString( $args, %arg_specs );
        }
        if ( !$ret ) {
            my $where = $source_name eq 'ARGV' ? 'on command line' : "in $source_name";
            App::Ack::die( "Invalid option $where" );
        }
    }

    # XXX
    # At this point, none of the sources should have unparsed args except for @ARGV.
    # If any sources other than @ARGV have stuff in them, then throw an error.
    # Otherwise, put what's left from @ARGV source into @ARGV.
    # Also we need to check on a -- in the middle of a non-ARGV source

    return \%opt;
}

=head2 create_ignore_rules( $what, $where, \@opts )

Takes an array of options passed in on the command line and returns
a hashref of information about them:

* 
# is:  Match the filename exactly
# ext: Match the extension
# regex: Match against a Perl regular expression

=cut

sub create_ignore_rules {
    my $what  = shift;
    my $where = shift;
    my $opts  = shift;

    my @opts = @{$opts};

    my %rules = {
    };

    for my $opt ( @opts ) {
        if ( $opt =~ /^(is|ext|regex),(.+)$/ ) {
            my $method = $1;
            my $arg    = $2;
            if ( $method eq 'regex' ) {
                push( @{$rules{regex}}, qr/$arg/ );
            }
            else {
                ++$rules{$method}{$arg};
            }
        }
        else {
            App::Ack::die( "Invalid argument for --$what: $opt" );
        }
    }

    return \%rules;
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
