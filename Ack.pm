package App::Ack;

use warnings;
use strict;

use App::Ack::ConfigDefault;
use App::Ack::ConfigFinder;
use Getopt::Long 2.35 ();
use File::Next 1.10;

=head1 NAME

App::Ack - A container for functions for the ack program

=head1 VERSION

Version 2.0301

=cut

our $VERSION;
our $GIT_REVISION;
our $COPYRIGHT;
BEGIN {
    $VERSION = '2.0301';
    $COPYRIGHT = 'Copyright 2005-2013 Andy Lester.';
    $GIT_REVISION = '';
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

use File::Spec 1.00015 ();
use File::Glob 1.00015 ':glob';

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

    Getopt::Long::Configure('default', 'no_auto_help', 'no_auto_version');
    Getopt::Long::Configure('pass_through');
    Getopt::Long::Configure('no_auto_abbrev');

    Getopt::Long::GetOptions(
        'noenv'   => \$noenv,
        'ackrc=s' => \$ackrc,
    );

    Getopt::Long::Configure('default', 'no_auto_help', 'no_auto_version');

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
        }
        else {
            die "Unable to load ackrc '$ackrc': $!"
        }
        push( @files, $ackrc );
    }

    push @arg_sources, Defaults => [ App::Ack::ConfigDefault::options() ];

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

    my %rules;

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

    my $re = eval { qr/$str/o };
    if ( !$re ) {
        die "Invalid regex '$str':\n  $@";
    }

    return $re;

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

    return show_help_types() if $help_arg =~ /^types?/;

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
  -i, --ignore-case             Ignore case distinctions in PATTERN
  --[no]smart-case              Ignore case distinctions in PATTERN,
                                only if PATTERN contains no upper case.
                                Ignored if -i is specified
  -v, --invert-match            Invert match: select non-matching lines
  -w, --word-regexp             Force PATTERN to match only whole words
  -Q, --literal                 Quote all metacharacters; PATTERN is literal

Search output:
  --lines=NUM                   Only print line(s) NUM of each file
  -l, --files-with-matches      Only print filenames containing matches
  -L, --files-without-matches   Only print filenames with no matches
  --output=expr                 Output the evaluation of expr for each line
                                (turns off text highlighting)
  -o                            Show only the part of a line matching PATTERN
                                Same as --output='\$&'
  --passthru                    Print all lines, whether matching or not
  --match PATTERN               Specify PATTERN explicitly.
  -m, --max-count=NUM           Stop searching in each file after NUM matches
  -1                            Stop searching after one match of any kind
  -H, --with-filename           Print the filename for each match (default:
                                on unless explicitly searching a single file)
  -h, --no-filename             Suppress the prefixing filename on output
  -c, --count                   Show number of lines matching per file
  --[no]column                  Show the column number of the first match

  -A NUM, --after-context=NUM   Print NUM lines of trailing context after matching
                                lines.
  -B NUM, --before-context=NUM  Print NUM lines of leading context before matching
                                lines.
  -C [NUM], --context[=NUM]     Print NUM lines (default 2) of output context.

  --print0                      Print null byte as separator between filenames,
                                only works with -f, -g, -l, -L or -c.

  -s                            Suppress error messages about nonexistent or
                                unreadable files.


File presentation:
  --pager=COMMAND               Pipes all ack output through COMMAND.  For example,
                                --pager="less -R".  Ignored if output is redirected.
  --nopager                     Do not send output through a pager.  Cancels any
                                setting in ~/.ackrc, ACK_PAGER or ACK_PAGER_COLOR.
  --[no]heading                 Print a filename heading above each file's results.
                                (default: on when used interactively)
  --[no]break                   Print a break between results from different files.
                                (default: on when used interactively)
  --group                       Same as --heading --break
  --nogroup                     Same as --noheading --nobreak
  --[no]color                   Highlight the matching text (default: on unless
                                output is redirected, or on Windows)
  --[no]colour                  Same as --[no]color
  --color-filename=COLOR
  --color-match=COLOR
  --color-lineno=COLOR          Set the color for filenames, matches, and line numbers.
  --flush                       Flush output immediately, even when ack is used
                                non-interactively (when output goes to a pipe or
                                file).


File finding:
  -f                            Only print the files selected, without searching.
                                The PATTERN must not be specified.
  -g                            Same as -f, but only select files matching PATTERN.
  --sort-files                  Sort the found files lexically.
  --show-types                  Show which types each file has.
  --files-from=FILE             Read the list of files to search from FILE.
  -x                            Read the list of files to search from STDIN.

File inclusion/exclusion:
  --[no]ignore-dir=name         Add/Remove directory from the list of ignored dirs
  --[no]ignore-directory=name   Synonym for ignore-dir
  --ignore-file=filter          Add filter for ignoring files
  -r, -R, --recurse             Recurse into subdirectories (ack's default behavior)
  -n, --no-recurse              No descending into subdirectories
  --[no]follow                  Follow symlinks.  Default is off.
  -k, --known-types             Include only files with types that ack recognizes.

  --type=X                      Include only X files, where X is a recognized filetype.
  --type=noX                    Exclude X files.
                                See "ack --help-types" for supported filetypes.

File type specification:
  --type-set TYPE:FILTER:FILTERARGS
                                Files with the given FILTERARGS applied to the given
                                FILTER are recognized as being of type TYPE. This
                                replaces an existing definition for type TYPE.
  --type-add TYPE:FILTER:FILTERARGS
                                Files with the given FILTERARGS applied to the given
                                FILTER are recognized as being of type TYPE.
  --type-del TYPE               Removes all filters associated with TYPE.


Miscellaneous:
  --[no]env                     Ignore environment variables and global ackrc files.  --env is legal but redundant.
  --ackrc=filename              Specify an ackrc file to use
  --ignore-ack-defaults         Ignore the default definitions that ack includes.
  --create-ackrc                Outputs a default ackrc for your customization to standard output.
  --help, -?                    This help
  --help-types                  Display all known types
  --dump                        Dump information on which options are loaded from which RC files
  --[no]filter                  Force ack to treat standard input as a pipe (--filter) or tty (--nofilter)
  --man                         Man page
  --version                     Display version & copyright
  --thpppt                      Bill the Cat
  --bar                         The warning admiral

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
            $ext_list = join( '; ', map { $_->to_string } @{$ext_list} );
        }
        App::Ack::print( sprintf( "    --[no]%-*.*s %s\n", $maxlen, $maxlen, $type, $ext_list ) );
    }

    return;
}

sub show_man {
    require Pod::Usage;

    Pod::Usage::pod2usage({
        -input   => $App::Ack::orig_program_name,
        -verbose => 2,
        -exitval => 0,
    });

    return;
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

    my $git_revision = $GIT_REVISION ? " (git commit $GIT_REVISION)" : '';

    return <<"END_OF_VERSION";
ack ${VERSION}${git_revision}
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
    eval 'use Term::ANSIColor 1.10 ()';

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

    my $re = $opt->{regex} or return;

    $match_column_number = undef;
    @capture_indices     = ();

    if ( $opt->{v} ) {
        return ( $line !~ $re );
    }
    else {
        if ( $line =~ /$re/o ) {
            # @- = @LAST_MATCH_START
            # @+ = @LAST_MATCH_END
            $match_column_number = $-[0] + 1;

            if ( @- > 1 ) {
                @capture_indices = map {
                    [ $-[$_], $+[$_] ]
                } ( 1 .. $#- );
            }
            return 1;
        }
        else {
            return;
        }
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

    my $passthru       = $opt->{passthru};
    my $max_count      = $opt->{m} || -1;
    my $nmatches       = 0;
    my $filename       = $resource->name;
    my $break          = $opt->{break};
    my $heading        = $opt->{heading};
    my $ors            = $opt->{print0} ? "\0" : "\n";
    my $color          = $opt->{color};
    my $print_filename = $opt->{show_filename};

    my $has_printed_for_this_resource = 0;

    App::Ack::iterate($resource, $opt, sub {
        if ( App::Ack::does_match($opt, $_) ) {
            if( !$has_printed_for_this_resource ) {
                if( $break && has_printed_something() ) {
                    App::Ack::print_blank_line();
                }
                if( $print_filename) {
                    if( $heading ) {
                        my $filename = $resource->name;
                        if($color) {
                            $filename = Term::ANSIColor::colored($filename,
                                $ENV{ACK_COLOR_FILENAME});
                        }
                        App::Ack::print_filename( $filename, $ors );
                    }
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

    return count_matches_in_resource($resource, $opt) > 0;
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
        my $former_dot_period = $.;
        $. = $. - @after_ctx_lines;

        last unless $cb->();

        # I tried doing this with local(), but for some reason,
        # $. continued to have its new value after the exit of the
        # enclosing block.  I'm guessing that $. has some extra
        # magic associated with it or something.  If someone can
        # tell me why this happened, I would love to know!
        $. = $former_dot_period; # XXX this won't happen on an exception

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

    $is_iterating = 0; # XXX this won't happen on an exception
                       #     then again, do we care? ack doesn't really
                       #     handle exceptions anyway.

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

    my $print_filename = $opt->{show_filename};
    my $print_column   = $opt->{column};
    my $ors            = $opt->{print0} ? "\0" : "\n";
    my $heading        = $opt->{heading};
    my $output_expr    = $opt->{output};
    my $color          = $opt->{color};

    my @line_parts;

    if( $color ) {
        $filename = Term::ANSIColor::colored($filename,
            $ENV{ACK_COLOR_FILENAME});
        $line_no  = Term::ANSIColor::colored($line_no,
            $ENV{ACK_COLOR_LINENO});
    }

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
        my $re = $opt->{regex};
        while ( $line =~ /$re/og ) {
            my $output = eval $output_expr;
            App::Ack::print( join( $separator, @line_parts, $output ), $ors );
        }
    }
    else {
        if ( $color ) {
            my @capture_indices = get_capture_indices();
            if( @capture_indices ) {
                my $offset = 0; # additional offset for when we add stuff

                foreach my $index_pair ( @capture_indices ) {
                    my ( $match_start, $match_end ) = @{$index_pair};

                    my $substring = substr( $line,
                        $offset + $match_start, $match_end - $match_start );
                    my $substitution = Term::ANSIColor::colored( $substring,
                        $ENV{ACK_COLOR_MATCH} );

                    substr( $line, $offset + $match_start,
                        $match_end - $match_start, $substitution );

                    $offset += length( $substitution ) - length( $substring );
                }
            }
            else {
                my $matched = 0; # flag; if matched, need to escape afterwards

                my $re = $opt->{regex};
                while ( $line =~ /$re/og ) {

                    $matched = 1;
                    my ( $match_start, $match_end ) = ($-[0], $+[0]);

                    my $substring = substr( $line, $match_start,
                        $match_end - $match_start );
                    my $substitution = Term::ANSIColor::colored( $substring,
                        $ENV{ACK_COLOR_MATCH} );

                    substr( $line, $match_start, $match_end - $match_start,
                        $substitution );

                    pos($line) = $match_end +
                    (length( $substitution ) - length( $substring ));
                }
                $line .= "\033[0m\033[K" if $matched;
            }
        }

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
    my $match_word          = $opt->{w};
    my $is_tracking_context = $opt->{after_context} || $opt->{before_context};
    my $output_expr         = $opt->{output};

    chomp $matching_line;

    my ( $before_context, $after_context ) = get_context();

    if ( $before_context ) {
        my $first_line = $. - @{$before_context};

        if ( $first_line <= $previous_line_printed ) {
            splice @{$before_context}, 0, $previous_line_printed - $first_line + 1;
            $first_line = $. - @{$before_context};
        }
        if ( @{$before_context} ) {
            my $offset = @{$before_context};

            if( !$is_first_match && $previous_line_printed != $first_line - 1 ) {
                App::Ack::print('--', $ors);
            }
            foreach my $line (@{$before_context}) {
                my $context_line_no = $. - $offset;
                if ( $context_line_no <= $previous_line_printed ) {
                    next;
                }

                chomp $line;
                App::Ack::print_line_with_options($opt, $filename, $line, $context_line_no, '-');
                $previous_line_printed = $context_line_no;
                $offset--;
            }
        }
    }

    if ( $. > $previous_line_printed ) {
        if( $is_tracking_context && !$is_first_match && $previous_line_printed != $. - 1 ) {
            App::Ack::print('--', $ors);
        }

        App::Ack::print_line_with_options($opt, $filename, $matching_line, $line_no, ':');
        $previous_line_printed = $.;
    }

    if($after_context) {
        my $offset = 1;
        foreach my $line (@{$after_context}) {
            # XXX improve this!
            if ( $previous_line_printed >= $. + $offset ) {
                $offset++;
                next;
            }
            chomp $line;
            my $separator = App::Ack::does_match( $opt, $line ) ? ':' : '-';
            App::Ack::print_line_with_options($opt, $filename, $line, $. + $offset, $separator);
            $previous_line_printed = $. + $offset;
            $offset++;
        }
    }

    $is_first_match = 0;

    return;
}

}

# inefficient, but functional
sub filetypes {
    my ( $resource ) = @_;

    my @matches;

    foreach my $k (keys %mappings) {
        my $filters = $mappings{$k};

        foreach my $filter (@{$filters}) {
            # clone the resource
            my $clone = $resource->clone;
            if ( $filter->filter($clone) ) {
                push @matches, $k;
                last;
            }
        }
    }

    return sort @matches;
}

# returns a (fairly) unique identifier for a file
# use this function to compare two files to see if they're
# equal (ie. the same file, but with a different path/links/etc)
sub get_file_id {
    my ( $filename ) = @_;

    if ( $is_windows ) {
        return File::Next::reslash( $filename );
    }
    else {
        # XXX is this the best method? it always hits the FS
        if( my ( $dev, $inode ) = (stat($filename))[0, 1] ) {
            return join(':', $dev, $inode);
        }
        else {
            # XXX this could be better
            return $filename;
        }
    }
}

sub create_ackrc {
    print "$_\n" for ( '--ignore-ack-defaults', App::Ack::ConfigDefault::options() );
}


=head1 COPYRIGHT & LICENSE

Copyright 2005-2013 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

=cut

1; # End of App::Ack
