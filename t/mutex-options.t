#!perl

use strict;
use warnings;

use Test::More;
use lib 't';
use Util;

# do this without system()
sub are_mutually_exclusive {
    my ( $opt1, $opt2, $args ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ( $stdout, $stderr ) = run_ack_with_stderr(@$args);

    isnt get_rc(), 0, 'The ack command should fail';
    is scalar(@$stdout), 0, 'No lines should be present on standard output';
    is scalar(@$stderr), 1, 'A single line should be present on standard error';

    my $opt1_re = quotemeta($opt1);
    my $opt2_re = quotemeta($opt2);

    my $error = $stderr->[0] || ''; # avoid undef warnings
    if($error =~ /Options '$opt1_re' and '$opt2_re' are mutually exclusive/ ||
       $error =~ /Options '$opt2_re' and '$opt1_re' are mutually exclusive/) {

        pass qq{Error message resembles "Options '$opt1' and '$opt2' are mutually exclusive"};
    } else {
        fail qq{Error message does not resemble "Options '$opt1' and '$opt2' are mutually exclusive"};
        diag("Error message: '$error'");
    }
}

prep_environment();

# --line
are_mutually_exclusive('--line', '-l', ['--line=1', '-l', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-l', ['--line', 1, '-l', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--files-with-matches', ['--line=1', '--files-with-matches', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--files-with-matches', ['--line', 1, '--files-with-matches', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-L', ['--line=1', '-L', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-L', ['--line', 1, '-L', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--files-without-matches', ['--line=1', '--files-without-matches', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--files-without-matches', ['--line', 1, '--files-without-matches', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-o', ['--line=1', '-o', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-o', ['--line', 1, '-o', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--passthru', ['--line=1', '--passthru', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--passthru', ['--line', 1, '--passthru', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--match', ['--line=1', '--match', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--match', ['--line', 1, '--match', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-m', ['--line=1', '-m', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-m', ['--line', 1, '-m', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--max-count', ['--line=1', '--max-count', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--max-count', ['--line', 1, '--max-count', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--max-count', ['--line=1', '--max-count=1', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--max-count', ['--line', 1, '--max-count=1', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-1', ['--line=1', '-1', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-1', ['--line', 1, '-1', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-H', ['--line=1', '-H', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-H', ['--line', 1, '-H', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--with-filename', ['--line=1', '--with-filename', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--with-filename', ['--line', 1, '--with-filename', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-h', ['--line=1', '-h', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-h', ['--line', 1, '-h', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--no-filename', ['--line=1', '--no-filename', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--no-filename', ['--line', 1, '--no-filename', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-c', ['--line=1', '-c', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-c', ['--line', 1, '-c', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--count', ['--line=1', '--count', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--count', ['--line', 1, '--count', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--column', ['--line=1', '--column', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--column', ['--line', 1, '--column', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-A', ['--line=1', '-A', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-A', ['--line', 1, '-A', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--after-context', ['--line=1', '--after-context', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--after-context', ['--line', 1, '--after-context', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--after-context', ['--line=1', '--after-context=1', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--after-context', ['--line', 1, '--after-context=1', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-B', ['--line=1', '-B', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-B', ['--line', 1, '-B', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--before-context', ['--line=1', '--before-context', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--before-context', ['--line', 1, '--before-context', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--before-context', ['--line=1', '--before-context=1', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--before-context', ['--line', 1, '--before-context=1', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-C', ['--line=1', '-C', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-C', ['--line', 1, '-C', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--context', ['--line=1', '--context', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--context', ['--line', 1, '--context', 1, 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--context', ['--line=1', '--context=1', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--context', ['--line', 1, '--context=1', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--print0', ['--line=1', '--print0', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--print0', ['--line', 1, '--print0', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-f', ['--line=1', '-f', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-f', ['--line', 1, '-f', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-g', ['--line=1', '-g', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '-g', ['--line', 1, '-g', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--show-types', ['--line=1', '--show-types', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--line', '--show-types', ['--line', 1, '--show-types', 't/text/science-of-myth.txt']);

# -l/--files-with-matches
are_mutually_exclusive('-l', '-L', ['-l', '-L', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '-o', ['-l', '-o', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--passthru', ['-l', '--passthru', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--output', ['-l', '--output', '$&', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--output', ['-l', '--output=$&', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--max-count', ['-l', '--max-count', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--max-count', ['-l', '--max-count=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '-h', ['-l', '-h', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--with-filename', ['-l', '--with-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--no-filename', ['-l', '--no-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--column', ['-l', '--column', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '-A', ['-l', '-A', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--after-context', ['-l', '--after-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--after-context', ['-l', '--after-context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '-B', ['-l', '-B', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--before-context', ['-l', '--before-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--before-context', ['-l', '--before-context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '-C', ['-l', '-C', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--context', ['-l', '--context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--context', ['-l', '--context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--heading', ['-l', '--heading', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--break', ['-l', '--break', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--group', ['-l', '--group', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '-f', ['-l', '-f', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '-g', ['-l', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-l', '--show-types', ['-l', '--show-types', 'science', 't/text/science-of-myth.txt']);

# -L/--files-without-matches
are_mutually_exclusive('-L', '-l', ['-L', '-l', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '-o', ['-L', '-o', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--passthru', ['-L', '--passthru', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--output', ['-L', '--output', '$&', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--output', ['-L', '--output=$&', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--max-count', ['-L', '--max-count', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--max-count', ['-L', '--max-count=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '-h', ['-L', '-h', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--with-filename', ['-L', '--with-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--no-filename', ['-L', '--no-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--column', ['-L', '--column', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '-A', ['-L', '-A', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--after-context', ['-L', '--after-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--after-context', ['-L', '--after-context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '-B', ['-L', '-B', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--before-context', ['-L', '--before-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--before-context', ['-L', '--before-context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '-C', ['-L', '-C', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--context', ['-L', '--context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--context', ['-L', '--context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--heading', ['-L', '--heading', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--break', ['-L', '--break', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--group', ['-L', '--group', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '-f', ['-L', '-f', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '-g', ['-L', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--show-types', ['-L', '--show-types', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '-c', ['-L', '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-L', '--count', ['-L', '--count', 'science', 't/text/science-of-myth.txt']);

# -o
are_mutually_exclusive('-o', '--output', ['-o', '--output', '$&', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '--output', ['-o', '--output=$&', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '-c', ['-o', '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '--count', ['-o', '--count', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '--column', ['-o', '--column', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '-A', ['-o', '-A', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '--after-context', ['-o', '--after-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '--after-context', ['-o', '--after-context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '-B', ['-o', '-B', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '--before-context', ['-o', '--before-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '--before-context', ['-o', '--before-context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '-C', ['-o', '-C', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '--context', ['-o', '--context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '--context', ['-o', '--context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-o', '-f', ['-o', '-f', 'science', 't/text/science-of-myth.txt']);

# --passthru
are_mutually_exclusive('--passthru', '--output', ['--passthru', '--output', '$&', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--output', ['--passthru', '--output=$&', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '-m', ['--passthru', '-m', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--max-count', ['--passthru', '--max-count', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--max-count', ['--passthru', '--max-count=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '-1', ['--passthru', '-1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '-c', ['--passthru', '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--count', ['--passthru', '--count', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--count', ['--passthru', '--count', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '-A', ['--passthru', '-A', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--after-context', ['--passthru', '--after-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--after-context', ['--passthru', '--after-context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '-B', ['--passthru', '-B', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--before-context', ['--passthru', '--before-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--before-context', ['--passthru', '--before-context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '-C', ['--passthru', '-C', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--context', ['--passthru', '--context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--context', ['--passthru', '--context=1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '-f', ['--passthru', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '-g', ['--passthru', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--passthru', '--column', ['--passthru', '--column', 'science', 't/text/science-of-myth.txt']);

# --output
are_mutually_exclusive('--output', '-c', ['--output', '$&', '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '--count', ['--output', '$&', '--count', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '-f', ['--output', '$&', '-f', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '-g', ['--output', '$&', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '-c', ['--output=$&', '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '--count', ['--output=$&', '--count', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '-f', ['--output=$&', '-f', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '-g', ['--output=$&', '-g', 'science', 't/text/science-of-myth.txt']);

# --match
are_mutually_exclusive('--match', '-f', ['--match', 'science', '-f', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--match', '-g', ['--match', 'science', '-g', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--match', '-f', ['--match=science', '-f', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--match', '-g', ['--match=science', '-g', 't/text/science-of-myth.txt']);

# --max-count
are_mutually_exclusive('-m', '-1', ['-m', 1, '-1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-m', '-c', ['-m', 1, '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-m', '-f', ['-m', 1, '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-m', '-g', ['-m', 1, '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--max-count', '-1', ['--max-count', 1, '-1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--max-count', '-c', ['--max-count', 1, '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--max-count', '-f', ['--max-count', 1, '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--max-count', '-g', ['--max-count', 1, '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--max-count', '-1', ['--max-count=1', '-1', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--max-count', '-c', ['--max-count=1', '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--max-count', '-f', ['--max-count=1', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--max-count', '-g', ['--max-count=1', '-g', 'science', 't/text/science-of-myth.txt']);

# -h/--no-filename
are_mutually_exclusive('-h', '-H', ['-h', '-H', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-h', '--with-filename', ['-h', '--with-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-h', '-c', ['-h', '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-h', '--count', ['-h', '--count', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-h', '-f', ['-h', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-h', '-g', ['-h', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '-H', ['--no-filename', '-H', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '--with-filename', ['--no-filename', '--with-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '-c', ['--no-filename', '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '--count', ['--no-filename', '--count', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '-f', ['--no-filename', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '-g', ['--no-filename', '-g', 'science', 't/text/science-of-myth.txt']);

# -H/--with-filename
are_mutually_exclusive('-H', '-h', ['-H', '-h', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-H', '--no-filename', ['-H', '--no-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-H', '-c', ['-H', '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-H', '--count', ['-H', '--count', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-H', '-f', ['-H', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-H', '-g', ['-H', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--with-filename', '-h', ['--with-filename', '-h', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--with-filename', '--no-filename', ['--with-filename', '--no-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--with-filename', '-c', ['--with-filename', '-c', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--with-filename', '--count', ['--with-filename', '--count', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--with-filename', '-f', ['--with-filename', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--with-filename', '-g', ['--with-filename', '-g', 'science', 't/text/science-of-myth.txt']);

done_testing();

# XXX test --count after --
