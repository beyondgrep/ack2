#!/usr/bin/env perl

use strict;
use warnings;
use lib 'blib/lib';
use lib 't';

use Template;
use Util;

# XXX special completion for --type-add?
# XXX don't complete mutually exclusive options?
# XXX don't complete repeat options? (bash)
# XXX don't do anything post -- (bash)
# XXX handle option arguments (zsh)

my %ZSH_DESCRIPTIONS = (
    '--ackrc'                 => 'specify an alternative ackrc',
    '--after-context'         => 'print NUM lines of trailing context after matching lines',
    '--bar'                   => 'check with the admiral for traps',
    '--before-context'        => 'print NUM lines of leading context before matching lines',
    '--break'                 => 'print a break between results for different files',
    '--cathy'                 => 'chocolate, chocolate, chocolate!' ,
    '--color'                 => 'highlight matching text',
    '--color-filename'        => 'set color for filenames',
    '--color-lineno'          => 'set color for line numbers',
    '--color-match'           => 'set color for matches',
    '--column'                => 'show column number of first match',
    '--context'               => 'print NUM lines of context around matching lines',
    '--count'                 => 'print a count of matching lines for each input file',
    '--create-ackrc'          => 'dumps default ack options to standard output',
    '--dump'                  => 'writes the list of loaded options and where they came from',
    '--files-from'            => 'specifies the list of files to search within FILE',
    '--files-with-matches'    => 'only print filenames of matching files',
    '--files-without-matches' => 'only print filenames of non-matching files',
    '--filter'                => 'force ack to behave as if it were receiving input via a pipe',
    '--flush'                 => 'flushes output immediately',
    '--follow'                => 'follow symlinks',
    '--group'                 => 'group matches by filename',
    '--heading'               => q{print a filename heading above each file's result},
    '--help'                  => 'displays help',
    '--help-types'            => 'print all known types',
    '--ignore-ack-defaults'   => 'ignore default definitions provided with ack',
    '--ignore-case'           => 'ignore case in matches',
    '--ignore-directory'      => 'ignore directories (at any level) named DIRNAME',
    '--ignore-file'           => 'ignore files matching FILTERTYPE:FILTERARGS',
    '--invert-match'          => 'select non-matching lines',
    '--lines'                 => 'print only line NUM of each file',
    '--literal'               => 'quote all metacharacters in PATTERN',
    '--man'                   => 'displays the ack man page',
    '--match'                 => 'specify PATTERN explicitly',
    '--max-count'             => 'stop reading after NUM matches',
    '--no-filename'           => q{don't print filenames on output},
    '--noenv'                 => q{don't consider ackrc files/environment variables for configuration},
    '--output'                => 'output the evaluation of EXPR for each line',
    '--pager'                 => q{direct ack's output through PAGER},
    '--passthru'              => 'print all lines, whether or not they match the expression, highlighting matches',
    '--print0'                => 'separate output lines with NUL characters',
    '--recurse'               => 'recurse into subdirectories',
    '--show-types'            => 'outputs the filetypes that ack associates with each file',
    '--smart-case'            => 'ignores case in search strings if PATTERN contains no uppercase characters',
    '--sort-files'            => 'sorts found files lexicographically',
    '--thpppt'                => 'display the Bill The Cat logo.',
    '--type-add'              => 'add a type definition',
    '--type-del'              => 'removes a type definition',
    '--type-set'              => 'add a type definition',
    '--version'               => 'displays version and copyright information',
    '--with-filename'         => 'print the filename for each match',
    '--word-regexp'           => 'force PATTERN to match only whole words',
    '-1'                      => 'stops after reporting first match',
    '-f'                      => 'only print files that would be searched',
    '-g'                      => 'only print files whose names match PATTERN',
    '-o'                      => 'only print the part of each matching line that matches PATTERN',
    '-s'                      => 'suppress error messages about nonexistent or unreadable files',
    '-x'                      => 'search files specified on standard input',
);

my %OPTION_ALIASES = (
    '--after-context'         => ['-A'],
    '--before-context'        => ['-B'],
    '--context'               => ['-C'],
    '--count'                 => ['-c'],
    '--no-filename'           => ['-h'],
    '--with-filename'         => ['-H'],
    '--files-with-matches'    => ['-l'],
    '--files-without-matches' => ['-L'],
    '--max-count'             => ['-m'],
    '--no-recurse'            => ['-n'],
    '--help'                  => ['-?'],
    '--ignore-case'           => ['-i'],
    '--literal'               => ['-Q'],
    '--recurse'               => ['-r', '-R'],
    '--invert-match'          => ['-v'],
    '--word-regexp'           => ['-w'],
    '--color'                 => ['--colour'],
    '--ignore-directory'      => ['--ignore-dir'],
);

my %IS_AN_ALIAS = map { $_ => 1 } map { @$_ } values %OPTION_ALIASES;

my $BASH_TEMPLATE = <<'END_TEMPLATE';
declare -g -a _ack_options
declare -g -a _ack_types=()

_ack_options=(
[% FOREACH option IN options -%]
  "[% option -%]" \
[% END -%]
)

function __setup_ack() {
    local type

    while read LINE; do
        case $LINE in
            --*)
                type="${LINE%% *}"
                type=${type/--\[no\]/}
                _ack_options[ ${#_ack_options[@]} ]="--$type"
                _ack_options[ ${#_ack_options[@]} ]="--no$type"
                _ack_types[ ${#_ack_types[@]} ]="$type"
            ;;
        esac
    done < <(ack --help-types)
}
__setup_ack
unset -f __setup_ack

function _ack_complete() {
    local current_word
    local pattern

    current_word=${COMP_WORDS[$COMP_CWORD]}

    if [[ "$current_word" == -* ]]; then
        pattern="${current_word}*"
        for option in ${_ack_options[@]}; do
            if [[ "$option" == $pattern ]]; then
                COMPREPLY[ ${#COMPREPLY[@]} ]=$option
            fi
        done
    else
        local previous_word
        previous_word=${COMP_WORDS[$(( $COMP_CWORD - 1 ))]}
        if [[ "$previous_word" == "=" ]]; then
            previous_word=${COMP_WORDS[$(( $COMP_CWORD - 2 ))]}
        fi

        if [ "$previous_word" == '--type' -o "$previous_word" == '--notype' ]; then
            pattern="${current_word}*"
            for type in ${_ack_types[@]}; do
                if [[ "$type" == $pattern ]]; then
                    COMPREPLY[ ${#COMPREPLY[@]} ]=$type
                fi
            done
        fi
    fi
}

complete -o default -F _ack_complete ack ack2 ack-grep
END_TEMPLATE

my $ZSH_TEMPLATE = <<'END_TEMPLATE';
#compdef ack ack2 ack-grep

declare -a ack_types
declare -a arguments
local type

arguments=( \
[% FOREACH option IN options -%]
    [% IF option != '--type' && option != '--notype' && !is_alias.exists(option) -%]
        [% FILTER collapse -%]
            [%- IF aliases.exists(option) -%]
{[% option -%],[% aliases.$option.join(',') -%]}
            [%- ELSE -%]
"[% option -%]"
            [%- END -%]
            [%- IF descriptions.exists(option) -%]
"[[% descriptions.$option -%]]"
            [%- END -%]
        [% END -%]
        \
    [% END -%]
[% END -%]
)

while read LINE; do
    case $LINE in
        --*)
            type="${LINE%% *}"
            type=${type/--\[no\]/}
            arguments[$(( ${#arguments[@]} + 1 ))]="--${type}[restrict to files of type $type]"
            arguments[$(( ${#arguments[@]} + 1 ))]="--no${type}[restrict to files other than type $type]"
            ack_types[$(( ${#ack_types[@]} + 1 ))]="$type"
        ;;
    esac
done < <(ack --help-types)

arguments[$(( ${#arguments[@]} + 1 ))]="--type=[restrict to files of given type]:filetype:(${ack_types[@]})"
arguments[$(( ${#arguments[@]} + 1 ))]="--notype=[restrict to files other than given type]:notfiletype:(${ack_types[@]})"
arguments[$(( ${#arguments[@]} + 1 ))]="*:files:_files"

_arguments -S $arguments
END_TEMPLATE

my $tt = Template->new({});

# XXX do a sanity check on ZSH_DESCRIPTIONS vs get_options, OPTION_ALIASES

my $vars = {
    options      => [ get_options() ],
    descriptions => \%ZSH_DESCRIPTIONS,
    aliases      => \%OPTION_ALIASES,
    is_alias     => \%IS_AN_ALIAS,
};

my ( $filename ) = @ARGV;

if ( !$filename ) {
    die "usage: $0 (completion.bash|completion.zsh)\n";
}
elsif ( $filename eq 'completion.bash' ) {
    $tt->process(\$BASH_TEMPLATE, $vars, 'completion.bash') || die $tt->error;
}
elsif ( $filename eq 'completion.zsh' ) {
    $tt->process(\$ZSH_TEMPLATE, $vars, 'completion.zsh')   || die $tt->error;
}
else {
    die "I don't know how to generate $filename\n";
}
