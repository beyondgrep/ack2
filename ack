#!/usr/bin/perl

use strict;
use warnings;
our $VERSION = '2.22'; # Check https://beyondgrep.com/ for updates

use 5.008008;
use Getopt::Long 2.38 ();
use Carp 1.04 ();

use File::Spec ();
use File::Next ();

use App::Ack ();
use App::Ack::ConfigLoader ();
use App::Ack::Resources;
use App::Ack::Resource ();

# XXX Don't make this so brute force
# See also: https://github.com/beyondgrep/ack2/issues/89
use App::Ack::Filter ();
use App::Ack::Filter::Default;
use App::Ack::Filter::Extension;
use App::Ack::Filter::FirstLineMatch;
use App::Ack::Filter::Inverse;
use App::Ack::Filter::Is;
use App::Ack::Filter::IsPath;
use App::Ack::Filter::Match;
use App::Ack::Filter::Collection;

our $opt_after_context;
our $opt_before_context;
our $opt_output;
our $opt_print0;
our $opt_color;
our $opt_heading;
our $opt_show_filename;
our $opt_regex;
our $opt_break;
our $opt_count;
our $opt_v;
our $opt_m;
our $opt_g;
our $opt_f;
our $opt_lines;
our $opt_L;
our $opt_l;
our $opt_passthru;
our $opt_column;

# Flag if we need any context tracking.
our $is_tracking_context;

# These are all our globals.

MAIN: {
    $App::Ack::orig_program_name = $0;
    $0 = join(' ', 'ack', $0);
    if ( $App::Ack::VERSION ne $main::VERSION ) {
        App::Ack::die( "Program/library version mismatch\n\t$0 is $main::VERSION\n\t$INC{'App/Ack.pm'} is $App::Ack::VERSION" );
    }

    # Do preliminary arg checking;
    my $env_is_usable = 1;
    for my $arg ( @ARGV ) {
        last if ( $arg eq '--' );

        # Get the --thpppt, --bar, --cathy checking out of the way.
        $arg =~ /^--th[pt]+t+$/ and App::Ack::thpppt($arg);
        $arg eq '--bar'         and App::Ack::ackbar();
        $arg eq '--cathy'       and App::Ack::cathy();

        # See if we want to ignore the environment. (Don't tell Al Gore.)
        $arg eq '--env'         and $env_is_usable = 1;
        $arg eq '--noenv'       and $env_is_usable = 0;
    }

    if ( !$env_is_usable ) {
        my @keys = ( 'ACKRC', grep { /^ACK_/ } keys %ENV );
        delete @ENV{@keys};
    }
    load_colors();

    Getopt::Long::Configure('default', 'no_auto_help', 'no_auto_version');
    Getopt::Long::Configure('pass_through', 'no_auto_abbrev');
    Getopt::Long::GetOptions(
        'help'       => sub { App::Ack::show_help(); exit; },
        'version'    => sub { App::Ack::print_version_statement(); exit; },
        'man'        => sub { App::Ack::show_man(); exit; },
    );
    Getopt::Long::Configure('default', 'no_auto_help', 'no_auto_version');

    if ( !@ARGV ) {
        App::Ack::show_help();
        exit 1;
    }

    main();
}

sub _compile_descend_filter {
    my ( $opt ) = @_;

    my $idirs = 0;
    my $dont_ignore_dirs = 0;

    for my $filter (@{$opt->{idirs} || []}) {
        if ($filter->is_inverted()) {
            $dont_ignore_dirs++;
        }
        else {
            $idirs++;
        }
    }

    # If we have one or more --noignore-dir directives, we can't ignore
    # entire subdirectory hierarchies, so we return an "accept all"
    # filter and scrutinize the files more in _compile_file_filter.
    return if $dont_ignore_dirs;
    return unless $idirs;

    $idirs = $opt->{idirs};

    return sub {
        my $resource = App::Ack::Resource->new($File::Next::dir);
        return !grep { $_->filter($resource) } @{$idirs};
    };
}

sub _compile_file_filter {
    my ( $opt, $start ) = @_;

    my $ifiles_filters = $opt->{ifiles};

    my $filters         = $opt->{'filters'} || [];
    my $direct_filters = App::Ack::Filter::Collection->new();
    my $inverse_filters = App::Ack::Filter::Collection->new();

    foreach my $filter (@{$filters}) {
        if ($filter->is_inverted()) {
            # We want to check if files match the uninverted filters
            $inverse_filters->add($filter->invert());
        }
        else {
            $direct_filters->add($filter);
        }
    }

    my %is_member_of_starting_set = map { (get_file_id($_) => 1) } @{$start};

    my @ignore_dir_filter = @{$opt->{idirs} || []};
    my @is_inverted       = map { $_->is_inverted() } @ignore_dir_filter;
    # This depends on InverseFilter->invert returning the original filter (for optimization).
    @ignore_dir_filter         = map { $_->is_inverted() ? $_->invert() : $_ } @ignore_dir_filter;
    my $dont_ignore_dir_filter = grep { $_ } @is_inverted;
    my $previous_dir = '';
    my $previous_dir_ignore_result;

    return sub {
        if ( $opt_g ) {
            if ( $File::Next::name =~ /$opt_regex/ && $opt_v ) {
                return 0;
            }
            if ( $File::Next::name !~ /$opt_regex/ && !$opt_v ) {
                return 0;
            }
        }
        # ack always selects files that are specified on the command
        # line, regardless of filetype.  If you want to ack a JPEG,
        # and say "ack foo whatever.jpg" it will do it for you.
        return 1 if $is_member_of_starting_set{ get_file_id($File::Next::name) };

        if ( $dont_ignore_dir_filter ) {
            if ( $previous_dir eq $File::Next::dir ) {
                if ( $previous_dir_ignore_result ) {
                    return 0;
                }
            }
            else {
                my @dirs = File::Spec->splitdir($File::Next::dir);

                my $is_ignoring = 0;

                for ( my $i = 0; $i < @dirs; $i++) {
                    my $dir_rsrc = App::Ack::Resource->new(File::Spec->catfile(@dirs[0 .. $i]));

                    my $j = 0;
                    for my $filter (@ignore_dir_filter) {
                        if ( $filter->filter($dir_rsrc) ) {
                            $is_ignoring = !$is_inverted[$j];
                        }
                        $j++;
                    }
                }

                $previous_dir               = $File::Next::dir;
                $previous_dir_ignore_result = $is_ignoring;

                if ( $is_ignoring ) {
                    return 0;
                }
            }
        }

        # Ignore named pipes found in directory searching.  Named
        # pipes created by subprocesses get specified on the command
        # line, so the rule of "always select whatever is on the
        # command line" wins.
        return 0 if -p $File::Next::name;

        # We can't handle unreadable filenames; report them.
        if ( not -r _ ) {
            use filetest 'access';

            if ( not -R $File::Next::name ) {
                if ( $App::Ack::report_bad_filenames ) {
                    App::Ack::warn( "${File::Next::name}: cannot open file for reading" );
                }
                return 0;
            }
        }

        my $resource = App::Ack::Resource->new($File::Next::name);

        if ( $ifiles_filters && $ifiles_filters->filter($resource) ) {
            return 0;
        }

        my $match_found = $direct_filters->filter($resource);

        # Don't bother invoking inverse filters unless we consider the current resource a match
        if ( $match_found && $inverse_filters->filter( $resource ) ) {
            $match_found = 0;
        }
        return $match_found;
    };
}

sub show_types {
    my $resource = shift;
    my $ors      = shift;

    my @types = filetypes( $resource );
    my $types = join( ',', @types );
    my $arrow = @types ? ' => ' : ' =>';
    App::Ack::print( $resource->name, $arrow, join( ',', @types ), $ors );

    return;
}

# Set default colors, load Term::ANSIColor
sub load_colors {
    eval 'use Term::ANSIColor 1.10 ()';
    eval 'use Win32::Console::ANSI' if $App::Ack::is_windows;

    $ENV{ACK_COLOR_MATCH}    ||= 'black on_yellow';
    $ENV{ACK_COLOR_FILENAME} ||= 'bold green';
    $ENV{ACK_COLOR_LINENO}   ||= 'bold yellow';

    return;
}

sub filetypes {
    my ( $resource ) = @_;

    my @matches;

    foreach my $k (keys %App::Ack::mappings) {
        my $filters = $App::Ack::mappings{$k};

        foreach my $filter (@{$filters}) {
            # Clone the resource.
            my $clone = $resource->clone;
            if ( $filter->filter($clone) ) {
                push @matches, $k;
                last;
            }
        }
    }

    # http://search.cpan.org/dist/Perl-Critic/lib/Perl/Critic/Policy/Subroutines/ProhibitReturnSort.pm
    @matches = sort @matches;
    return @matches;
}

# Returns a (fairly) unique identifier for a file.
# Use this function to compare two files to see if they're
# equal (ie. the same file, but with a different path/links/etc).
sub get_file_id {
    my ( $filename ) = @_;

    if ( $App::Ack::is_windows ) {
        return File::Next::reslash( $filename );
    }
    else {
        # XXX Is this the best method? It always hits the FS.
        if( my ( $dev, $inode ) = (stat($filename))[0, 1] ) {
            return join(':', $dev, $inode);
        }
        else {
            # XXX This could be better.
            return $filename;
        }
    }
}

# Returns a regex object based on a string and command-line options.
# Dies when the regex $str is undefined (i.e. not given on command line).

sub build_regex {
    my $str = shift;
    my $opt = shift;

    defined $str or App::Ack::die( 'No regular expression found.' );

    $str = quotemeta( $str ) if $opt->{Q};
    if ( $opt->{w} ) {
        my $pristine_str = $str;

        $str = "(?:$str)";
        $str = "\\b$str" if $pristine_str =~ /^\w/;
        $str = "$str\\b" if $pristine_str =~ /\w$/;
    }

    my $regex_is_lc = $str eq lc $str;
    if ( $opt->{i} || ($opt->{smart_case} && $regex_is_lc) ) {
        $str = "(?i)$str";
    }

    my $re = eval { qr/$str/m };
    if ( !$re ) {
        die "Invalid regex '$str':\n  $@";
    }

    return $re;

}

my $match_column_number;

{

# Number of context lines
my $n_before_ctx_lines;
my $n_after_ctx_lines;

# Array to keep track of lines that might be required for a "before" context
my @before_context_buf;
# Position to insert next line in @before_context_buf
my $before_context_pos;

# Number of "after" context lines still pending
my $after_context_pending;

# Number of latest line that got printed
my $printed_line_no;

my $is_iterating;

my $is_first_match;
my $has_printed_something;

BEGIN {
    $has_printed_something = 0;
}

# Set up context tracking variables.
sub set_up_line_context {
    $n_before_ctx_lines = $opt_output ? 0 : ($opt_before_context || 0);
    $n_after_ctx_lines  = $opt_output ? 0 : ($opt_after_context || 0);

    @before_context_buf = (undef) x $n_before_ctx_lines;
    $before_context_pos = 0;

    $is_tracking_context = $n_before_ctx_lines || $n_after_ctx_lines;

    $is_first_match = 1;

    return;
}

# Adjust context tracking variables when entering a new file.
sub set_up_line_context_for_file {
    $printed_line_no = 0;
    $after_context_pending = 0;
    if ( $opt_heading && !$opt_lines ) {
        $is_first_match = 1;
    }

    return;
}

=begin Developers

This subroutine jumps through a number of optimization hoops to
try to be fast in the more common use cases of ack.  For one thing,
in non-context tracking searches (not using -A, -B, or -C),
conditions that normally would be checked inside the loop happen
outside, resulting in three nearly identical loops for -v, --passthru,
and normal searching.  Any changes that happen to one should propagate
to the others if they make sense.  The non-context branches also inline
does_match for performance reasons; any relevant changes that happen here
must also happen there.

=end Developers

=cut

sub print_matches_in_resource {
    my ( $resource ) = @_;

    my $max_count      = $opt_m || -1;
    my $nmatches       = 0;
    my $filename       = $resource->name;
    my $ors            = $opt_print0 ? "\0" : "\n";

    my $has_printed_for_this_resource = 0;

    $is_iterating = 1;

    my $fh = $resource->open();
    if ( !$fh ) {
        if ( $App::Ack::report_bad_filenames ) {
            App::Ack::warn( "$filename: $!" );
        }
        return 0;
    }

    my $display_filename = $filename;
    if ( $opt_show_filename && $opt_heading && $opt_color ) {
        $display_filename = Term::ANSIColor::colored($display_filename, $ENV{ACK_COLOR_FILENAME});
    }

    # Check for context before the main loop, so we don't pay for it if we don't need it.
    if ( $is_tracking_context ) {
        $after_context_pending = 0;
        while ( <$fh> ) {
            if ( does_match( $_ ) && $max_count ) {
                if ( !$has_printed_for_this_resource ) {
                    if ( $opt_break && $has_printed_something ) {
                        App::Ack::print_blank_line();
                    }
                    if ( $opt_show_filename && $opt_heading ) {
                        App::Ack::print_filename( $display_filename, $ors );
                    }
                }
                print_line_with_context( $filename, $_, $. );
                $has_printed_for_this_resource = 1;
                $nmatches++;
                $max_count--;
            }
            elsif ( $opt_passthru ) {
                chomp; # XXX Proper newline handling?
                # XXX Inline this call?
                if ( $opt_break && !$has_printed_for_this_resource && $has_printed_something ) {
                    App::Ack::print_blank_line();
                }
                print_line_with_options( $filename, $_, $., ':' );
                $has_printed_for_this_resource = 1;
            }
            else {
                chomp; # XXX Proper newline handling?
                print_line_if_context( $filename, $_, $., '-' );
            }

            last if ($max_count == 0) && ($after_context_pending == 0);
        }
    }
    else {
        if ( $opt_passthru ) {
            local $_;

            while ( <$fh> ) {
                $match_column_number = undef;
                if ( $opt_v ? !/$opt_regex/o : /$opt_regex/o ) {
                    if ( !$opt_v ) {
                        $match_column_number = $-[0] + 1;
                    }
                    if ( !$has_printed_for_this_resource ) {
                        if ( $opt_break && $has_printed_something ) {
                            App::Ack::print_blank_line();
                        }
                        if ( $opt_show_filename && $opt_heading ) {
                            App::Ack::print_filename( $display_filename, $ors );
                        }
                    }
                    print_line_with_context( $filename, $_, $. );
                    $has_printed_for_this_resource = 1;
                    $nmatches++;
                    $max_count--;
                }
                else {
                    chomp; # XXX proper newline handling?
                    if ( $opt_break && !$has_printed_for_this_resource && $has_printed_something ) {
                        App::Ack::print_blank_line();
                    }
                    print_line_with_options( $filename, $_, $., ':' );
                    $has_printed_for_this_resource = 1;
                }
                last unless $max_count != 0;
            }
        }
        elsif ( $opt_v ) {
            local $_;

            $match_column_number = undef;
            while ( <$fh> ) {
                if ( !/$opt_regex/o ) {
                    if ( !$has_printed_for_this_resource ) {
                        if ( $opt_break && $has_printed_something ) {
                            App::Ack::print_blank_line();
                        }
                        if ( $opt_show_filename && $opt_heading ) {
                            App::Ack::print_filename( $display_filename, $ors );
                        }
                    }
                    print_line_with_context( $filename, $_, $. );
                    $has_printed_for_this_resource = 1;
                    $nmatches++;
                    $max_count--;
                }
                last unless $max_count != 0;
            }
        }
        else {
            local $_;

            while ( <$fh> ) {
                $match_column_number = undef;
                if ( /$opt_regex/o ) {
                    $match_column_number = $-[0] + 1;
                    if ( !$has_printed_for_this_resource ) {
                        if ( $opt_break && $has_printed_something ) {
                            App::Ack::print_blank_line();
                        }
                        if ( $opt_show_filename && $opt_heading ) {
                            App::Ack::print_filename( $display_filename, $ors );
                        }
                    }
                    s/[\r\n]+$//g;
                    print_line_with_options( $filename, $_, $., ':' );
                    $has_printed_for_this_resource = 1;
                    $nmatches++;
                    $max_count--;
                }
                last unless $max_count != 0;
            }
        }

    }

    $is_iterating = 0;

    return $nmatches;
}

sub print_line_with_options {
    my ( $filename, $line, $line_no, $separator ) = @_;

    $has_printed_something = 1;
    $printed_line_no = $line_no;

    my $ors = $opt_print0 ? "\0" : "\n";

    my @line_parts;

    if( $opt_color ) {
        $filename = Term::ANSIColor::colored($filename,
            $ENV{ACK_COLOR_FILENAME});
        $line_no  = Term::ANSIColor::colored($line_no,
            $ENV{ACK_COLOR_LINENO});
    }

    if($opt_show_filename) {
        if( $opt_heading ) {
            push @line_parts, $line_no;
        }
        else {
            push @line_parts, $filename, $line_no;
        }

        if( $opt_column ) {
            push @line_parts, get_match_column();
        }
    }
    if( $opt_output ) {
        while ( $line =~ /$opt_regex/og ) {
            # XXX We need to stop using eval() for --output.  See https://github.com/beyondgrep/ack2/issues/421
            my $output = eval $opt_output;
            App::Ack::print( join( $separator, @line_parts, $output ), $ors );
        }
    }
    else {
        if ( $opt_color ) {
            # This match is redundant, but we need to perfom it in order to get if capture groups are set.
            $line =~ /$opt_regex/o;

            if ( @+ > 1 ) { # If we have captures...
                while ( $line =~ /$opt_regex/og ) {
                    my $offset = 0; # Additional offset for when we add stuff.
                    my $previous_match_end = 0;

                    last if $-[0] == $+[0];

                    for ( my $i = 1; $i < @+; $i++ ) {
                        my ( $match_start, $match_end ) = ( $-[$i], $+[$i] );

                        next unless defined($match_start);
                        next if $match_start < $previous_match_end;

                        my $substring = substr( $line,
                            $offset + $match_start, $match_end - $match_start );
                        my $substitution = Term::ANSIColor::colored( $substring,
                            $ENV{ACK_COLOR_MATCH} );

                        substr( $line, $offset + $match_start,
                            $match_end - $match_start, $substitution );

                        $previous_match_end  = $match_end; # Offsets do not need to be applied.
                        $offset             += length( $substitution ) - length( $substring );
                    }

                    pos($line) = $+[0] + $offset;
                }
            }
            else {
                my $matched = 0; # If matched, need to escape afterwards.

                while ( $line =~ /$opt_regex/og ) {

                    $matched = 1;
                    my ( $match_start, $match_end ) = ($-[0], $+[0]);
                    next unless defined($match_start);
                    last if $match_start == $match_end;

                    my $substring = substr( $line, $match_start,
                        $match_end - $match_start );
                    my $substitution = Term::ANSIColor::colored( $substring,
                        $ENV{ACK_COLOR_MATCH} );

                    substr( $line, $match_start, $match_end - $match_start,
                        $substitution );

                    pos($line) = $match_end +
                    (length( $substitution ) - length( $substring ));
                }
                # XXX Why do we do this?
                $line .= "\033[0m\033[K" if $matched;
            }
        }

        push @line_parts, $line;
        App::Ack::print( join( $separator, @line_parts ), $ors );
    }

    return;
}

sub iterate {
    my ( $resource, $cb ) = @_;

    $is_iterating = 1;

    my $fh = $resource->open();
    if ( !$fh ) {
        if ( $App::Ack::report_bad_filenames ) {
            App::Ack::warn( $resource->name . ': ' . $! );
        }
        return;
    }

    # Check for context before the main loop, so we don't pay for it if we don't need it.
    if ( $is_tracking_context ) {
        $after_context_pending = 0;

        while ( <$fh> ) {
            last unless $cb->();
        }
    }
    else {
        local $_;

        while ( <$fh> ) {
            last unless $cb->();
        }
    }

    $is_iterating = 0;

    return;
}

sub print_line_with_context {
    my ( $filename, $matching_line, $line_no ) = @_;

    my $ors                 = $opt_print0 ? "\0" : "\n";
    my $is_tracking_context = $opt_after_context || $opt_before_context;

    $matching_line =~ s/[\r\n]+$//g;

    # Check if we need to print context lines first.
    if ( $is_tracking_context ) {
        my $before_unprinted = $line_no - $printed_line_no - 1;
        if ( !$is_first_match && ( !$printed_line_no || $before_unprinted > $n_before_ctx_lines ) ) {
            App::Ack::print('--', $ors);
        }

        # We want at most $n_before_ctx_lines of context.
        if ( $before_unprinted > $n_before_ctx_lines ) {
            $before_unprinted = $n_before_ctx_lines;
        }

        while ( $before_unprinted > 0 ) {
            my $line = $before_context_buf[($before_context_pos - $before_unprinted + $n_before_ctx_lines) % $n_before_ctx_lines];

            chomp $line;

            # Disable $opt->{column} since there are no matches in the context lines.
            local $opt_column = 0;

            print_line_with_options( $filename, $line, $line_no-$before_unprinted, '-' );
            $before_unprinted--;
        }
    }

    print_line_with_options( $filename, $matching_line, $line_no, ':' );

    # We want to get the next $n_after_ctx_lines printed.
    $after_context_pending = $n_after_ctx_lines;

    $is_first_match = 0;

    return;
}

# Print the line only if it's part of a context we need to display.
sub print_line_if_context {
    my ( $filename, $line, $line_no, $separator ) = @_;

    if ( $after_context_pending ) {
        # Disable $opt_column since there are no matches in the context lines.
        local $opt_column = 0;
        print_line_with_options( $filename, $line, $line_no, $separator );
        --$after_context_pending;
    }
    elsif ( $n_before_ctx_lines ) {
        # Save line for "before" context.
        $before_context_buf[$before_context_pos] = $_;
        $before_context_pos = ($before_context_pos+1) % $n_before_ctx_lines;
    }

    return;
}

}

# does_match() MUST have an $opt_regex set.

=begin Developers

This subroutine is inlined a few places in print_matches_in_resource
for performance reasons, so any changes here must be copied there as
well.

=end Developers

=cut

sub does_match {
    my ( $line ) = @_;

    $match_column_number = undef;

    if ( $opt_v ) {
        return ( $line !~ /$opt_regex/o );
    }
    else {
        if ( $line =~ /$opt_regex/o ) {
            # @- = @LAST_MATCH_START
            # @+ = @LAST_MATCH_END
            $match_column_number = $-[0] + 1;
            return 1;
        }
        else {
            return;
        }
    }
}

sub get_match_column {
    return $match_column_number;
}

sub resource_has_match {
    my ( $resource ) = @_;

    my $has_match = 0;
    my $fh = $resource->open();
    if ( !$fh ) {
        if ( $App::Ack::report_bad_filenames ) {
            App::Ack::warn( $resource->name . ': ' . $! );
        }
    }
    else {
        while ( <$fh> ) {
            if (/$opt_regex/o xor $opt_v) {
                $has_match = 1;
                last;
            }
        }
        close $fh;
    }

    return $has_match;
}

sub count_matches_in_resource {
    my ( $resource ) = @_;

    my $nmatches = 0;
    my $fh = $resource->open();
    if ( !$fh ) {
        if ( $App::Ack::report_bad_filenames ) {
            App::Ack::warn( $resource->name . ': ' . $! );
        }
    }
    else {
        while ( <$fh> ) {
            ++$nmatches if (/$opt_regex/o xor $opt_v);
        }
        close $fh;
    }

    return $nmatches;
}

sub main {
    my @arg_sources = App::Ack::ConfigLoader::retrieve_arg_sources();

    my $opt = App::Ack::ConfigLoader::process_args( @arg_sources );

    $opt_after_context  = $opt->{after_context};
    $opt_before_context = $opt->{before_context};
    $opt_output         = $opt->{output};
    $opt_print0         = $opt->{print0};
    $opt_color          = $opt->{color};
    $opt_heading        = $opt->{heading};
    $opt_show_filename  = $opt->{show_filename};
    $opt_regex          = $opt->{regex};
    $opt_break          = $opt->{break};
    $opt_count          = $opt->{count};
    $opt_v              = $opt->{v};
    $opt_m              = $opt->{m};
    $opt_g              = $opt->{g};
    $opt_f              = $opt->{f};
    $opt_lines          = $opt->{lines};
    $opt_L              = $opt->{L};
    $opt_l              = $opt->{l};
    $opt_passthru       = $opt->{passthru};
    $opt_column         = $opt->{column};

    $App::Ack::report_bad_filenames = !$opt->{dont_report_bad_filenames};

    if ( $opt->{flush} ) {
        $| = 1;
    }

    if ( !defined($opt_color) && !$opt_g ) {
        my $windows_color = 1;
        if ( $App::Ack::is_windows ) {
            $windows_color = eval { require Win32::Console::ANSI; };
        }
        $opt_color = !App::Ack::output_to_pipe() && $windows_color;
    }
    if ( not defined $opt_heading and not defined $opt_break  ) {
        $opt_heading = $opt_break = $opt->{break} = !App::Ack::output_to_pipe();
    }

    if ( defined($opt->{H}) || defined($opt->{h}) ) {
        $opt_show_filename = $opt->{show_filename} = $opt->{H} && !$opt->{h};
    }

    if ( my $output = $opt_output ) {
        $output        =~ s{\\}{\\\\}g;
        $output        =~ s{"}{\\"}g;
        $opt_output = qq{"$output"};
    }

    my $resources;
    if ( $App::Ack::is_filter_mode && !$opt->{files_from} ) { # probably -x
        $resources    = App::Ack::Resources->from_stdin( $opt );
        $opt_regex = shift @ARGV if not defined $opt_regex;
        $opt_regex = $opt->{regex} = build_regex( $opt_regex, $opt );
    }
    else {
        if ( $opt_f || $opt_lines ) {
            if ( $opt_regex ) {
                App::Ack::warn( "regex ($opt_regex) specified with -f or --lines" );
                App::Ack::exit_from_ack( 0 ); # XXX the 0 is misleading
            }
        }
        else {
            $opt_regex = shift @ARGV if not defined $opt_regex;
            $opt_regex = $opt->{regex} = build_regex( $opt_regex, $opt );
        }
        if ( $opt_regex && $opt_regex =~ /\n/ ) {
            App::Ack::exit_from_ack( 0 );
        }
        my @start;
        if ( not defined $opt->{files_from} ) {
            @start = @ARGV;
        }
        if ( !exists($opt->{show_filename}) ) {
            unless(@start == 1 && !(-d $start[0])) {
                $opt_show_filename = $opt->{show_filename} = 1;
            }
        }

        if ( defined $opt->{files_from} ) {
            $resources = App::Ack::Resources->from_file( $opt, $opt->{files_from} );
            exit 1 unless $resources;
        }
        else {
            @start = ('.') unless @start;
            foreach my $target (@start) {
                if ( !-e $target && $App::Ack::report_bad_filenames) {
                    App::Ack::warn( "$target: No such file or directory" );
                }
            }

            $opt->{file_filter}    = _compile_file_filter($opt, \@start);
            $opt->{descend_filter} = _compile_descend_filter($opt);

            $resources = App::Ack::Resources->from_argv( $opt, \@start );
        }
    }
    App::Ack::set_up_pager( $opt->{pager} ) if defined $opt->{pager};

    my $ors        = $opt_print0 ? "\0" : "\n";
    my $only_first = $opt->{1};

    my $nmatches    = 0;
    my $total_count = 0;

    set_up_line_context();

RESOURCES:
    while ( my $resource = $resources->next ) {
        if ($is_tracking_context) {
            set_up_line_context_for_file();
        }

        if ( $opt_f ) {
            if ( $opt->{show_types} ) {
                show_types( $resource, $ors );
            }
            else {
                App::Ack::print( $resource->name, $ors );
            }
            ++$nmatches;
            last RESOURCES if defined($opt_m) && $nmatches >= $opt_m;
        }
        elsif ( $opt_g ) {
            if ( $opt->{show_types} ) {
                show_types( $resource, $ors );
            }
            else {
                local $opt_show_filename = 0; # XXX Why is this local?

                print_line_with_options( '', $resource->name, 0, $ors );
            }
            ++$nmatches;
            last RESOURCES if defined($opt_m) && $nmatches >= $opt_m;
        }
        elsif ( $opt_lines ) {
            my %line_numbers;
            foreach my $line ( @{ $opt_lines } ) {
                my @lines             = split /,/, $line;
                @lines                = map {
                    /^(\d+)-(\d+)$/
                        ? ( $1 .. $2 )
                        : $_
                } @lines;
                @line_numbers{@lines} = (1) x @lines;
            }

            my $filename = $resource->name;

            local $opt_color = 0;

            iterate( $resource, sub {
                chomp;

                if ( $line_numbers{$.} ) {
                    print_line_with_context( $filename, $_, $. );
                }
                elsif ( $opt_passthru ) {
                    print_line_with_options( $filename, $_, $., ':' );
                }
                elsif ( $is_tracking_context ) {
                    print_line_if_context( $filename, $_, $., '-' );
                }
                return 1;
            });
        }
        elsif ( $opt_count ) {
            my $matches_for_this_file = count_matches_in_resource( $resource );

            if ( not $opt_show_filename ) {
                $total_count += $matches_for_this_file;
                next RESOURCES;
            }

            if ( !$opt_l || $matches_for_this_file > 0) {
                if ( $opt_show_filename ) {
                    App::Ack::print( $resource->name, ':', $matches_for_this_file, $ors );
                }
                else {
                    App::Ack::print( $matches_for_this_file, $ors );
                }
            }
        }
        elsif ( $opt_l || $opt_L ) {
            my $is_match = resource_has_match( $resource );

            if ( $opt_L ? !$is_match : $is_match ) {
                App::Ack::print( $resource->name, $ors );
                ++$nmatches;

                last RESOURCES if $only_first;
                last RESOURCES if defined($opt_m) && $nmatches >= $opt_m;
            }
        }
        else {
            $nmatches += print_matches_in_resource( $resource, $opt );
            if ( $nmatches && $only_first ) {
                last RESOURCES;
            }
        }
    }

    if ( $opt_count && !$opt_show_filename ) {
        App::Ack::print( $total_count, "\n" );
    }

    close $App::Ack::fh;
    App::Ack::exit_from_ack( $nmatches );
}

=pod

=encoding UTF-8

=head1 NAME

ack - grep-like text finder

=head1 SYNOPSIS

    ack [options] PATTERN [FILE...]
    ack -f [options] [DIRECTORY...]

=head1 DESCRIPTION

ack is designed as an alternative to F<grep> for programmers.

ack searches the named input files or directories for lines containing a
match to the given PATTERN.  By default, ack prints the matching lines.
If no FILE or DIRECTORY is given, the current directory will be searched.

PATTERN is a Perl regular expression.  Perl regular expressions
are commonly found in other programming languages, but for the particulars
of their behavior, please consult
L<http://perldoc.perl.org/perlreref.html|perlreref>.  If you don't know
how to use regular expression but are interested in learning, you may
consult L<http://perldoc.perl.org/perlretut.html|perlretut>.  If you do not
need or want ack to use regular expressions, please see the
C<-Q>/C<--literal> option.

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

With no file selection, I<ack> searches through regular files that
are not explicitly excluded by B<--ignore-dir> and B<--ignore-file>
options, either present in F<ackrc> files or on the command line.

The default options for I<ack> ignore certain files and directories.  These
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
specified.  If no directories are specified, the current working directory is
used.  However, it will ignore the shadow directories used by
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

=item B<--ackrc>

Specifies an ackrc file to load after all others; see L</"ACKRC LOCATION SEMANTICS">.

=item B<-A I<NUM>>, B<--after-context=I<NUM>>

Print I<NUM> lines of trailing context after matching lines.

=item B<-B I<NUM>>, B<--before-context=I<NUM>>

Print I<NUM> lines of leading context before matching lines.

=item B<--[no]break>

Print a break between results from different files. On by default
when used interactively.

=item B<-C [I<NUM>]>, B<--context[=I<NUM>]>

Print I<NUM> lines (default 2) of context around matching lines.
You can specify zero lines of context to override another context
specified in an ackrc.

=item B<-c>, B<--count>

Suppress normal output; instead print a count of matching lines for
each input file.  If B<-l> is in effect, it will only show the
number of lines for each file that has lines matching.  Without
B<-l>, some line counts may be zeroes.

If combined with B<-h> (B<--no-filename>) ack outputs only one total
count.

=item B<--[no]color>, B<--[no]colour>

B<--color> highlights the matching text.  B<--nocolor> suppresses
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

=item B<--[no]column>

Show the column number of the first match.  This is helpful for
editors that can place your cursor at a given position.

=item B<--create-ackrc>

Dumps the default ack options to standard output.  This is useful for
when you want to customize the defaults.

=item B<--dump>

Writes the list of options loaded and where they came from to standard
output.  Handy for debugging.

=item B<--[no]env>

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

=item B<--files-from=I<FILE>>

The list of files to be searched is specified in I<FILE>.  The list of
files are separated by newlines.  If I<FILE> is C<->, the list is loaded
from standard input.

=item B<--[no]filter>

Forces ack to act as if it were receiving input via a pipe.

=item B<--[no]follow>

Follow or don't follow symlinks, other than whatever starting files
or directories were specified on the command line.

This is off by default.

=item B<-g I<PATTERN>>

Print searchable files where the relative path + filename matches
I<PATTERN>.

Note that

    ack -g foo

is exactly the same as

    ack -f | ack foo

This means that just as ack will not search, for example, F<.jpg>
files, C<-g> will not list F<.jpg> files either.  ack is not intended
to be a general-purpose file finder.

Note also that if you have C<-i> in your .ackrc that the filenames
to be matched will be case-insensitive as well.

This option can be combined with B<--color> to make it easier to
spot the match.

=item B<--[no]group>

B<--group> groups matches by file name.  This is the default
when used interactively.

B<--nogroup> prints one result per line, like grep.  This is the
default when output is redirected.

=item B<-H>, B<--with-filename>

Print the filename for each match. This is the default unless searching
a single explicitly specified file.

=item B<-h>, B<--no-filename>

Suppress the prefixing of filenames on output when multiple files are
searched.

=item B<--[no]heading>

Print a filename heading above each file's results.  This is the default
when used interactively.

=item B<--help>, B<-?>

Print a short help statement.

=item B<--help-types>, B<--help=types>

Print all known types.

=item B<-i>, B<--ignore-case>

Ignore case distinctions in PATTERN

=item B<--ignore-ack-defaults>

Tells ack to completely ignore the default definitions provided with ack.
This is useful in combination with B<--create-ackrc> if you I<really> want
to customize ack.

=item B<--[no]ignore-dir=I<DIRNAME>>, B<--[no]ignore-directory=I<DIRNAME>>

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

=item B<--ignore-file=I<FILTERTYPE:FILTERARGS>>

Ignore files matching I<FILTERTYPE:FILTERARGS>.  The filters are specified
identically to file type filters as seen in L</"Defining your own types">.

=item B<-k>, B<--known-types>

Limit selected files to those with types that ack knows about.  This is
equivalent to the default behavior found in ack 1.

=item B<--lines=I<NUM>>

Only print line I<NUM> of each file. Multiple lines can be given with multiple
B<--lines> options or as a comma separated list (B<--lines=3,5,7>). B<--lines=4-7>
also works. The lines are always output in ascending order, no matter the
order given on the command line.

=item B<-l>, B<--files-with-matches>

Only print the filenames of matching files, instead of the matching text.

=item B<-L>, B<--files-without-matches>

Only print the filenames of files that do I<NOT> match.

=item B<--match I<PATTERN>>

Specify the I<PATTERN> explicitly. This is helpful if you don't want to put the
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
If PATTERN matches more than once then a line is output for each non-overlapping match.
For more information please see the section L</"Examples of F<--output>">.

=item B<--pager=I<program>>, B<--nopager>

B<--pager> directs ack's output through I<program>.  This can also be specified
via the C<ACK_PAGER> and C<ACK_PAGER_COLOR> environment variables.

Using --pager does not suppress grouping and coloring like piping
output on the command-line does.

B<--nopager> cancels any setting in ~/.ackrc, C<ACK_PAGER> or C<ACK_PAGER_COLOR>.
No output will be sent through a pager.

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

=item B<-r>, B<-R>, B<--recurse>

Recurse into sub-directories. This is the default and just here for
compatibility with grep. You can also use it for turning B<--no-recurse> off.

=item B<-s>

Suppress error messages about nonexistent or unreadable files.  This is taken
from fgrep.

=item B<--[no]smart-case>, B<--no-smart-case>

Ignore case in the search strings if PATTERN contains no uppercase
characters. This is similar to C<smartcase> in vim. This option is
off by default, and ignored if C<-i> is specified.

B<-i> always overrides this option.

=item B<--sort-files>

Sorts the found files lexicographically.  Use this if you want your file
listings to be deterministic between runs of I<ack>.

=item B<--show-types>

Outputs the filetypes that ack associates with each file.

Works with B<-f> and B<-g> options.

=item B<--type=[no]TYPE>

Specify the types of files to include or exclude from a search.
TYPE is a filetype, like I<perl> or I<xml>.  B<--type=perl> can
also be specified as B<--perl>, and B<--type=noperl> can be done
as B<--noperl>.

If a file is of both type "foo" and "bar", specifying --foo and
--nobar will exclude the file, because an exclusion takes precedence
over an inclusion.

Type specifications can be repeated and are ORed together.

See I<ack --help=types> for a list of valid types.

=item B<--type-add I<TYPE>:I<FILTER>:I<FILTERARGS>>

Files with the given FILTERARGS applied to the given FILTER
are recognized as being of (the existing) type TYPE.
See also L</"Defining your own types">.


=item B<--type-set I<TYPE>:I<FILTER>:I<FILTERARGS>>

Files with the given FILTERARGS applied to the given FILTER are recognized as
being of type TYPE. This replaces an existing definition for type TYPE.  See
also L</"Defining your own types">.

=item B<--type-del I<TYPE>>

The filters associated with TYPE are removed from Ack, and are no longer considered
for searches.

=item B<-v>, B<--invert-match>

Invert match: select non-matching lines

=item B<--version>

Display version and copyright information.

=item B<-w>, B<--word-regexp>

=item B<-w>, B<--word-regexp>

Turn on "words mode".  This sometimes matches a whole word, but the
semantics is quite subtle.  If the passed regexp begins with a word
character, then a word boundary is required before the match.  If the
passed regexp ends with a word character, or with a word character
followed by newline, then a word boundary is required after the match.

Thus, for example, B<-w> with the regular expression C<ox> will not
match the strings C<box> or C<oxen>.  However, if the regular
expression is C<(ox|ass)> then it will match those strings.  Because
the regular expression's first character is C<(>, the B<-w> flag has
no effect at the start, and because the last character is C<)>, it has
no effect at the end.

Force PATTERN to match only whole words.  The PATTERN is wrapped with
C<\b> metacharacters.

=item B<-x>

An abbreviation for B<--files-from=->; the list of files to search are read
from standard input, with one line per file.

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

=item B<--cathy>

Chocolate, Chocolate, Chocolate!

=back

=head1 THE .ackrc FILE

The F<.ackrc> file contains command-line options that are prepended
to the command line before processing.  Multiple options may live
on multiple lines.  Lines beginning with a # are ignored.  A F<.ackrc>
might look like this:

    # Always sort the files
    --sort-files

    # Always color, even if piping to another program
    --color

    # Use "less -r" as my pager
    --pager=less -r

Note that arguments with spaces in them do not need to be quoted,
as they are not interpreted by the shell. Basically, each I<line>
in the F<.ackrc> file is interpreted as one element of C<@ARGV>.

F<ack> looks in several locations for F<.ackrc> files; the searching
process is detailed in L</"ACKRC LOCATION SEMANTICS">.  These
files are not considered if B<--noenv> is specified on the command line.

=head1 Defining your own types

ack allows you to define your own types in addition to the predefined
types. This is done with command line options that are best put into
an F<.ackrc> file - then you do not have to define your types over and
over again. In the following examples the options will always be shown
on one command line so that they can be easily copy & pasted.

File types can be specified both with the the I<--type=xxx> option,
or the file type as an option itself.  For example, if you create
a filetype of "cobol", you can specify I<--type=cobol> or simply
I<--cobol>.  File types must be at least two characters long.  This
is why the C language is I<--cc> and the R language is I<--rr>.

I<ack --perl foo> searches for foo in all perl files. I<ack --help=types>
tells you, that perl files are files ending
in .pl, .pm, .pod or .t. So what if you would like to include .xs
files as well when searching for --perl files? I<ack --type-add perl:ext:xs --perl foo>
does this for you. B<--type-add> appends
additional extensions to an existing type.

If you want to define a new type, or completely redefine an existing
type, then use B<--type-set>. I<ack --type-set eiffel:ext:e,eiffel> defines
the type I<eiffel> to include files with
the extensions .e or .eiffel. So to search for all eiffel files
containing the word Bertrand use I<ack --type-set eiffel:ext:e,eiffel --eiffel Bertrand>.
As usual, you can also write B<--type=eiffel>
instead of B<--eiffel>. Negation also works, so B<--noeiffel> excludes
all eiffel files from a search. Redefining also works: I<ack --type-set cc:ext:c,h>
and I<.xs> files no longer belong to the type I<cc>.

When defining your own types in the F<.ackrc> file you have to use
the following:

  --type-set=eiffel:ext:e,eiffel

or writing on separate lines

  --type-set
  eiffel:ext:e,eiffel

The following does B<NOT> work in the F<.ackrc> file:

  --type-set eiffel:ext:e,eiffel

In order to see all currently defined types, use I<--help-types>, e.g.
I<ack --type-set backup:ext:bak --type-add perl:ext:perl --help-types>

In addition to filtering based on extension (like ack 1.x allowed), ack 2
offers additional filter types.  The generic syntax is
I<--type-set TYPE:FILTER:FILTERARGS>; I<FILTERARGS> depends on the value
of I<FILTER>.

=over 4

=item is:I<FILENAME>

I<is> filters match the target filename exactly.  It takes exactly one
argument, which is the name of the file to match.

Example:

    --type-set make:is:Makefile

=item ext:I<EXTENSION>[,I<EXTENSION2>[,...]]

I<ext> filters match the extension of the target file against a list
of extensions.  No leading dot is needed for the extensions.

Example:

    --type-set perl:ext:pl,pm,t

=item match:I<PATTERN>

I<match> filters match the target filename against a regular expression.
The regular expression is made case insensitive for the search.

Example:

    --type-set make:match:/(gnu)?makefile/

=item firstlinematch:I<PATTERN>

I<firstlinematch> matches the first line of the target file against a
regular expression.  Like I<match>, the regular expression is made
case insensitive.

Example:

    --type-add perl:firstlinematch:/perl/

=back

More filter types may be made available in the future.

=head1 ENVIRONMENT VARIABLES

For commonly-used ack options, environment variables can make life
much easier.  These variables are ignored if B<--noenv> is specified
on the command line.

=over 4

=item ACKRC

Specifies the location of the user's F<.ackrc> file.  If this file doesn't
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

=head1 AVAILABLE COLORS

F<ack> uses the colors available in Perl's L<Term::ANSIColor> module, which
provides the following listed values. Note that case does not matter when using
these values.

=head2 Foreground colors

    black  red  green  yellow  blue  magenta  cyan  white

    bright_black  bright_red      bright_green  bright_yellow
    bright_blue   bright_magenta  bright_cyan   bright_white

=head2 Background colors

    on_black  on_red      on_green  on_yellow
    on_blue   on_magenta  on_cyan   on_white

    on_bright_black  on_bright_red      on_bright_green  on_bright_yellow
    on_bright_blue   on_bright_magenta  on_bright_cyan   on_bright_white

=head1 ACK & OTHER TOOLS

=head2 Simple vim integration

F<ack> integrates easily with the Vim text editor. Set this in your
F<.vimrc> to use F<ack> instead of F<grep>:

    set grepprg=ack\ -k

That example uses C<-k> to search through only files of the types ack
knows about, but you may use other default flags. Now you can search
with F<ack> and easily step through the results in Vim:

  :grep Dumper perllib

=head2 Editor integration

Many users have integrated ack into their preferred text editors.
For details and links, see L<https://beyondgrep.com/more-tools/>.

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

=head2 Use B<--dump>

This lists the ackrc files that are loaded and the options loaded
from them.
So for example you can find a list of directories that do not get searched or where filetypes are defined.

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

=head2 Examples of F<--output>

Following variables are useful in the expansion string:

=over 4

=item C<$&>

The whole string matched by PATTERN.

=item C<$1>, C<$2>, ...

The contents of the 1st, 2nd ... bracketed group in PATTERN.

=item C<$`>

The string before the match.

=item C<$'>

The string after the match.

=back

For more details and other variables see
L<http://perldoc.perl.org/perlvar.html#Variables-related-to-regular-expressions|perlvar>.

This example shows how to add text around a particular pattern
(in this case adding _ around word with "e")

    ack2.pl "\w*e\w*" quick.txt --output="$`_$&_$'"
    _The_ quick brown fox jumps over the lazy dog
    The quick brown fox jumps _over_ the lazy dog
    The quick brown fox jumps over _the_ lazy dog

This shows how to pick out particular parts of a match using ( ) within regular expression.

  ack '=head(\d+)\s+(.*)' --output=' $1 : $2'
  input file contains "=head1 NAME"
  output  "1 : NAME"

=head1 COMMUNITY

There are ack mailing lists and a Slack channel for ack.  See
L<https://beyondgrep.com/community/> for details.

=head1 FAQ

=head2 Why isn't ack finding a match in (some file)?

First, take a look and see if ack is even looking at the file.  ack is
intelligent in what files it will search and which ones it won't, but
sometimes that can be surprising.

Use the C<-f> switch, with no regex, to see a list of files that ack
will search for you.  If your file doesn't show up in the list of files
that C<ack -f> shows, then ack never looks in it.

NOTE: If you're using an old ack before 2.0, it's probably because it's of
a type that ack doesn't recognize.  In ack 1.x, the searching behavior is
driven by filetype.  B<If ack 1.x doesn't know what kind of file it is,
ack ignores the file.>  You can use the C<--show-types> switch to show
which type ack thinks each file is.

=head2 Wouldn't it be great if F<ack> did search & replace?

No, ack will always be read-only.  Perl has a perfectly good way
to do search & replace in files, using the C<-i>, C<-p> and C<-n>
switches.

You can certainly use ack to select your files to update.  For
example, to change all "foo" to "bar" in all PHP files, you can do
this from the Unix shell:

    $ perl -i -p -e's/foo/bar/g' $(ack -f --php)

=head2 Can I make ack recognize F<.xyz> files?

Yes!  Please see L</"Defining your own types">.  If you think
that F<ack> should recognize a type by default, please see
L</"ENHANCEMENTS">.

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

Alternatively, you could use a shell alias:

    # bash/zsh
    alias ack=ack-grep

    # csh
    alias ack ack-grep

=head2 What does F<ack> mean?

Nothing.  I wanted a name that was easy to type and that you could
pronounce as a single syllable.

=head2 Can I do multi-line regexes?

No, ack does not support regexes that match multiple lines.  Doing
so would require reading in the entire file at a time.

If you want to see lines near your match, use the C<--A>, C<--B>
and C<--C> switches for displaying context.

=head2 Why is ack telling me I have an invalid option when searching for C<+foo>?

ack treats command line options beginning with C<+> or C<-> as options; if you
would like to search for these, you may prefix your search term with C<--> or
use the C<--match> option.  (However, don't forget that C<+> is a regular
expression metacharacter!)

=head2 Why does C<"ack '.{40000,}'"> fail?  Isn't that a valid regex?

The Perl language limits the repetition quantifier to 32K.  You
can search for C<.{32767}> but not C<.{32768}>.

=head2 Ack does "X" and shouldn't, should it?

We try to remain as close to grep's behavior as possible, so when in doubt,
see what grep does!  If there's a mismatch in functionality there, please
bring it up on the ack-users mailing list.

=head1 ACKRC LOCATION SEMANTICS

Ack can load its configuration from many sources.  The following list
specifies the sources Ack looks for configuration files; each one
that is found is loaded in the order specified here, and
each one overrides options set in any of the sources preceding
it.  (For example, if I set --sort-files in my user ackrc, and
--nosort-files on the command line, the command line takes
precedence)

=over 4

=item *

Defaults are loaded from App::Ack::ConfigDefaults.  This can be omitted
using C<--ignore-ack-defaults>.

=item * Global ackrc

Options are then loaded from the global ackrc.  This is located at
C</etc/ackrc> on Unix-like systems.

Under Windows XP and earlier, the global ackrc is at
C<C:\Documents and Settings\All Users\Application Data\ackrc>

Under Windows Vista/7, the global ackrc is at
C<C:\ProgramData\ackrc>

The C<--noenv> option prevents all ackrc files from being loaded.

=item * User ackrc

Options are then loaded from the user's ackrc.  This is located at
C<$HOME/.ackrc> on Unix-like systems.

Under Windows XP and earlier, the user's ackrc is at
C<C:\Documents and Settings\$USER\Application Data\ackrc>.

Under Windows Vista/7, the user's ackrc is at
C<C:\Users\$USER\AppData\Roaming\ackrc>.

If you want to load a different user-level ackrc, it may be specified
with the C<$ACKRC> environment variable.

The C<--noenv> option prevents all ackrc files from being loaded.

=item * Project ackrc

Options are then loaded from the project ackrc.  The project ackrc is
the first ackrc file with the name C<.ackrc> or C<_ackrc>, first searching
in the current directory, then the parent directory, then the grandparent
directory, etc.  This can be omitted using C<--noenv>.

=item * --ackrc

The C<--ackrc> option may be included on the command line to specify an
ackrc file that can override all others.  It is consulted even if C<--noenv>
is present.

=item * ACK_OPTIONS

Options are then loaded from the environment variable C<ACK_OPTIONS>.  This can
be omitted using C<--noenv>.

=item * Command line

Options are then loaded from the command line.

=back

=head1 DIFFERENCES BETWEEN ACK 1.X AND ACK 2.X

A lot of changes were made for ack 2; here is a list of them.

=head2 GENERAL CHANGES

=over 4

=item *

When no selectors are specified, ack 1.x only searches through files that
it can map to a file type.  ack 2.x, by contrast, will search through
every regular, non-binary file that is not explicitly ignored via
B<--ignore-file> or B<--ignore-dir>.  This is similar to the behavior of the
B<-a/--all> option in ack 1.x.

=item *

A more flexible filter system has been added, so that more powerful file types
may be created by the user.  For details, please consult
L</"Defining your own types">.

=item *

ack now loads multiple ackrc files; see L</"ACKRC LOCATION SEMANTICS"> for
details.

=item *

ack's default filter definitions aren't special; you may tell ack to
completely disregard them if you don't like them.

=back

=head2 REMOVED OPTIONS

=over 4

=item *

Because of the change in default search behavior, the B<-a/--all> and
B<-u/--unrestricted> options have been removed.  In addition, the
B<-k/--known-types> option was added to cause ack to behave with
the default search behavior of ack 1.x.

=item *

The B<-G> option has been removed.  Two regular expressions on the
command line was considered too confusing; to simulate B<-G>'s functionality,
you may use the new B<-x> option to pipe filenames from one invocation of
ack into another.

=item *

The B<--binary> option has been removed.

=item *

The B<--skipped> option has been removed.

=item *

The B<--text> option has been removed.

=item *

The B<--invert-file-match> option has been removed.  Instead, you may
use B<-v> with B<-g>.

=back

=head2 CHANGED OPTIONS

=over 4

=item *

The options that modify the regular expression's behavior (B<-i>, B<-w>,
B<-Q>, and B<-v>) may now be used with B<-g>.

=back

=head2 ADDED OPTIONS

=over 4

=item *

B<--files-from> was added so that a user may submit a list of filenames as
a list of files to search.

=item *

B<-x> was added to tell ack to accept a list of filenames via standard input;
this list is the list of filenames that will be used for the search.

=item *

B<-s> was added to tell ack to suppress error messages about non-existent or
unreadable files.

=item *

B<--ignore-directory> and B<--noignore-directory> were added as aliases for
B<--ignore-dir> and B<--noignore-dir> respectively.

=item *

B<--ignore-file> was added so that users may specify patterns of files to
ignore (ex. /.*~$/).

=item *

B<--dump> was added to allow users to easily find out which options are
set where.

=item *

B<--create-ackrc> was added so that users may create custom ackrc files based
on the default settings loaded by ack, and so that users may easily view those
defaults.

=item *

B<--type-del> was added to selectively remove file type definitions.

=item *

B<--ignore-ack-defaults> was added so that users may ignore ack's default
options in favor of their own.

=item *

B<--bar> was added so ack users may consult Admiral Ackbar.

=back

=head1 AUTHOR

Andy Lester, C<< <andy at petdance.com> >>

=head1 BUGS

Please report any bugs or feature requests to the issues list at
Github: L<https://github.com/beyondgrep/ack2/issues>

=head1 ENHANCEMENTS

All enhancement requests MUST first be posted to the ack-users
mailing list at L<http://groups.google.com/group/ack-users>.  I
will not consider a request without it first getting seen by other
ack users.  This includes requests for new filetypes.

There is a list of enhancements I want to make to F<ack> in the ack
issues list at Github: L<https://github.com/beyondgrep/ack2/issues>

Patches are always welcome, but patches with tests get the most
attention.

=head1 SUPPORT

Support for and information about F<ack> can be found at:

=over 4

=item * The ack homepage

L<https://beyondgrep.com/>

=item * The ack-users mailing list

L<http://groups.google.com/group/ack-users>

=item * The ack issues list at Github

L<https://github.com/beyondgrep/ack2/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ack>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ack>

=item * Search CPAN

L<http://search.cpan.org/dist/ack>

=item * MetaCPAN

L<http://metacpan.org/release/ack>

=item * Git source repository

L<https://github.com/beyondgrep/ack2>

=back

=head1 ACKNOWLEDGEMENTS

How appropriate to have I<ack>nowledgements!

Thanks to everyone who has contributed to ack in any way, including
Michele Campeotto,
H.Merijn Brand,
Duke Leto,
Gerhard Poul,
Ethan Mallove,
Marek Kubica,
Ray Donnelly,
Nikolaj Schumacher,
Ed Avis,
Nick Morrott,
Austin Chamberlin,
Varadinsky,
SE<eacute>bastien FeugE<egrave>re,
Jakub Wilk,
Pete Houston,
Stephen Thirlwall,
Jonah Bishop,
Chris Rebert,
Denis Howe,
RaE<uacute>l GundE<iacute>n,
James McCoy,
Daniel Perrett,
Steven Lee,
Jonathan Perret,
Fraser Tweedale,
RaE<aacute>l GundE<aacute>n,
Steffen Jaeckel,
Stephan Hohe,
Michael Beijen,
Alexandr Ciornii,
Christian Walde,
Charles Lee,
Joe McMahon,
John Warwick,
David Steinbrunner,
Kara Martens,
Volodymyr Medvid,
Ron Savage,
Konrad Borowski,
Dale Sedivic,
Michael McClimon,
Andrew Black,
Ralph Bodenner,
Shaun Patterson,
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

Copyright 2005-2017 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

See http://www.perlfoundation.org/artistic_license_2_0 or the LICENSE.md
file that comes with the ack distribution.

=cut
