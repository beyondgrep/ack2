package App::Ack;

use warnings;
use strict;

use App::Ack::ConfigFinder;
use Getopt::Long;
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

our $is_filter_mode;
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
    $is_filter_mode = -p STDIN;

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

    my $noenv;
    my $ackrc;

    Getopt::Long::Configure('default');
    Getopt::Long::Configure('pass_through');
    Getopt::Long::Configure('no_auto_abbrev');

    GetOptions(
        'noenv'   => \$noenv,
        'ackrc=s' => \$ackrc,
    );

    Getopt::Long::Configure('default');

    my @files;

    if ( !$noenv ) {
        my $finder = App::Ack::ConfigFinder->new;
        @files  = $finder->find_config_files;
    }
    if ( $ackrc ) {
        # we explicitly use open so we get a nice error message
        # XXX this is a potential race condition!
        if(open my $fh, '<', $ackrc) {
            close $fh;
        } else {
            die "Unable to load ackrc '$ackrc': $!"
        }
        push( @files, $ackrc );
    }

    foreach my $file ( @files) {
        my @lines = read_rcfile($file);
        push ( @arg_sources, $file, \@lines ) if @lines;
    }

    if ( $ENV{ACK_OPTIONS} && !$noenv ) {
        push( @arg_sources, 'ACK_OPTIONS' => $ENV{ACK_OPTIONS} );
    }

    push( @arg_sources, 'ARGV' => [ @ARGV ] );

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

sub warn {
    return CORE::warn( _my_program(), ': ', @_, "\n" );
}

=head2 die( @_ )

Die in an ack-specific way.

=cut

sub die {
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

sub _bar {
    my $x;
    $x = <<'_BAR';
 6?!I'7!I"?%+!
 3~!I#7#I"7#I!?!+!="+"="+!:!
 2?#I!7!I!?#I!7!I"+"=%+"=#
 1?"+!?*+!=#~"=!+#?"="+!
 0?"+!?"I"?&+!="~!=!~"=!+%="+"
 /I!+!?)+!?!+!=$~!=!~!="+!="+"?!="?!
 .?%I"?%+%='?!=#~$="
 ,,!?%I"?(+$=$~!=#:"~$:!~!
 ,I!?!I!?"I"?!+#?"+!?!+#="~$:!~!:!~!:!,!:!,":#~!
 +I!?&+!="+!?#+$=!~":!~!:!~!:!,!:#,!:!,%:"
 *+!I!?!+$=!+!=!+!?$+#=!~":!~":#,$:",#:!,!:!
 *I!?"+!?!+!=$+!?#+#=#~":$,!:",!:!,&:"
 )I!?$=!~!=#+"?!+!=!+!=!~!="~!:!~":!,'.!,%:!~!
 (=!?"+!?!=!~$?"+!?!+!=#~"=",!="~$,$.",#.!:!=!
 (I"+"="~"=!+&=!~"=!~!,!~!+!=!?!+!?!=!I!?!+"=!.",!.!,":!
 %I$?!+!?!=%+!~!+#~!=!~#:#=!~!+!~!=#:!,%.!,!.!:"
 $I!?!=!?!I!+!?"+!=!~!=!~!?!I!?!=!+!=!~#:",!~"=!~!:"~!=!:",&:" '-/
 $?!+!I!?"+"=!+"~!,!:"+#~#:#,"=!~"=!,!~!,!.",!:".!:! */! !I!t!'!s! !a! !g!r!e!p!!! !/!
 $+"=!+!?!+"~!=!:!~!:"I!+!,!~!=!:!~!,!:!,$:!~".&:"~!,# (-/
 %~!=!~!=!:!.!+"~!:!,!.!,!~!=!:$.!,":!,!.!:!~!,!:!=!.#="~!,!:" ./!
 %=!~!?!+"?"+!=!~",!.!:!?!~!.!:!,!:!,#.!,!:","~!:!=!~!=!:",!~! ./!
 %+"~":!~!=#~!:!~!,!.!~!:",!~!=!~!.!:!,!.",!:!,":!=":!.!,!:!7! -/!
 %~",!:".#:!=!:!,!:"+!:!~!:!.!,!~!,!.#,!.!,$:"~!,":"~!=! */!
 &=!~!=#+!=!~",!.!:",#:#,!.",+:!,!.",!=!+!?!
 &~!=!~!=!~!:"~#:",!.!,#~!:!.!+!,!.",$.",$.#,!+!I!?!
 &~!="~!:!~":!~",!~!=!~":!,!:!~!,!:!,&.$,#."+!?!I!?!I!
 &~!=!~!=!+!,!:!~!:!=!,!:!~&:$,!.!,".!,".!,#."~!+!?$I!
 &~!=!~!="~!=!:!~":!,!~%:#,!:",!.!,#.",#I!7"I!?!+!?"I"
 &+!I!7!:#~"=!~!:!,!:"~$.!=!.!,!~!,$.#,!~!7!I#?!+!?"I"7!
 %7#?!+!~!:!=!~!=!~":!,!:"~":#.!,)7#I"?"I!7&
 %7#I!=":!=!~!:"~$:"~!:#,!:!,!:!~!:#,!7#I!?#7)
 $7$+!,!~!=#~!:!~!:!~$:#,!.!~!:!=!,":!7#I"?#7+=!?!
 $7#I!~!,!~#=!~!:"~!:!,!:!,#:!=!~",":!7$I!?#I!7*+!=!+"
 "I!7$I!,":!,!.!=":$,!:!,$:$7$I!+!?"I!7+?"I!7!I!7!,!
 !,!7%I!:",!."~":!,&.!,!:!~!I!7$I!+!?"I!7,?!I!7',!
 !7(,!.#~":!,%.!,!7%I!7!?#I"7,+!?!7*
7+:!,!~#,"=!7'I!?#I"7/+!7+
77I!+!7!?!7!I"71+!7,
_BAR

    $x =~ s/(.)(.)/$1x(ord($2)-32)/eg;
    App::Ack::print( $x );
    exit 0;
}

=head2 show_help()

Dumps the help page to the user.

=cut

sub show_help {
    my $help_arg = shift || 0;

#   return show_help_types() if $help_arg =~ /^types?/;

    App::Ack::print( <<"END_OF_HELP" );
Usage: ack [OPTION]... PATTERN [FILES OR DIRECTORIES]

Search for PATTERN in each source file in the tree from the current
directory on down.  If any files or directories are specified, then
only those files and directories are checked.  ack may also search
STDIN, but only if no file or directory arguments are specified,
or if one of them is "-".

Default switches may be specified in ACK_OPTIONS environment variable or
an .ackrc file. If you want no dependency on the environment, turn it
off with --noenv.

Example: ack -i select

Searching:
  -i, --ignore-case     Ignore case distinctions in PATTERN
  --[no]smart-case      Ignore case distinctions in PATTERN,
                        only if PATTERN contains no upper case
                        Ignored if -i is specified
  -v, --invert-match    Invert match: select non-matching lines
  -w, --word-regexp     Force PATTERN to match only whole words
  -Q, --literal         Quote all metacharacters; PATTERN is literal

Search output:
  --line=NUM            Only print line(s) NUM of each file
  -l, --files-with-matches
                        Only print filenames containing matches
  -L, --files-without-matches
                        Only print filenames with no matches
  -o                    Show only the part of a line matching PATTERN
                        (turns off text highlighting)
  --passthru            Print all lines, whether matching or not
  --output=expr         Output the evaluation of expr for each line
                        (turns off text highlighting)
  --match PATTERN       Specify PATTERN explicitly.
  -m, --max-count=NUM   Stop searching in each file after NUM matches
  -1                    Stop searching after one match of any kind
  -H, --with-filename   Print the filename for each match
  -h, --no-filename     Suppress the prefixing filename on output
  -c, --count           Show number of lines matching per file
  --column              Show the column number of the first match

  -A NUM, --after-context=NUM
                        Print NUM lines of trailing context after matching
                        lines.
  -B NUM, --before-context=NUM
                        Print NUM lines of leading context before matching
                        lines.
  -C [NUM], --context[=NUM]
                        Print NUM lines (default 2) of output context.

  --print0              Print null byte as separator between filenames,
                        only works with -f, -g, -l, -L or -c.


File presentation:
  --pager=COMMAND       Pipes all ack output through COMMAND.  For example,
                        --pager="less -R".  Ignored if output is redirected.
  --nopager             Do not send output through a pager.  Cancels any
                        setting in ~/.ackrc, ACK_PAGER or ACK_PAGER_COLOR.
  --[no]heading         Print a filename heading above each file's results.
                        (default: on when used interactively)
  --[no]break           Print a break between results from different files.
                        (default: on when used interactively)
  --group               Same as --heading --break
  --nogroup             Same as --noheading --nobreak
  --[no]color           Highlight the matching text (default: on unless
                        output is redirected, or on Windows)
  --[no]colour          Same as --[no]color
  --color-filename=COLOR
  --color-match=COLOR
  --color-lineno=COLOR  Set the color for filenames, matches, and line numbers.
  --flush               Flush output immediately, even when ack is used
                        non-interactively (when output goes to a pipe or
                        file).


File finding:
  -f                    Only print the files found, without searching.
                        The PATTERN must not be specified.
  -g                    Same as -f, but only print files matching PATTERN.
  --sort-files          Sort the found files lexically.
  --show-types          Show which types each file has.

File inclusion/exclusion:
  --[no]ignore-dir=name Add/Remove directory from the list of ignored dirs
  -r, -R, --recurse     Recurse into subdirectories (ack's default behavior)
  -n, --no-recurse      No descending into subdirectories

  --type=X              Include only X files, where X is a recognized filetype.
  --type=noX            Exclude X files.
                        See "ack --help type" for supported filetypes.

  --type-set TYPE=.EXTENSION[,.EXT2[,...]]
                        Files with the given EXTENSION(s) are recognized as
                        being of type TYPE. This replaces an existing
                        definition for type TYPE.
  --type-add TYPE=.EXTENSION[,.EXT2[,...]]
                        Files with the given EXTENSION(s) are recognized as
                        being of (the existing) type TYPE

  --[no]follow          Follow symlinks.  Default is off.


Miscellaneous:
  --noenv               Ignore environment variables and global ackrc files
  --ackrc=filename      Specify an ackrc file to use
  --help                This help
  --dump                Dump information on which options are loaded from which RC files
  --man                 Man page
  --version             Display version & copyright
  --thpppt              Bill the Cat
  --bar                 The warning admiral

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
Usage: ack [OPTION]... PATTERN [FILES OR DIRECTORIES]

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
sub print                   { print {$fh} @_; return; }
sub print_first_filename    { App::Ack::print( $_[0], "\n" ); return; }
sub print_blank_line        { App::Ack::print( "\n" ); return; }
sub print_separator         { App::Ack::print( "--\n" ); return; }
sub print_filename          { App::Ack::print( $_[0], $_[1] ); return; }
sub print_line_no           { App::Ack::print( $_[0], $_[1] ); return; }
sub print_column_no         { App::Ack::print( $_[0], $_[1] ); return; }
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

    return;
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

    return;
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

{

my @capture_indices;
my $match_column_number;

sub does_match {
    my ( $opt, $line ) = @_;

    my $re     = $opt->{regex};
    my $invert = $opt->{v};

    $match_column_number = undef;
    @capture_indices     = ();

    if ( $invert ? $line !~ /$re/ : $line =~ /$re/ ) {
        if ( not $invert ) {
            use English '-no_match_vars';

            $match_column_number = $LAST_MATCH_START[0] + 1;

            if ( @LAST_MATCH_START > 1 ) {
                @capture_indices = map {
                    [ $LAST_MATCH_START[$_], $LAST_MATCH_END[$_] ]
                } ( 1 .. $#LAST_MATCH_START );
            }
        }
        return 1;
    }
    else {
        return;
    }
}

sub get_capture_indices {
    return @capture_indices;
}

sub get_match_column {
    return $match_column_number;
}

}

sub print_matches_in_resource {
    my ( $resource, $opt ) = @_;

    my $passthru  = $opt->{passthru};
    my $max_count = $opt->{m} || -1;
    my $nmatches  = 0;
    my $filename  = $resource->name;
    my $break     = $opt->{break};
    my $heading   = $opt->{heading};
    my $ors       = $opt->{print0} ? "\0" : "\n";
    my $color     = $opt->{color};

    my $has_printed_for_this_resource = 0;

    App::Ack::iterate($resource, $opt, sub {
        if ( App::Ack::does_match($opt, $_) ) {
            if( !$has_printed_for_this_resource ) {
                if( $break && has_printed_something() ) {
                    App::Ack::print_blank_line();
                }
                if( $heading ) {
                    my $filename = $resource->name;
                    if($color) {
                        $filename = Term::ANSIColor::colored($filename,
                            $ENV{ACK_COLOR_FILENAME});
                    }
                    App::Ack::print_filename( $filename, $ors );
                }
            }
            App::Ack::print_line_with_context($opt, $filename, $_, $.);
            $has_printed_for_this_resource = 1;
            $nmatches++;
            $max_count--;
        }
        elsif ( $passthru ) {
            chomp;
            if( $break && !$has_printed_for_this_resource && has_printed_something() ) {
                App::Ack::print_blank_line();
            }
            App::Ack::print_line_with_options($opt, $filename, $_, $., ':');
            $has_printed_for_this_resource = 1;
        }
        return $max_count != 0;
    });

    return $nmatches;
}

sub count_matches_in_resource {
    my ( $resource, $opt ) = @_;

    my $nmatches = 0;

    App::Ack::iterate( $resource, $opt, sub {
        ++$nmatches if App::Ack::does_match($opt, $_);
        return 1;
    } );

    return $nmatches;
}

sub resource_has_match {
    my ( $resource, $opt ) = @_;

    my $stash_v = $opt->{v};
    $opt->{v} = 0;

    my $n = count_matches_in_resource($resource, $opt) > 0;

    $opt->{v} = $stash_v;

    return $n;
}

{

my @before_ctx_lines;
my @after_ctx_lines;
my $is_iterating;

sub get_context {
    if ( not $is_iterating ) {
        Carp::croak( 'get_context() called outside of iterate()' );
    }

    return (
        scalar(@before_ctx_lines) ? \@before_ctx_lines : undef,
        scalar(@after_ctx_lines)  ? \@after_ctx_lines  : undef,
    );
}

sub iterate {
    my ( $resource, $opt, $cb ) = @_;

    $is_iterating = 1;

    local $opt->{before_context} = $opt->{output} ? 0 : $opt->{before_context};
    local $opt->{after_context}  = $opt->{output} ? 0 : $opt->{after_context};

    my $n_before_ctx_lines = $opt->{before_context} || 0;
    my $n_after_ctx_lines  = $opt->{after_context}  || 0;
    my $current_line;

    @after_ctx_lines = @before_ctx_lines = ();

    if ( $resource->next_text() ) {
        $current_line = $_; # prime the first line of input
    }

    while ( defined $current_line ) {
        while ( (@after_ctx_lines < $n_after_ctx_lines) && $resource->next_text() ) {
            push @after_ctx_lines, $_;
        }

        local $_ = $current_line;
        local $. = $. - @after_ctx_lines;

        last unless $cb->();

        push @before_ctx_lines, $current_line;

        if($n_after_ctx_lines) {
            $current_line = shift @after_ctx_lines;
        }
        elsif($resource->next_text()) {
            $current_line = $_;
        }
        else {
            undef $current_line;
        }
        shift @before_ctx_lines while @before_ctx_lines > $n_before_ctx_lines;
    }

    $is_iterating = 0;

    return;
}

}

my $has_printed_something;

BEGIN {
    $has_printed_something = 0;
}

sub has_printed_something {
    return $has_printed_something;
}

sub print_line_with_options {
    my ( $opt, $filename, $line, $line_no, $separator ) = @_;

    $has_printed_something = 1;

    my $print_filename = $opt->{H} && !$opt->{h};
    my $print_column   = $opt->{column};
    my $ors            = $opt->{print0} ? "\0" : "\n";
    my $heading        = $opt->{heading};
    my $output_expr    = $opt->{output};
    my $re             = $opt->{regex};

    my @line_parts;

    if($print_filename) {
        if( $heading ) {
            push @line_parts, $line_no;
        }
        else {
            push @line_parts, $filename, $line_no;
        }

        if( $print_column ) {
            push @line_parts, get_match_column();
        }
    }
    if( $output_expr ) {
        # XXX avoid re-evaluation if we can
        while( $line =~ /$re/g ) {
            my $output = eval qq{"$output_expr"};
            App::Ack::print( join( $separator, @line_parts, $output ), $ors );
        }
    }
    else {
        push @line_parts, $line;
        App::Ack::print( join( $separator, @line_parts ), $ors );
    }

    return;
}

{

my $is_first_match;
my $previous_file_processed;
my $previous_line_printed;

BEGIN {
    $is_first_match        = 1;
    $previous_line_printed = -1;
}

sub print_line_with_context {
    my ( $opt, $filename, $matching_line, $line_no ) = @_;

    my $heading = $opt->{heading};

    if( !defined($previous_file_processed) ||
      $previous_file_processed ne $filename ) {
        $previous_file_processed = $filename;
        $previous_line_printed   = -1;

        if( $heading ) {
            $is_first_match = 1;
        }
    }

    my $ors                 = $opt->{print0} ? "\0" : "\n";
    my $color               = $opt->{color};
    my $match_word          = $opt->{w};
    my $re                  = $opt->{regex};
    my $is_tracking_context = $opt->{after_context} || $opt->{before_context};
    my $output_expr         = $opt->{output};

    chomp $matching_line;

    my ( $before_context, $after_context ) = get_context();

    if($before_context) {
        my $first_line = $. - @{$before_context};
        if( !$is_first_match && $previous_line_printed != $first_line - 1 ) {
            App::Ack::print('--', $ors);
        }
        $previous_line_printed = $.; # XXX unless --after-context
        my $offset = @{$before_context};
        foreach my $line (@{$before_context}) {
            chomp $line;
            App::Ack::print_line_with_options($opt, $filename, $line, $. - $offset, '-');
            $previous_line_printed = $. - $offset;
            $offset--;
        }
    }

    if( $is_tracking_context && !$is_first_match && $previous_line_printed != $. - 1 ) {
        App::Ack::print('--', $ors);
    }

    if($color) {
        $filename = Term::ANSIColor::colored($filename,
            $ENV{ACK_COLOR_FILENAME});
        $line_no  = Term::ANSIColor::colored($line_no,
            $ENV{ACK_COLOR_LINENO});
    }

    my @capture_indices  = get_capture_indices();
    if( @capture_indices && !$output_expr ) {
        my $offset = 0; # additional offset for when we add stuff

        foreach my $index_pair ( @capture_indices ) {
            my ( $match_start, $match_end ) = @{$index_pair};

            my $substring = substr( $matching_line,
                $offset + $match_start, $match_end - $match_start );
            my $substitution = Term::ANSIColor::colored( $substring,
                $ENV{ACK_COLOR_MATCH} );

            substr( $matching_line, $offset + $match_start,
                $match_end - $match_start, $substitution );

            $offset += length( $substitution ) - length( $substring );
        }
    }
    elsif($color) {
        # XXX I know $& is a no-no; fix it later
        $matching_line  =~ s/$re/Term::ANSIColor::colored($&, $ENV{ACK_COLOR_MATCH})/ge;
        $matching_line .= "\033[0m\033[K";
    }

    App::Ack::print_line_with_options($opt, $filename, $matching_line, $line_no, ':');
    $previous_line_printed = $.;

    if($after_context) {
        my $offset = 1;
        foreach my $line (@{$after_context}) {
            chomp $line;
            App::Ack::print_line_with_options($opt, $filename, $line, $. + $offset, '-');
            $previous_line_printed = $. + $offset;
            $offset++;
        }
    }

    $is_first_match = 0;
}

}


=head1 COPYRIGHT & LICENSE

Copyright 2005-2011 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

=cut

1; # End of App::Ack
