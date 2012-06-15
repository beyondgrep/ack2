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
    if ( $App::Ack::is_filter_mode && !$opt->{files_from} ) { # probably -x
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
            if($opt->{show_types}) {
                my @types = App::Ack::filetypes($resource);
                print $resource->name, ' => ', join(',', @types), $ors;
            } else {
                print $resource->name, $ors;
            }
            ++$nmatches;
            last RESOURCES if defined($max_count) && $nmatches >= $max_count;
        }
        elsif ( $opt->{g} ) {
            my $is_match = ( $resource->name =~ /$opt->{regex}/o );
            if ( $opt->{v} ? !$is_match : $is_match ) {
                if($opt->{show_types}) {
                    my @types = App::Ack::filetypes($resource);
                    print $resource->name, ' => ', join(',', @types), $ors;
                } else {
                    print $resource->name, $ors;
                }
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


=head1 NAME

ack - grep-like text finder

=head1 SYNOPSIS

    ack [options] PATTERN [FILE...]
    ack -f [options] [DIRECTORY...]

=head1 DESCRIPTION

Ack is designed as a replacement for 99% of the uses of F<grep>.

Ack searches the named input FILEs (or standard input if no files
are named, or the file name - is given) for lines containing a match
to the given PATTERN.  By default, ack prints the matching lines.

Ack can also list files that would be searched, without actually
searching them, to let you take advantage of ack's file-type filtering
capabilities.

=head1 FILE SELECTION

If files are not specified for searching, either on the command
line or piped in with the C<-x> option, I<ack> delves into
subdirectories selecting files for searching.

I<ack> is intelligent about the files it searches.  It knows about
certain file types, based on both the extension on the file and,
in some cases, the contents of the file.  These selections can be
made with the B<--type> option.

With no file selections, I<ack> only searches files of types that
it recognizes.  If you have a file called F<foo.wango>, and I<ack>
doesn't know what a .wango file is, I<ack> won't search it.

By default, I<ack> ignores certain files and directories.  These
include:

=over 4

=item * Backup files: Files matching F<#*#> or ending with F<~>.

=item * Coredumps: Files matching F<core.\d+>

=item * Version control directories like F<.svn> and F<.git>.

=back

Run I<ack> with the C<--dump> option to see what settings are set.

However, I<ack> always searches the files given on the command line,
no matter what type.  If you tell I<ack> to search in a coredump,
it will search in a coredump.

=head1 DIRECTORY SELECTION

I<ack> descends through the directory tree of the starting directories
specified.  However, it will ignore the shadow directories used by
many version control systems, and the build directories used by the
Perl MakeMaker system.  You may add or remove a directory from this
list with the B<--[no]ignore-dir> option. The option may be repeated
to add/remove multiple directories from the ignore list.

For a complete list of directories that do not get searched, run
C<ack --dump>.

=head1 WHEN TO USE GREP

I<ack> trumps I<grep> as an everyday tool 99% of the time, but don't
throw I<grep> away, because there are times you'll still need it.

E.g., searching through huge files looking for regexes that can be
expressed with I<grep> syntax should be quicker with I<grep>.

If your script or parent program uses I<grep> C<--quiet> or C<--silent>
or needs exit 2 on IO error, use I<grep>.

=head1 OPTIONS

=over 4

=item B<-A I<NUM>>, B<--after-context=I<NUM>>

Print I<NUM> lines of trailing context after matching lines.

=item B<-B I<NUM>>, B<--before-context=I<NUM>>

Print I<NUM> lines of leading context before matching lines.

=item B<-C [I<NUM>]>, B<--context[=I<NUM>]>

Print I<NUM> lines (default 2) of context around matching lines.

=item B<-c>, B<--count>

Suppress normal output; instead print a count of matching lines for
each input file.  If B<-l> is in effect, it will only show the
number of lines for each file that has lines matching.  Without
B<-l>, some line counts may be zeroes.

If combined with B<-h> (B<--no-filename>) ack outputs only one total
count.

=item B<--color>, B<--nocolor>

B<--color> highlights the matching text.  B<--nocolor> supresses
the color.  This is on by default unless the output is redirected.

On Windows, this option is off by default unless the
L<Win32::Console::ANSI> module is installed or the C<ACK_PAGER_COLOR>
environment variable is used.

=item B<--color-filename=I<color>>

Sets the color to be used for filenames.

=item B<--color-match=I<color>>

Sets the color to be used for matches.

=item B<--color-lineno=I<color>>

Sets the color to be used for line numbers.

=item B<--column>

Show the column number of the first match.  This is helpful for
editors that can place your cursor at a given position.

=item B<--env>, B<--noenv>

B<--noenv> disables all environment processing. No F<.ackrc> is
read and all environment variables are ignored. By default, F<ack>
considers F<.ackrc> and settings in the environment.

=item B<--flush>

B<--flush> flushes output immediately.  This is off by default
unless ack is running interactively (when output goes to a pipe or
file).

=item B<-f>

Only print the files that would be searched, without actually doing
any searching.  PATTERN must not be specified, or it will be taken
as a path to search.

=item B<--follow>, B<--nofollow>

Follow or don't follow symlinks, other than whatever starting files
or directories were specified on the command line.

This is off by default.

=item B<-g I<REGEX>>

Print files where the relative path + filename matches I<REGEX>.
This option is a convenience shortcut for B<-f> B<-G I<REGEX>>.

The options B<-i>, B<-w>, B<-v>, and B<-Q> do not apply to this
I<REGEX>.

=item B<--group>, B<--nogroup>

B<--group> groups matches by file name with.  This is the default
when used interactively.

B<--nogroup> prints one result per line, like grep.  This is the
default when output is redirected.

=item B<-H>, B<--with-filename>

Print the filename for each match.

=item B<-h>, B<--no-filename>

Suppress the prefixing of filenames on output when multiple files are
searched.

=item B<--help>

Print a short help statement.

=item B<-i>, B<--ignore-case>

Ignore case in the search strings.

This applies only to the PATTERN, not to the regexes given for the B<-g>
and B<-G> options.

=item B<--[no]ignore-dir=I<DIRNAME>>

Ignore directory (as CVS, .svn, etc are ignored). May be used
multiple times to ignore multiple directories. For example, mason
users may wish to include B<--ignore-dir=data>. The B<--noignore-dir>
option allows users to search directories which would normally be
ignored (perhaps to research the contents of F<.svn/props> directories).

The I<DIRNAME> must always be a simple directory name. Nested
directories like F<foo/bar> are NOT supported. You would need to
specify B<--ignore-dir=foo> and then no files from any foo directory
are taken into account by ack unless given explicitly on the command
line.

=item B<--line=I<NUM>>

Only print line I<NUM> of each file. Multiple lines can be given with multiple
B<--line> options or as a comma separated list (B<--line=3,5,7>). B<--line=4-7>
also works. The lines are always output in ascending order, no matter the
order given on the command line.

=item B<-l>, B<--files-with-matches>

Only print the filenames of matching files, instead of the matching text.

=item B<-L>, B<--files-without-matches>

Only print the filenames of files that do I<NOT> match. This is equivalent
to specifying B<-l> and B<-v>.

=item B<--match I<REGEX>>

Specify the I<REGEX> explicitly. This is helpful if you don't want to put the
regex as your first argument, e.g. when executing multiple searches over the
same set of files.

    # search for foo and bar in given files
    ack file1 t/file* --match foo
    ack file1 t/file* --match bar

=item B<-m=I<NUM>>, B<--max-count=I<NUM>>

Stop reading a file after I<NUM> matches.

=item B<--man>

Print this manual page.

=item B<-n>, B<--no-recurse>

No descending into subdirectories.

=item B<-o>

Show only the part of each line matching PATTERN (turns off text
highlighting)

=item B<--output=I<expr>>

Output the evaluation of I<expr> for each line (turns off text
highlighting)

=item B<--pager=I<program>>

Direct ack's output through I<program>.  This can also be specified
via the C<ACK_PAGER> and C<ACK_PAGER_COLOR> environment variables.

Using --pager does not suppress grouping and coloring like piping
output on the command-line does.

=item B<--passthru>

Prints all lines, whether or not they match the expression.  Highlighting
will still work, though, so it can be used to highlight matches while
still seeing the entire file, as in:

    # Watch a log file, and highlight a certain IP address
    $ tail -f ~/access.log | ack --passthru 123.45.67.89

=item B<--print0>

Only works in conjunction with -f, -g, -l or -c (filename output). The filenames
are output separated with a null byte instead of the usual newline. This is
helpful when dealing with filenames that contain whitespace, e.g.

    # remove all files of type html
    ack -f --html --print0 | xargs -0 rm -f

=item B<-Q>, B<--literal>

Quote all metacharacters in PATTERN, it is treated as a literal.

This applies only to the PATTERN, not to the regexes given for the B<-g>
and B<-G> options.

=item B<-r>, B<-R>, B<--recurse>

Recurse into sub-directories. This is the default and just here for
compatibility with grep. You can also use it for turning B<--no-recurse> off.

=item B<--smart-case>, B<--no-smart-case>

Ignore case in the search strings if PATTERN contains no uppercase
characters. This is similar to C<smartcase> in vim. This option is
off by default.

B<-i> always overrides this option.

This applies only to the PATTERN, not to the regexes given for the
B<-g> and B<-G> options.

=item B<--sort-files>

Sorts the found files lexically.  Use this if you want your file
listings to be deterministic between runs of I<ack>.

=item B<--show-types>

Outputs the filetypes that ack associates with each file.

Works with B<-f> and B<-g> options.

=item B<--type=TYPE>, B<--type=noTYPE>

Specify the types of files to include or exclude from a search.
TYPE is a filetype, like I<perl> or I<xml>.  B<--type=perl> can
also be specified as B<--perl>, and B<--type=noperl> can be done
as B<--noperl>.

If a file is of both type "foo" and "bar", specifying --foo and
--nobar will exclude the file, because an exclusion takes precedence
over an inclusion.

Type specifications can be repeated and are ORed together.

See I<ack --help=types> for a list of valid types.

=item B<--type-add I<TYPE>=I<.EXTENSION>[,I<.EXT2>[,...]]>

Files with the given EXTENSION(s) are recognized as being of (the
existing) type TYPE. See also L</"Defining your own types">.


=item B<--type-set I<TYPE>=I<.EXTENSION>[,I<.EXT2>[,...]]>

Files with the given EXTENSION(s) are recognized as being of type
TYPE. This replaces an existing definition for type TYPE.  See also
L</"Defining your own types">.

=item B<-v>, B<--invert-match>

Invert match: select non-matching lines

This applies only to the PATTERN, not to the regexes given for the B<-g>
and B<-G> options.

=item B<--version>

Display version and copyright information.

=item B<-w>, B<--word-regexp>

Force PATTERN to match only whole words.  The PATTERN is wrapped with
C<\b> metacharacters.

This applies only to the PATTERN, not to the regexes given for the B<-g>
and B<-G> options.

=item B<-1>

Stops after reporting first match of any kind.  This is different
from B<--max-count=1> or B<-m1>, where only one match per file is
shown.  Also, B<-1> works with B<-f> and B<-g>, where B<-m> does
not.

=item B<--thpppt>

Display the all-important Bill The Cat logo.  Note that the exact
spelling of B<--thpppppt> is not important.  It's checked against
a regular expression.

=item B<--bar>

Check with the admiral for traps.

=back

=head1 THE .ackrc FILE

The F<.ackrc> file contains command-line options that are prepended
to the command line before processing.  Multiple options may live
on multiple lines.  Lines beginning with a # are ignored.  A F<.ackrc>
might look like this:

    # Always sort the files
    --sort-files

    # Always color, even if piping to a another program
    --color

    # Use "less -r" as my pager
    --pager=less -r

Note that arguments with spaces in them do not need to be quoted,
as they are not interpreted by the shell. Basically, each I<line>
in the F<.ackrc> file is interpreted as one element of C<@ARGV>.

F<ack> looks in your home directory for the F<.ackrc>.  You can
specify another location with the F<ACKRC> variable, below.

If B<--noenv> is specified on the command line, the F<.ackrc> file
is ignored.

=head1 Defining your own types

ack allows you to define your own types in addition to the predefined
types. This is done with command line options that are best put into
an F<.ackrc> file - then you do not have to define your types over and
over again. In the following examples the options will always be shown
on one command line so that they can be easily copy & pasted.

I<ack --perl foo> searches for foo in all perl files. I<ack --help=types>
tells you, that perl files are files ending
in .pl, .pm, .pod or .t. So what if you would like to include .xs
files as well when searching for --perl files? I<ack --type-add perl=.xs --perl foo>
does this for you. B<--type-add> appends
additional extensions to an existing type.

If you want to define a new type, or completely redefine an existing
type, then use B<--type-set>. I<ack --type-set
eiffel=.e,.eiffel> defines the type I<eiffel> to include files with
the extensions .e or .eiffel. So to search for all eiffel files
containing the word Bertrand use I<ack --type-set eiffel=.e,.eiffel --eiffel Bertrand>.
As usual, you can also write B<--type=eiffel>
instead of B<--eiffel>. Negation also works, so B<--noeiffel> excludes
all eiffel files from a search. Redefining also works: I<ack --type-set cc=.c,.h>
and I<.xs> files no longer belong to the type I<cc>.

When defining your own types in the F<.ackrc> file you have to use
the following:

  --type-set=eiffel=.e,.eiffel

or writing on separate lines

  --type-set
  eiffel=.e,.eiffel

The following does B<NOT> work in the F<.ackrc> file:

  --type-set eiffel=.e,.eiffel


In order to see all currently defined types, use I<--help types>, e.g.
I<ack --type-set backup=.bak --type-add perl=.perl --help types>

Restrictions:

=over 4

=item

The shebang line recognition of the types 'perl', 'ruby', 'php',
'python', 'shell' and 'xml' cannot be redefined by I<--type-set>,
it is always active. However, the shebang line is only examined for
files where the extension is not recognised. Therefore it is possible
to say I<ack --type-set perl=.perl --type-set foo=.pl,.pm,.pod,.t
--perl --nofoo> and only find your shiny new I<.perl> files (and
all files with unrecognized extension and perl on the shebang line).

=back

=head1 ENVIRONMENT VARIABLES

For commonly-used ack options, environment variables can make life
much easier.  These variables are ignored if B<--noenv> is specified
on the command line.

=over 4

=item ACKRC

Specifies the location of the F<.ackrc> file.  If this file doesn't
exist, F<ack> looks in the default location.

=item ACK_OPTIONS

This variable specifies default options to be placed in front of
any explicit options on the command line.

=item ACK_COLOR_FILENAME

Specifies the color of the filename when it's printed in B<--group>
mode.  By default, it's "bold green".

The recognized attributes are clear, reset, dark, bold, underline,
underscore, blink, reverse, concealed black, red, green, yellow,
blue, magenta, on_black, on_red, on_green, on_yellow, on_blue,
on_magenta, on_cyan, and on_white.  Case is not significant.
Underline and underscore are equivalent, as are clear and reset.
The color alone sets the foreground color, and on_color sets the
background color.

This option can also be set with B<--color-filename>.

=item ACK_COLOR_MATCH

Specifies the color of the matching text when printed in B<--color>
mode.  By default, it's "black on_yellow".

This option can also be set with B<--color-match>.

See B<ACK_COLOR_FILENAME> for the color specifications.

=item ACK_COLOR_LINENO

Specifies the color of the line number when printed in B<--color>
mode.  By default, it's "bold yellow".

This option can also be set with B<--color-lineno>.

See B<ACK_COLOR_FILENAME> for the color specifications.

=item ACK_PAGER

Specifies a pager program, such as C<more>, C<less> or C<most>, to which
ack will send its output.

Using C<ACK_PAGER> does not suppress grouping and coloring like
piping output on the command-line does, except that on Windows
ack will assume that C<ACK_PAGER> does not support color.

C<ACK_PAGER_COLOR> overrides C<ACK_PAGER> if both are specified.

=item ACK_PAGER_COLOR

Specifies a pager program that understands ANSI color sequences.
Using C<ACK_PAGER_COLOR> does not suppress grouping and coloring
like piping output on the command-line does.

If you are not on Windows, you never need to use C<ACK_PAGER_COLOR>.

=back

=head1 ACK & OTHER TOOLS

=head2 Vim integration

F<ack> integrates easily with the Vim text editor. Set this in your
F<.vimrc> to use F<ack> instead of F<grep>:

    set grepprg=ack\ -a

That examples uses C<-a> to search through all files, but you may
use other default flags. Now you can search with F<ack> and easily
step through the results in Vim:

  :grep Dumper perllib

=head2 Emacs integration

Phil Jackson put together an F<ack.el> extension that "provides a
simple compilation mode ... has the ability to guess what files you
want to search for based on the major-mode."

L<http://www.shellarchive.co.uk/content/emacs.html>

=head2 TextMate integration

Pedro Melo is a TextMate user who writes "I spend my day mostly
inside TextMate, and the built-in find-in-project sucks with large
projects.  So I hacked a TextMate command that was using find +
grep to use ack.  The result is the Search in Project with ack, and
you can find it here:
L<http://www.simplicidade.org/notes/archives/2008/03/search_in_proje.html>"

=head2 Shell and Return Code

For greater compatibility with I<grep>, I<ack> in normal use returns
shell return or exit code of 0 only if something is found and 1 if
no match is found.

(Shell exit code 1 is C<$?=256> in perl with C<system> or backticks.)

The I<grep> code 2 for errors is not used.

If C<-f> or C<-g> are specified, then 0 is returned if at least one
file is found.  If no files are found, then 1 is returned.

=cut

=head1 DEBUGGING ACK PROBLEMS

If ack gives you output you're not expecting, start with a few simple steps.

=head2 Use B<--noenv>

Your environment variables and F<.ackrc> may be doing things you're
not expecting, or forgotten you specified.  Use B<--noenv> to ignore
your environment and F<.ackrc>.

=head2 Use B<-f> to see what files have been selected

Ack's B<-f> was originally added as a debugging tool.  If ack is
not finding matches you think it should find, run F<ack -f> to see
what files have been selected.  You can also add the C<--show-types>
options to show the type of each file selected.

=head1 TIPS

=head2 Use the F<.ackrc> file.

The F<.ackrc> is the place to put all your options you use most of
the time but don't want to remember.  Put all your --type-add and
--type-set definitions in it.  If you like --smart-case, set it
there, too.  I also set --sort-files there.

=head2 Use F<-f> for working with big codesets

Ack does more than search files.  C<ack -f --perl> will create a
list of all the Perl files in a tree, ideal for sending into F<xargs>.
For example:

    # Change all "this" to "that" in all Perl files in a tree.
    ack -f --perl | xargs perl -p -i -e's/this/that/g'

or if you prefer:

    perl -p -i -e's/this/that/g' $(ack -f --perl)

=head2 Use F<-Q> when in doubt about metacharacters

If you're searching for something with a regular expression
metacharacter, most often a period in a filename or IP address, add
the -Q to avoid false positives without all the backslashing.  See
the following example for more...

=head2 Use ack to watch log files

Here's one I used the other day to find trouble spots for a website
visitor.  The user had a problem loading F<troublesome.gif>, so I
took the access log and scanned it with ack twice.

    ack -Q aa.bb.cc.dd /path/to/access.log | ack -Q -B5 troublesome.gif

The first ack finds only the lines in the Apache log for the given
IP.  The second finds the match on my troublesome GIF, and shows
the previous five lines from the log in each case.

=head2 Share your knowledge

Join the ack-users mailing list.  Send me your tips and I may add
them here.

=head1 FAQ

=head2 Why isn't ack finding a match in (some file)?

Probably because it's of a type that ack doesn't recognize.  ack's
searching behavior is driven by filetype.  B<If ack doesn't know
what kind of file it is, ack ignores the file.>

Use the C<-f> switch to see a list of files that ack will search
for you.

If you want ack to search files that it doesn't recognize, use the
C<-a> switch.

If you want ack to search every file, even ones that it always
ignores like coredumps and backup files, use the C<-u> switch.

=head2 Why does ack ignore unknown files by default?

ack is designed by a programmer, for programmers, for searching
large trees of code.  Most codebases have a lot files in them which
aren't source files (like compiled object files, source control
metadata, etc), and grep wastes a lot of time searching through all
of those as well and returning matches from those files.

That's why ack's behavior of not searching things it doesn't recognize
is one of its greatest strengths: the speed you get from only
searching the things that you want to be looking at.

=head2 Wouldn't it be great if F<ack> did search & replace?

No, ack will always be read-only.  Perl has a perfectly good way
to do search & replace in files, using the C<-i>, C<-p> and C<-n>
switches.

You can certainly use ack to select your files to update.  For
example, to change all "foo" to "bar" in all PHP files, you can do
this from the Unix shell:

    $ perl -i -p -e's/foo/bar/g' $(ack -f --php)

=head2 Can you make ack recognize F<.xyz> files?

That's an enhancement.  Please see the section in the manual about
enhancements.

=head2 There's already a program/package called ack.

Yes, I know.

=head2 Why is it called ack if it's called ack-grep?

The name of the program is "ack".  Some packagers have called it
"ack-grep" when creating packages because there's already a package
out there called "ack" that has nothing to do with this ack.

I suggest you make a symlink named F<ack> that points to F<ack-grep>
because one of the crucial benefits of ack is having a name that's
so short and simple to type.

To do that, run this with F<sudo> or as root:

   ln -s /usr/bin/ack-grep /usr/bin/ack

=head2 What does F<ack> mean?

Nothing.  I wanted a name that was easy to type and that you could
pronounce as a single syllable.

=head2 Can I do multi-line regexes?

No, ack does not support regexes that match multiple lines.  Doing
so would require reading in the entire file at a time.

If you want to see lines near your match, use the C<--A>, C<--B>
and C<--C> switches for displaying context.

=head1 ACKRC LOCATION SEMANTICS

Ack can load its configuration from many sources.  This list
specifies the sources Ack looks for configuration; each one
that is found is loaded in the order specified here, and
each one overrides options set in any of the sources preceding
it.  (For example, if I set --sort-files in my user ackrc, and
--nosort-files on the command line, the comand line takes
precedence)

=over 4

=item *

Defaults are loaded from App::Ack::ConfigDefaults.  This can be omitted
using C<--ignore-ack-defaults>.

=item * Global ackrc

Options are then loaded from the global ackrc.  This is located at
C</etc/ackrc> on Unix-like systems, and
C<C:\Documents and Settings\All Users\Application Data> on Windows.
This can be omitted using C<--noenv>.

=item * User ackrc

Options are then loaded from the user's ackrc.  This is located at
C<$HOME/.ackrc> on Unix-like systems, and
C<C:\Documents and Settings\$USER\Application Data>.
This can be omitted using C<--noenv>.

=item * Project ackrc

Options are then loaded from the project ackrc.  The project ackrc is
the first ackrc file with the name C<.ackrc> or C<_ackrc>, first searching
in the current directory, then the parent directory, then the grandparent
directory, etc.  This can be omitted using C<--noenv>.

=item * ACK_OPTIONS

Options are then loaded from the enviroment variable C<ACK_OPTIONS>.  This can
be omitted using C<--noenv>.

=item * Command line

Options are then loaded from the command line.

=back

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
Ricardo Signes,
Pete Krawczyk and
Rob Hoelz.

=head1 COPYRIGHT & LICENSE

Copyright 2005-2012 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

=cut
