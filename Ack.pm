package App::Ack;

use warnings;
use strict;

=head1 NAME

App::Ack

=head1 DESCRIPTION

A container for functions for the ack program.

=head1 VERSION

Version 2.28

=cut

our $VERSION;
our $COPYRIGHT;
BEGIN {
    $VERSION = '2.28';
    $COPYRIGHT = 'Copyright 2005-2019 Andy Lester.';
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

BEGIN {
    # These have to be checked before any filehandle diddling.
    $output_to_pipe  = not -t *STDOUT;
    $is_filter_mode = -p STDIN;

    $is_cygwin       = ($^O eq 'cygwin' || $^O eq 'msys');
    $is_windows      = ($^O eq 'MSWin32');
    $dir_sep_chars   = $is_windows ? quotemeta( '\\/' ) : quotemeta( File::Spec->catfile( '', '' ) );
}

=head1 SYNOPSIS

If you want to know about the F<ack> program, see the F<ack> file itself.

No user-serviceable parts inside.  F<ack> is all that should use this.

=head1 FUNCTIONS

=cut

=head2 remove_dir_sep( $path )

This functions removes a trailing path separator, if there is one, from its argument

=cut

sub remove_dir_sep {
    my $path = shift;
    $path =~ s/[$dir_sep_chars]$//;

    return $path;
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

sub thpppt {
    my $y = q{_   /|,\\'!.x',=(www)=,   U   };
    $y =~ tr/,x!w/\nOo_/;

    App::Ack::print( "$y ack $_[0]!\n" );
    exit 0;
}

sub ackbar {
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

    return _pic_decode($x);
}

sub cathy {
    my $x = <<'CATHY';
 0+!--+!
 0|! "C!H!O!C!O!L!A!T!E!!! !|!
 0|! "C!H!O!C!O!L!A!T!E!!! !|!
 0|! "C!H!O!C!O!L!A!T!E!!! !|!
 0|! $A"C!K!!! $|!
 0+!--+!
 6\! 1:!,!.! !
 7\! /.!M!~!Z!M!~!
 8\! /~!D! "M! !
 4.! $\! /M!~!.!8! +.!M# 4
 0,!.! (\! .~!M!N! ,+!I!.!M!.! 3
 /?!O!.!M!:! '\! .O!.! +~!Z!=!N!.! 4
 ..! !D!Z!.!Z!.! '\! 9=!M".! 6
 /.! !.!~!M".! '\! 8~! 9
 4M!.! /.!7!N!M!.! F
 4.! &:!M! !N"M# !M"N!M! #D!M&=! =
 :M!7!M#:! !~!M!7!,!$!M!:! #.! !O!N!.!M!:!M# ;
 8Z!M"~!N!$!D!.!N!?! !I!N!.! (?!M! !M!,!D!M".! 9
 (?!Z!M!N!:! )=!M!O!8!.!M!+!M! !M!,! !O!M! +,!M!.!M!~!Z!N!M!:! &:!~! 0
 &8!7!.!~!M"D!M!,! &M!?!=!8! !M!,!O! !M!+! !+!O!.!M! $M#~! !.!8!M!Z!.!M! !O!M"Z! %:!~!M!Z!M!Z!.! +
 &:!M!7!,! *M!.!Z!M! !8"M!.!M!~! !.!M!.!=! #~!8!.!M! !7!M! "N!Z#I! !D!M!,!M!.! $."M!,! !M!.! *
 2$!O! "N! !.!M!I! !7" "M! "+!O! !~!M! !d!O!.!7!I!M!.! !.!O!=!M!.! !M",!M!.! %.!$!O!D! +
 1~!O! "M!+! !8!$! "M! "?!O! %Z!8!D!M!?!8!I!O!7!M! #M!.!M! "M",!M! 4
 07!~! ".!8! !.!M! "I!+! !.!M! &Z!D!.!7!=!M! !:!.!M! #:!8"+! !.!+!8! !8! 3
 /~!M! #N! !~!M!$! !.!M! !.!M" &~!M! "~!M!O! "D! $M! !8! "M!,!M!+!D!.! 1
 #.! #?!M!N!.! #~!O! $M!.!7!$! "?" !?!~!M! '7!8!?!M!.!+!M"O! $?"$!D! !.!O! !$!7!I!.! 0
 $,!M!:!O!?! ".! !?!=! $=!:!O! !M! "M! !M! !+!$! (.! +.!M! !M!.! !8! !+"Z!~! $:!M!$! !.! '
 #.!8!.!I!$! $7!I! %M" !=!M! !~!M!D! "7!I! .I!O! %?!=!,!D! !,!M! !D!~!8!~! %D!M! (
 #.!M"?! $=!O! %=!N! "8!.! !Z!M! #M!~! (M!:! #.!M" &O! !M!.! !?!,! !8!.!N!~! $8!N!M!,!.! %
 *$!O! &M!,! "O! !.!M!.! #M! (~!M( &O!.! !7! "M! !.!M!.!M!,! #.!M! !M! &
 )=!8!.! $.!M!O!.! "$!.!I!N! !I!M# (7!M(I! %D"Z!M! "=!I! "M! !M!:! #~!D! '
 )D! &8!N!:! ".!O! !M!="M! "M! (7!M) %." !M!D!."M!.! !$!=! !M!,! +
 (M! &+!.!M! #Z!7!O!M!.!~!8! +,!M#D!?!M#D! #.!Z!M#,!Z!?! !~!N! "N!.! !M! +
 'D!:! %$!D! !?! #M!Z! !8!.! !M"?!7!?!7! '+!I!D! !?!O!:!M!:! ":!M!:! !M!7".!M! "8!+! !:!D! !.!M! *
 %.!O!:! $.!O!+! !D!.! #M! "M!.!+!N!I!Z! "7!M!N!M!N!?!I!7!Z!=!M'D"~! #M!.!8!$! !:! !.!M! "N!?! !,!O! )
 !.!?!M!:!M!I! %8!,! "M!.! #M! "N! !M!.! !M!.! !+!~! !.!M!.! ':!M! $M! $M!Z!$! !M!.! "D! "M! "?!M! (
 !7!8! !+!I! ".! "$!=! ":!$! "+! !M!.! !O! !M!I!M".! !=!~! ",!O! '=!M! $$!,! #N!:! ":!8!.! !D!~! !,!M!.! !:!M!.! &
 !:!,!.! &Z" #D! !.!8!."M!.! !8!?!Z!M!.!M! #Z!~! !?!M!Z!.! %~!O!.!8!$!N!8!O!I!:!~! !+! #M!.! !.!M!.! !+!M! ".!~!M!+! $
 !.! 'D!I! #?!M!.!M!,! !.!Z! !.!8! #M&O!I!?! (~!I!M"." !M!Z!.! !M!N!.! "+!$!.! "M!.! !M!?!.! "8!M! $
 (O!8! $M! !M!.! ".!:! !+!=! #M! #.!M! !+" *$!M":!.! !M!~! "M!7! #M! #7!Z! "M"$!M!.! !.! #
 '$!Z! #.!7!+!M! $.!,! !+!:! #N! #.!M!.!+!M! +D!M! #=!N! ":!O! #=!M! #Z!D! $M!I! %
 $,! ".! $.!M" %$!.! !?!~! "+!7!." !.!M!,! !M! *,!N!M!.$M!?! "D!,! #M!.! #N! +
 ,M!Z! &M! "I!,! "M! %I!M! !?!=!.! (Z!8!M! $:!M!.! !,!M! $D! #.!M!.! )
 +8!O! &.!8! "I!,! !~!M! &N!M! !M!D! '?!N!O!." $?!7! "?!~! #M!.! #I!D!.! (
 3M!,! "N!.! !D" &.!+!M!.! !M":!.":!M!7!M!D! 'M!.! "M!.! "M!,! $I! )
 3I! #M! "M!,! !:! &.!M" ".!,! !.!$!M!I! #.! !:! !.!M!?! "N!+! ".! /
 1M!,! #.!M!8!M!=!.! +~!N"O!Z"~! *+!M!.! "M! 2
 0.!M! &M!.! 8:! %.!M!Z! "M!=! *O!,! %
 0?!$! &N! )." .,! %."M! ":!M!.! 0
 0N!:! %?!O! #.! ..! &,! &.!D!,! "N!I! 0
CATHY
    return _pic_decode($x);
}

sub _pic_decode {
    my($compressed) = @_;
    $compressed =~ s/(.)(.)/$1x(ord($2)-32)/eg;
    App::Ack::print( $compressed );
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
  --lines=NUMS                  Only print line(s) NUMS of each file.
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

  -A NUM, --after-context=NUM   Print NUM lines of trailing context after
                                matching lines.
  -B NUM, --before-context=NUM  Print NUM lines of leading context before
                                matching lines.
  -C [NUM], --context[=NUM]     Print NUM lines (default 2) of output context.

  --print0                      Print null byte as separator between filenames,
                                only works with -f, -g, -l, -L or -c.

  -s                            Suppress error messages about nonexistent or
                                unreadable files.


File presentation:
  --pager=COMMAND               Pipes all ack output through COMMAND.  For
                                example, --pager="less -R".  Ignored if output
                                is redirected.
  --nopager                     Do not send output through a pager.  Cancels
                                any setting in ~/.ackrc, ACK_PAGER or
                                ACK_PAGER_COLOR.
  --[no]heading                 Print a filename heading above each file's
                                results.  (default: on when used interactively)
  --[no]break                   Print a break between results from different
                                files.  (default: on when used interactively)
  --group                       Same as --heading --break
  --nogroup                     Same as --noheading --nobreak
  --[no]color                   Highlight the matching text (default: on unless
                                output is redirected, or on Windows)
  --[no]colour                  Same as --[no]color
  --color-filename=COLOR
  --color-match=COLOR
  --color-lineno=COLOR          Set the color for filenames, matches, and line
                                numbers.
  --help-colors                 Show a list of possible color combinations.
  --help-rgb-colors             Show a list of advanced color specifications.
  --flush                       Flush output immediately, even when ack is used
                                non-interactively (when output goes to a pipe or
                                file).


File finding:
  -f                            Only print the files selected, without
                                searching.  The PATTERN must not be specified.
  -g                            Same as -f, but only select files matching
                                PATTERN.
  --sort-files                  Sort the found files lexically.
  --show-types                  Show which types each file has.
  --files-from=FILE             Read the list of files to search from FILE.
  -x                            Read the list of files to search from STDIN.

File inclusion/exclusion:
  --[no]ignore-dir=name         Add/remove directory from list of ignored dirs
  --[no]ignore-directory=name   Synonym for ignore-dir
  --ignore-file=filter          Add filter for ignoring files
  -r, -R, --recurse             Recurse into subdirectories (default: on)
  -n, --no-recurse              No descending into subdirectories
  --[no]follow                  Follow symlinks.  Default is off.
  -k, --known-types             Include only files of types that ack recognizes.

  --type=X                      Include only X files, where X is a recognized
                                filetype.
  --type=noX                    Exclude X files.
                                See "ack --help-types" for supported filetypes.
  --max-file-size=NUM, --max-size=NUM
                                Excludes files larger than this size (in bytes)
  --min-file-size=NUM, --min-size=NUM
                                Excludes files smaller than this size (in bytes)

File type specification:
  --type-set TYPE:FILTER:FILTERARGS
                                Files with the given FILTERARGS applied to the
                                given FILTER are recognized as being of type
                                TYPE. This replaces an existing definition for
                                type TYPE.
  --type-add TYPE:FILTER:FILTERARGS
                                Files with the given FILTERARGS applied to the
                                given FILTER are recognized as being type TYPE.
  --type-del TYPE               Removes all filters associated with TYPE.


Miscellaneous:
  --[no]env                     Ignore environment variables and global ackrc
                                files.  --env is legal but redundant.
  --ackrc=filename              Specify an ackrc file to use
  --ignore-ack-defaults         Ignore default definitions included with ack.
  --create-ackrc                Outputs a default ackrc for your customization
                                to standard output.
  --help, -?                    This help
  --help-types                  Display all known types
  --help-types                  Display all known types, and how they're defined.
  --help-colors                 Show a list of possible color combinations.
  --help-rgb-colors             Show a list of advanced color specifications.
  --dump                        Dump information on which options are loaded
                                from which RC files
  --[no]filter                  Force ack to treat standard input as a pipe
                                (--filter) or tty (--nofilter)
  --man                         Man page
  --version                     Display version & copyright
  --thpppt                      Bill the Cat
  --bar                         The warning admiral
  --cathy                       Chocolate! Chocolate! Chocolate!

Exit status is 0 if match, 1 if no match.

ack's home page is at https://beyondgrep.com/

The full ack manual is available by running "ack --man".

This is version $VERSION of ack.  Run "ack --version" for full version info.
END_OF_HELP

    return;
 }


=head2 show_help_colors()

Display the colors help subpage.

=cut

sub show_help_colors {
    App::Ack::print( <<'END_OF_HELP' );
ack allows customization of the colors it uses when presenting matches
onscreen.  See the "ACK COLORS" section of the ack manual (ack --man).

Here is a chart of how various color combinations appear: Each of the eight
foreground colors, on each of the eight background colors or no background
color, with and without the bold modifier.

Run ack --help-rgb-colors for a chart of the RGB colors.

END_OF_HELP

    _show_color_grid();

    return;
}


=head2 show_help_rgb()

Display the RGB help subpage.

=cut

sub show_help_rgb {
    App::Ack::print( <<'END_OF_HELP' );
ack allows customization of the colors it uses when presenting matches
onscreen.  See the "ACK COLORS" section of the ack manual (ack --man).

Colors may be specified as "rggNNN" where "NNN" is a triplet of digits
from 0 to 5 specifying the intensity of red, green and blue, respectively.

Here is a grid of the 216 possible values for NNN.

END_OF_HELP

    _show_rgb_grid();

    App::Ack::say( 'Here are the 216 possible colors with the "reverse" modifier applied.', "\n" );

    _show_rgb_grid( 'reverse' );

   return;
}


sub _show_color_grid {
    my $cell_width = 7;

    my @fg_colors = qw( black red green yellow blue magenta cyan white );
    my @bg_colors = map { "on_$_" } @fg_colors;

    App::Ack::say(
        _color_cell( '' ),
        map { _color_cell( $_ ) } @fg_colors
    );

    App::Ack::say(
        _color_cell( '' ),
        map { _color_cell( '-' x $cell_width ) } @fg_colors
    );

    for my $bg ( '', @bg_colors ) {
        App::Ack::say(
            _color_cell( '' ),
            ( map { _color_cell( $_, "$_ $bg" ) } @fg_colors ),
           $bg
        );

        App::Ack::say(
           _color_cell( 'bold' ),
            ( map { _color_cell( $_, "bold $_ $bg" ) } @fg_colors ),
            $bg
        );
       App::Ack::say();
    }

   return;
}


sub _color_cell {
    my $text  = shift;
    my $color = shift;

    my $cell_width = 7;
    $text = sprintf( '%-*s', $cell_width, $text );

    return ($color ? Term::ANSIColor::colored( $text, $color ) : $text) . ' ';
}


sub _show_rgb_grid {
    my $modifier = shift || '';

    my $grid = <<'HERE';
544 544 544 544 544 554 554 554 554 554 454 454 454 454 454 455 455 455 455 455 445 445 445 445 445 545 545 545 545 545
533 533 533 543 543 553 553 553 453 453 353 353 353 354 354 355 355 355 345 345 335 335 335 435 435 535 535 535 534 534
511 521 531 531 541 551 451 451 351 251 151 152 152 153 154 155 145 145 135 125 115 215 215 315 415 515 514 514 513 512
500 510 520 530 540 550 450 350 250 150 050 051 052 053 054 055 045 035 025 015 005 105 205 305 405 505 504 503 502 501
400 410 410 420 430 440 340 340 240 140 040 041 041 042 043 044 034 034 024 014 004 104 104 204 304 404 403 403 402 401
300 300 310 320 320 330 330 230 130 130 030 030 031 032 032 033 033 023 013 013 003 003 103 203 203 303 303 302 301 301
200 200 200 210 210 220 220 220 120 120 020 020 020 021 021 022 022 022 012 012 002 002 002 102 102 202 202 202 201 201
100 100 100 100 100 110 110 110 110 110 010 010 010 010 010 011 011 011 011 011 001 001 001 001 001 101 101 101 101 101

522 522 532 542 542 552 552 452 352 352 252 252 253 254 254 255 255 245 235 235 225 225 325 425 425 525 525 524 523 523

411 411 421 431 431 441 441 341 241 241 141 141 142 143 143 144 144 134 124 124 114 114 214 314 314 414 414 413 412 412

422 422 432 432 432 442 442 442 342 342 242 242 242 243 243 244 244 244 234 234 224 224 224 324 324 424 424 424 423 423

311 311 311 321 321 331 331 331 231 231 131 131 131 132 132 133 133 133 123 123 113 113 113 213 213 313 313 313 312 312

433 433 433 433 433 443 443 443 443 443 343 343 343 343 343 344 344 344 344 344 334 334 334 334 334 434 434 434 434 434
211 211 211 211 211 221 221 221 221 221 121 121 121 121 121 122 122 122 122 122 112 112 112 112 112 212 212 212 212 212

322 322 322 322 322 332 332 332 332 332 232 232 232 232 232 233 233 233 233 233 223 223 223 223 223 323 323 323 323 323

555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555
444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444
333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333
222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222
111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111
000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000
HERE

    $grid =~ s/(\d\d\d)/Term::ANSIColor::colored( "$1", "$modifier rgb$1" )/eg;

    App::Ack::say( $grid );

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

    return <<"END_OF_VERSION";
ack ${VERSION}
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


sub print                   { print {$fh} @_; return; }
sub say                     { print {$fh} @_, "\n"; return; }
sub print_blank_line        { App::Ack::print( "\n" ); return; }
sub print_filename          { App::Ack::print( $_[0], $_[1] ); return; }

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


=head1 COPYRIGHT & LICENSE

Copyright 2005-2019 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

=cut

1; # End of App::Ack
