#!perl -T

use strict;
use warnings;

use Test::More tests => 250;
use lib 't';
use Util;

prep_environment();

## no critic ( ValuesAndExpressions::RequireInterpolationOfMetachars ) Way too many metacharacters in this file

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
are_mutually_exclusive('--line', '-m', ['--line', 1, '-m1', 't/text/science-of-myth.txt']);
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
are_mutually_exclusive('--output', '-A', ['--output=$&', '-A2', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '-B', ['--output=$&', '-B2', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '-C', ['--output=$&', '-C2', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '--after-context', ['--output=$&', '--after-context=2', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '--before-context', ['--output=$&', '--before-context=2', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--output', '--context', ['--output=$&', '--context=2', 'science', 't/text/science-of-myth.txt']);

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
are_mutually_exclusive('-h', '-f', ['-h', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-h', '-g', ['-h', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-h', '--group', ['-h', '--group', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-h', '--heading', ['-h', '--heading', 'science', 't/text/science-of-myth.txt']);

are_mutually_exclusive('--no-filename', '-H', ['--no-filename', '-H', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '--with-filename', ['--no-filename', '--with-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '-f', ['--no-filename', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '-g', ['--no-filename', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '--group', ['--no-filename', '--group', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--no-filename', '--heading', ['--no-filename', '--heading', 'science', 't/text/science-of-myth.txt']);

# -H/--with-filename
are_mutually_exclusive('-H', '-h', ['-H', '-h', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-H', '--no-filename', ['-H', '--no-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-H', '-f', ['-H', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-H', '-g', ['-H', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--with-filename', '-h', ['--with-filename', '-h', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--with-filename', '--no-filename', ['--with-filename', '--no-filename', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--with-filename', '-f', ['--with-filename', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--with-filename', '-g', ['--with-filename', '-g', 'science', 't/text/science-of-myth.txt']);

# -c/--count
are_mutually_exclusive('-c', '--column', ['-c', '--column', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '-A', ['-c', '-A', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '--after-context', ['-c', '--after-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '-B', ['-c', '-B', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '--before-context', ['-c', '--before-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '-C', ['-c', '-C', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '--context', ['-c', '--context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '--heading', ['-c', '--heading', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '--group', ['-c', '--group', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '--break', ['-c', '--break', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '-f', ['-c', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-c', '-g', ['-c', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '--column', ['--count', '--column', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '-A', ['--count', '-A', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '--after-context', ['--count', '--after-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '-B', ['--count', '-B', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '--before-context', ['--count', '--before-context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '-C', ['--count', '-C', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '--context', ['--count', '--context', 1, 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '--heading', ['--count', '--heading', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '--group', ['--count', '--group', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '--break', ['--count', '--break', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '-f', ['--count', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--count', '-g', ['--count', '-g', 'science', 't/text/science-of-myth.txt']);

# --column
are_mutually_exclusive('--column', '-f', ['--column', '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--column', '-g', ['--column', '-g', 'science', 't/text/science-of-myth.txt']);

# -A/-B/-C/--after-context/--before-context/--context
are_mutually_exclusive('-A', '-f', ['-A', 1, '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-A', '-g', ['-A', 1, '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--after-context', '-f', ['--after-context', 1, '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--after-context', '-g', ['--after-context', 1, '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-B', '-f', ['-B', 1, '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-B', '-g', ['-B', 1, '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--before-context', '-f', ['--before-context', 1, '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--before-context', '-g', ['--before-context', 1, '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-C', '-f', ['-C', 1, '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-C', '-g', ['-C', 1, '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--context', '-f', ['--context', 1, '-f', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('--context', '-g', ['--context', 1, '-g', 'science', 't/text/science-of-myth.txt']);

# -f
are_mutually_exclusive('-f', '-g', ['-f', '-g', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-f', '--group', ['-f', '--group', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-f', '--heading', ['-f', '--heading', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-f', '--break', ['-f', '--break', 'science', 't/text/science-of-myth.txt']);

# -g
are_mutually_exclusive('-g', '--group', ['-g', '--group', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-g', '--heading', ['-g', '--heading', 'science', 't/text/science-of-myth.txt']);
are_mutually_exclusive('-g', '--break', ['-g', '--break', 'science', 't/text/science-of-myth.txt']);

subtest q{Verify that "options" that follow -- aren't factored into the mutual exclusivity} => sub {
    my ( $stdout, $stderr ) = run_ack_with_stderr('-A', 5, 'science', 't/text/science-of-myth.txt', '--', '-l');
    ok(@{$stdout} > 0, 'Some lines should appear on standard output');
    is(scalar(@{$stderr}), 1, 'A single line should be present on standard error');
    like($stderr->[0], qr/No such file or directory/, 'The error message should indicate a missing file (-l)');
    is(get_rc(), 0, 'The ack command should not fail');
};

subtest q{Verify that mutually exclusive options in different sources don't cause a problem} => sub {
    my $ackrc = <<'END_ACKRC';
--group
END_ACKRC

    my @stdout = run_ack('--count', 't/text/science-of-myth.txt', {
        ackrc => \$ackrc,
    });
    ok(@stdout > 0, 'Some lines should appear on standard output');
};

done_testing();

# Do this without system().
sub are_mutually_exclusive {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ( $opt1, $opt2, $args ) = @_;

    my @args = @{$args};

    my ( $stdout, $stderr ) = run_ack_with_stderr(@args);

    return subtest "are_mutually_exclusive( $opt1, $opt2, @args )" => sub {
        plan tests => 4;

        isnt( get_rc(), 0, 'The ack command should fail' );
        is_empty_array( $stdout, 'No lines should be present on standard output' );
        is( scalar(@{$stderr}), 1, 'A single line should be present on standard error' );

        my $opt1_re = quotemeta($opt1);
        my $opt2_re = quotemeta($opt2);

        my $error = $stderr->[0] || ''; # avoid undef warnings
        if ( $error =~ /Options '$opt1_re' and '$opt2_re' are mutually exclusive/ ||
            $error =~ /Options '$opt2_re' and '$opt1_re' are mutually exclusive/ ) {

            pass( qq{Error message resembles "Options '$opt1' and '$opt2' are mutually exclusive"} );
        }
        else {
            fail( qq{Error message does not resemble "Options '$opt1' and '$opt2' are mutually exclusive"} );
            diag("Error message: '$error'");
        }
    };
}
