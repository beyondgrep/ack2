#!perl -T

use strict;
use warnings;

use Test::More tests => 250;
use lib 't';
use Util;

prep_environment();

## no critic ( ValuesAndExpressions::RequireInterpolationOfMetachars ) Way too many metacharacters in this file

my $file = 't/text/raven.txt';
my $word = 'nevermore';

# --line
are_mutually_exclusive('--line', '-l', ['--line=1', '-l', $file]);
are_mutually_exclusive('--line', '-l', ['--line', 1, '-l', $file]);
are_mutually_exclusive('--line', '--files-with-matches', ['--line=1', '--files-with-matches', $file]);
are_mutually_exclusive('--line', '--files-with-matches', ['--line', 1, '--files-with-matches', $file]);
are_mutually_exclusive('--line', '-L', ['--line=1', '-L', $file]);
are_mutually_exclusive('--line', '-L', ['--line', 1, '-L', $file]);
are_mutually_exclusive('--line', '--files-without-matches', ['--line=1', '--files-without-matches', $file]);
are_mutually_exclusive('--line', '--files-without-matches', ['--line', 1, '--files-without-matches', $file]);
are_mutually_exclusive('--line', '-o', ['--line=1', '-o', $file]);
are_mutually_exclusive('--line', '-o', ['--line', 1, '-o', $file]);
are_mutually_exclusive('--line', '--passthru', ['--line=1', '--passthru', $file]);
are_mutually_exclusive('--line', '--passthru', ['--line', 1, '--passthru', $file]);
are_mutually_exclusive('--line', '--match', ['--line=1', '--match', $file]);
are_mutually_exclusive('--line', '--match', ['--line', 1, '--match', $file]);
are_mutually_exclusive('--line', '-m', ['--line=1', '-m', 1, $file]);
are_mutually_exclusive('--line', '-m', ['--line', 1, '-m', 1, $file]);
are_mutually_exclusive('--line', '-m', ['--line', 1, '-m1', $file]);
are_mutually_exclusive('--line', '--max-count', ['--line=1', '--max-count', 1, $file]);
are_mutually_exclusive('--line', '--max-count', ['--line', 1, '--max-count', 1, $file]);
are_mutually_exclusive('--line', '--max-count', ['--line=1', '--max-count=1', $file]);
are_mutually_exclusive('--line', '--max-count', ['--line', 1, '--max-count=1', $file]);
are_mutually_exclusive('--line', '-1', ['--line=1', '-1', $file]);
are_mutually_exclusive('--line', '-1', ['--line', 1, '-1', $file]);
are_mutually_exclusive('--line', '-H', ['--line=1', '-H', $file]);
are_mutually_exclusive('--line', '-H', ['--line', 1, '-H', $file]);
are_mutually_exclusive('--line', '--with-filename', ['--line=1', '--with-filename', $file]);
are_mutually_exclusive('--line', '--with-filename', ['--line', 1, '--with-filename', $file]);
are_mutually_exclusive('--line', '-h', ['--line=1', '-h', $file]);
are_mutually_exclusive('--line', '-h', ['--line', 1, '-h', $file]);
are_mutually_exclusive('--line', '--no-filename', ['--line=1', '--no-filename', $file]);
are_mutually_exclusive('--line', '--no-filename', ['--line', 1, '--no-filename', $file]);
are_mutually_exclusive('--line', '-c', ['--line=1', '-c', $file]);
are_mutually_exclusive('--line', '-c', ['--line', 1, '-c', $file]);
are_mutually_exclusive('--line', '--count', ['--line=1', '--count', $file]);
are_mutually_exclusive('--line', '--count', ['--line', 1, '--count', $file]);
are_mutually_exclusive('--line', '--column', ['--line=1', '--column', $file]);
are_mutually_exclusive('--line', '--column', ['--line', 1, '--column', $file]);
are_mutually_exclusive('--line', '-A', ['--line=1', '-A', 1, $file]);
are_mutually_exclusive('--line', '-A', ['--line', 1, '-A', 1, $file]);
are_mutually_exclusive('--line', '--after-context', ['--line=1', '--after-context', 1, $file]);
are_mutually_exclusive('--line', '--after-context', ['--line', 1, '--after-context', 1, $file]);
are_mutually_exclusive('--line', '--after-context', ['--line=1', '--after-context=1', $file]);
are_mutually_exclusive('--line', '--after-context', ['--line', 1, '--after-context=1', $file]);
are_mutually_exclusive('--line', '-B', ['--line=1', '-B', 1, $file]);
are_mutually_exclusive('--line', '-B', ['--line', 1, '-B', 1, $file]);
are_mutually_exclusive('--line', '--before-context', ['--line=1', '--before-context', 1, $file]);
are_mutually_exclusive('--line', '--before-context', ['--line', 1, '--before-context', 1, $file]);
are_mutually_exclusive('--line', '--before-context', ['--line=1', '--before-context=1', $file]);
are_mutually_exclusive('--line', '--before-context', ['--line', 1, '--before-context=1', $file]);
are_mutually_exclusive('--line', '-C', ['--line=1', '-C', 1, $file]);
are_mutually_exclusive('--line', '-C', ['--line', 1, '-C', 1, $file]);
are_mutually_exclusive('--line', '--context', ['--line=1', '--context', 1, $file]);
are_mutually_exclusive('--line', '--context', ['--line', 1, '--context', 1, $file]);
are_mutually_exclusive('--line', '--context', ['--line=1', '--context=1', $file]);
are_mutually_exclusive('--line', '--context', ['--line', 1, '--context=1', $file]);
are_mutually_exclusive('--line', '--print0', ['--line=1', '--print0', $file]);
are_mutually_exclusive('--line', '--print0', ['--line', 1, '--print0', $file]);
are_mutually_exclusive('--line', '-f', ['--line=1', '-f', $file]);
are_mutually_exclusive('--line', '-f', ['--line', 1, '-f', $file]);
are_mutually_exclusive('--line', '-g', ['--line=1', '-g', $file]);
are_mutually_exclusive('--line', '-g', ['--line', 1, '-g', $file]);
are_mutually_exclusive('--line', '--show-types', ['--line=1', '--show-types', $file]);
are_mutually_exclusive('--line', '--show-types', ['--line', 1, '--show-types', $file]);

# -l/--files-with-matches
are_mutually_exclusive('-l', '-L', ['-l', '-L', $word, $file]);
are_mutually_exclusive('-l', '-o', ['-l', '-o', $word, $file]);
are_mutually_exclusive('-l', '--passthru', ['-l', '--passthru', $word, $file]);
are_mutually_exclusive('-l', '--output', ['-l', '--output', '$&', $word, $file]);
are_mutually_exclusive('-l', '--output', ['-l', '--output=$&', $word, $file]);
are_mutually_exclusive('-l', '--max-count', ['-l', '--max-count', 1, $word, $file]);
are_mutually_exclusive('-l', '--max-count', ['-l', '--max-count=1', $word, $file]);
are_mutually_exclusive('-l', '-h', ['-l', '-h', $word, $file]);
are_mutually_exclusive('-l', '--with-filename', ['-l', '--with-filename', $word, $file]);
are_mutually_exclusive('-l', '--no-filename', ['-l', '--no-filename', $word, $file]);
are_mutually_exclusive('-l', '--column', ['-l', '--column', $word, $file]);
are_mutually_exclusive('-l', '-A', ['-l', '-A', 1, $word, $file]);
are_mutually_exclusive('-l', '--after-context', ['-l', '--after-context', 1, $word, $file]);
are_mutually_exclusive('-l', '--after-context', ['-l', '--after-context=1', $word, $file]);
are_mutually_exclusive('-l', '-B', ['-l', '-B', 1, $word, $file]);
are_mutually_exclusive('-l', '--before-context', ['-l', '--before-context', 1, $word, $file]);
are_mutually_exclusive('-l', '--before-context', ['-l', '--before-context=1', $word, $file]);
are_mutually_exclusive('-l', '-C', ['-l', '-C', 1, $word, $file]);
are_mutually_exclusive('-l', '--context', ['-l', '--context', 1, $word, $file]);
are_mutually_exclusive('-l', '--context', ['-l', '--context=1', $word, $file]);
are_mutually_exclusive('-l', '--heading', ['-l', '--heading', $word, $file]);
are_mutually_exclusive('-l', '--break', ['-l', '--break', $word, $file]);
are_mutually_exclusive('-l', '--group', ['-l', '--group', $word, $file]);
are_mutually_exclusive('-l', '-f', ['-l', '-f', $file]);
are_mutually_exclusive('-l', '-g', ['-l', '-g', $word, $file]);
are_mutually_exclusive('-l', '--show-types', ['-l', '--show-types', $word, $file]);

# -L/--files-without-matches
are_mutually_exclusive('-L', '-l', ['-L', '-l', $word, $file]);
are_mutually_exclusive('-L', '-o', ['-L', '-o', $word, $file]);
are_mutually_exclusive('-L', '--passthru', ['-L', '--passthru', $word, $file]);
are_mutually_exclusive('-L', '--output', ['-L', '--output', '$&', $word, $file]);
are_mutually_exclusive('-L', '--output', ['-L', '--output=$&', $word, $file]);
are_mutually_exclusive('-L', '--max-count', ['-L', '--max-count', 1, $word, $file]);
are_mutually_exclusive('-L', '--max-count', ['-L', '--max-count=1', $word, $file]);
are_mutually_exclusive('-L', '-h', ['-L', '-h', $word, $file]);
are_mutually_exclusive('-L', '--with-filename', ['-L', '--with-filename', $word, $file]);
are_mutually_exclusive('-L', '--no-filename', ['-L', '--no-filename', $word, $file]);
are_mutually_exclusive('-L', '--column', ['-L', '--column', $word, $file]);
are_mutually_exclusive('-L', '-A', ['-L', '-A', 1, $word, $file]);
are_mutually_exclusive('-L', '--after-context', ['-L', '--after-context', 1, $word, $file]);
are_mutually_exclusive('-L', '--after-context', ['-L', '--after-context=1', $word, $file]);
are_mutually_exclusive('-L', '-B', ['-L', '-B', 1, $word, $file]);
are_mutually_exclusive('-L', '--before-context', ['-L', '--before-context', 1, $word, $file]);
are_mutually_exclusive('-L', '--before-context', ['-L', '--before-context=1', $word, $file]);
are_mutually_exclusive('-L', '-C', ['-L', '-C', 1, $word, $file]);
are_mutually_exclusive('-L', '--context', ['-L', '--context', 1, $word, $file]);
are_mutually_exclusive('-L', '--context', ['-L', '--context=1', $word, $file]);
are_mutually_exclusive('-L', '--heading', ['-L', '--heading', $word, $file]);
are_mutually_exclusive('-L', '--break', ['-L', '--break', $word, $file]);
are_mutually_exclusive('-L', '--group', ['-L', '--group', $word, $file]);
are_mutually_exclusive('-L', '-f', ['-L', '-f', $file]);
are_mutually_exclusive('-L', '-g', ['-L', '-g', $word, $file]);
are_mutually_exclusive('-L', '--show-types', ['-L', '--show-types', $word, $file]);
are_mutually_exclusive('-L', '-c', ['-L', '-c', $word, $file]);
are_mutually_exclusive('-L', '--count', ['-L', '--count', $word, $file]);

# -o
are_mutually_exclusive('-o', '--output', ['-o', '--output', '$&', $word, $file]);
are_mutually_exclusive('-o', '--output', ['-o', '--output=$&', $word, $file]);
are_mutually_exclusive('-o', '-c', ['-o', '-c', $word, $file]);
are_mutually_exclusive('-o', '--count', ['-o', '--count', $word, $file]);
are_mutually_exclusive('-o', '--column', ['-o', '--column', $word, $file]);
are_mutually_exclusive('-o', '-A', ['-o', '-A', 1, $word, $file]);
are_mutually_exclusive('-o', '--after-context', ['-o', '--after-context', 1, $word, $file]);
are_mutually_exclusive('-o', '--after-context', ['-o', '--after-context=1', $word, $file]);
are_mutually_exclusive('-o', '-B', ['-o', '-B', 1, $word, $file]);
are_mutually_exclusive('-o', '--before-context', ['-o', '--before-context', 1, $word, $file]);
are_mutually_exclusive('-o', '--before-context', ['-o', '--before-context=1', $word, $file]);
are_mutually_exclusive('-o', '-C', ['-o', '-C', 1, $word, $file]);
are_mutually_exclusive('-o', '--context', ['-o', '--context', 1, $word, $file]);
are_mutually_exclusive('-o', '--context', ['-o', '--context=1', $word, $file]);
are_mutually_exclusive('-o', '-f', ['-o', '-f', $word, $file]);

# --passthru
are_mutually_exclusive('--passthru', '--output', ['--passthru', '--output', '$&', $word, $file]);
are_mutually_exclusive('--passthru', '--output', ['--passthru', '--output=$&', $word, $file]);
are_mutually_exclusive('--passthru', '-m', ['--passthru', '-m', 1, $word, $file]);
are_mutually_exclusive('--passthru', '--max-count', ['--passthru', '--max-count', 1, $word, $file]);
are_mutually_exclusive('--passthru', '--max-count', ['--passthru', '--max-count=1', $word, $file]);
are_mutually_exclusive('--passthru', '-1', ['--passthru', '-1', $word, $file]);
are_mutually_exclusive('--passthru', '-c', ['--passthru', '-c', $word, $file]);
are_mutually_exclusive('--passthru', '--count', ['--passthru', '--count', $word, $file]);
are_mutually_exclusive('--passthru', '--count', ['--passthru', '--count', $word, $file]);
are_mutually_exclusive('--passthru', '-A', ['--passthru', '-A', 1, $word, $file]);
are_mutually_exclusive('--passthru', '--after-context', ['--passthru', '--after-context', 1, $word, $file]);
are_mutually_exclusive('--passthru', '--after-context', ['--passthru', '--after-context=1', $word, $file]);
are_mutually_exclusive('--passthru', '-B', ['--passthru', '-B', 1, $word, $file]);
are_mutually_exclusive('--passthru', '--before-context', ['--passthru', '--before-context', 1, $word, $file]);
are_mutually_exclusive('--passthru', '--before-context', ['--passthru', '--before-context=1', $word, $file]);
are_mutually_exclusive('--passthru', '-C', ['--passthru', '-C', 1, $word, $file]);
are_mutually_exclusive('--passthru', '--context', ['--passthru', '--context', 1, $word, $file]);
are_mutually_exclusive('--passthru', '--context', ['--passthru', '--context=1', $word, $file]);
are_mutually_exclusive('--passthru', '-f', ['--passthru', '-f', $word, $file]);
are_mutually_exclusive('--passthru', '-g', ['--passthru', '-g', $word, $file]);
are_mutually_exclusive('--passthru', '--column', ['--passthru', '--column', $word, $file]);

# --output
are_mutually_exclusive('--output', '-c', ['--output', '$&', '-c', $word, $file]);
are_mutually_exclusive('--output', '--count', ['--output', '$&', '--count', $word, $file]);
are_mutually_exclusive('--output', '-f', ['--output', '$&', '-f', $file]);
are_mutually_exclusive('--output', '-g', ['--output', '$&', '-g', $word, $file]);
are_mutually_exclusive('--output', '-c', ['--output=$&', '-c', $word, $file]);
are_mutually_exclusive('--output', '--count', ['--output=$&', '--count', $word, $file]);
are_mutually_exclusive('--output', '-f', ['--output=$&', '-f', $file]);
are_mutually_exclusive('--output', '-g', ['--output=$&', '-g', $word, $file]);
are_mutually_exclusive('--output', '-A', ['--output=$&', '-A2', $word, $file]);
are_mutually_exclusive('--output', '-B', ['--output=$&', '-B2', $word, $file]);
are_mutually_exclusive('--output', '-C', ['--output=$&', '-C2', $word, $file]);
are_mutually_exclusive('--output', '--after-context', ['--output=$&', '--after-context=2', $word, $file]);
are_mutually_exclusive('--output', '--before-context', ['--output=$&', '--before-context=2', $word, $file]);
are_mutually_exclusive('--output', '--context', ['--output=$&', '--context=2', $word, $file]);

# --match
are_mutually_exclusive('--match', '-f', ['--match', $word, '-f', $file]);
are_mutually_exclusive('--match', '-g', ['--match', $word, '-g', $file]);
are_mutually_exclusive('--match', '-f', ['--match=science', '-f', $file]);
are_mutually_exclusive('--match', '-g', ['--match=science', '-g', $file]);

# --max-count
are_mutually_exclusive('-m', '-1', ['-m', 1, '-1', $word, $file]);
are_mutually_exclusive('-m', '-c', ['-m', 1, '-c', $word, $file]);
are_mutually_exclusive('-m', '-f', ['-m', 1, '-f', $word, $file]);
are_mutually_exclusive('-m', '-g', ['-m', 1, '-g', $word, $file]);
are_mutually_exclusive('--max-count', '-1', ['--max-count', 1, '-1', $word, $file]);
are_mutually_exclusive('--max-count', '-c', ['--max-count', 1, '-c', $word, $file]);
are_mutually_exclusive('--max-count', '-f', ['--max-count', 1, '-f', $word, $file]);
are_mutually_exclusive('--max-count', '-g', ['--max-count', 1, '-g', $word, $file]);
are_mutually_exclusive('--max-count', '-1', ['--max-count=1', '-1', $word, $file]);
are_mutually_exclusive('--max-count', '-c', ['--max-count=1', '-c', $word, $file]);
are_mutually_exclusive('--max-count', '-f', ['--max-count=1', '-f', $word, $file]);
are_mutually_exclusive('--max-count', '-g', ['--max-count=1', '-g', $word, $file]);

# -h/--no-filename
are_mutually_exclusive('-h', '-H', ['-h', '-H', $word, $file]);
are_mutually_exclusive('-h', '--with-filename', ['-h', '--with-filename', $word, $file]);
are_mutually_exclusive('-h', '-f', ['-h', '-f', $word, $file]);
are_mutually_exclusive('-h', '-g', ['-h', '-g', $word, $file]);
are_mutually_exclusive('-h', '--group', ['-h', '--group', $word, $file]);
are_mutually_exclusive('-h', '--heading', ['-h', '--heading', $word, $file]);

are_mutually_exclusive('--no-filename', '-H', ['--no-filename', '-H', $word, $file]);
are_mutually_exclusive('--no-filename', '--with-filename', ['--no-filename', '--with-filename', $word, $file]);
are_mutually_exclusive('--no-filename', '-f', ['--no-filename', '-f', $word, $file]);
are_mutually_exclusive('--no-filename', '-g', ['--no-filename', '-g', $word, $file]);
are_mutually_exclusive('--no-filename', '--group', ['--no-filename', '--group', $word, $file]);
are_mutually_exclusive('--no-filename', '--heading', ['--no-filename', '--heading', $word, $file]);

# -H/--with-filename
are_mutually_exclusive('-H', '-h', ['-H', '-h', $word, $file]);
are_mutually_exclusive('-H', '--no-filename', ['-H', '--no-filename', $word, $file]);
are_mutually_exclusive('-H', '-f', ['-H', '-f', $word, $file]);
are_mutually_exclusive('-H', '-g', ['-H', '-g', $word, $file]);
are_mutually_exclusive('--with-filename', '-h', ['--with-filename', '-h', $word, $file]);
are_mutually_exclusive('--with-filename', '--no-filename', ['--with-filename', '--no-filename', $word, $file]);
are_mutually_exclusive('--with-filename', '-f', ['--with-filename', '-f', $word, $file]);
are_mutually_exclusive('--with-filename', '-g', ['--with-filename', '-g', $word, $file]);

# -c/--count
are_mutually_exclusive('-c', '--column', ['-c', '--column', $word, $file]);
are_mutually_exclusive('-c', '-A', ['-c', '-A', 1, $word, $file]);
are_mutually_exclusive('-c', '--after-context', ['-c', '--after-context', 1, $word, $file]);
are_mutually_exclusive('-c', '-B', ['-c', '-B', 1, $word, $file]);
are_mutually_exclusive('-c', '--before-context', ['-c', '--before-context', 1, $word, $file]);
are_mutually_exclusive('-c', '-C', ['-c', '-C', 1, $word, $file]);
are_mutually_exclusive('-c', '--context', ['-c', '--context', 1, $word, $file]);
are_mutually_exclusive('-c', '--heading', ['-c', '--heading', $word, $file]);
are_mutually_exclusive('-c', '--group', ['-c', '--group', $word, $file]);
are_mutually_exclusive('-c', '--break', ['-c', '--break', $word, $file]);
are_mutually_exclusive('-c', '-f', ['-c', '-f', $word, $file]);
are_mutually_exclusive('-c', '-g', ['-c', '-g', $word, $file]);
are_mutually_exclusive('--count', '--column', ['--count', '--column', $word, $file]);
are_mutually_exclusive('--count', '-A', ['--count', '-A', 1, $word, $file]);
are_mutually_exclusive('--count', '--after-context', ['--count', '--after-context', 1, $word, $file]);
are_mutually_exclusive('--count', '-B', ['--count', '-B', 1, $word, $file]);
are_mutually_exclusive('--count', '--before-context', ['--count', '--before-context', 1, $word, $file]);
are_mutually_exclusive('--count', '-C', ['--count', '-C', 1, $word, $file]);
are_mutually_exclusive('--count', '--context', ['--count', '--context', 1, $word, $file]);
are_mutually_exclusive('--count', '--heading', ['--count', '--heading', $word, $file]);
are_mutually_exclusive('--count', '--group', ['--count', '--group', $word, $file]);
are_mutually_exclusive('--count', '--break', ['--count', '--break', $word, $file]);
are_mutually_exclusive('--count', '-f', ['--count', '-f', $word, $file]);
are_mutually_exclusive('--count', '-g', ['--count', '-g', $word, $file]);

# --column
are_mutually_exclusive('--column', '-f', ['--column', '-f', $word, $file]);
are_mutually_exclusive('--column', '-g', ['--column', '-g', $word, $file]);

# -A/-B/-C/--after-context/--before-context/--context
are_mutually_exclusive('-A', '-f', ['-A', 1, '-f', $word, $file]);
are_mutually_exclusive('-A', '-g', ['-A', 1, '-g', $word, $file]);
are_mutually_exclusive('--after-context', '-f', ['--after-context', 1, '-f', $word, $file]);
are_mutually_exclusive('--after-context', '-g', ['--after-context', 1, '-g', $word, $file]);
are_mutually_exclusive('-B', '-f', ['-B', 1, '-f', $word, $file]);
are_mutually_exclusive('-B', '-g', ['-B', 1, '-g', $word, $file]);
are_mutually_exclusive('--before-context', '-f', ['--before-context', 1, '-f', $word, $file]);
are_mutually_exclusive('--before-context', '-g', ['--before-context', 1, '-g', $word, $file]);
are_mutually_exclusive('-C', '-f', ['-C', 1, '-f', $word, $file]);
are_mutually_exclusive('-C', '-g', ['-C', 1, '-g', $word, $file]);
are_mutually_exclusive('--context', '-f', ['--context', 1, '-f', $word, $file]);
are_mutually_exclusive('--context', '-g', ['--context', 1, '-g', $word, $file]);

# -f
are_mutually_exclusive('-f', '-g', ['-f', '-g', $word, $file]);
are_mutually_exclusive('-f', '--group', ['-f', '--group', $word, $file]);
are_mutually_exclusive('-f', '--heading', ['-f', '--heading', $word, $file]);
are_mutually_exclusive('-f', '--break', ['-f', '--break', $word, $file]);

# -g
are_mutually_exclusive('-g', '--group', ['-g', '--group', $word, $file]);
are_mutually_exclusive('-g', '--heading', ['-g', '--heading', $word, $file]);
are_mutually_exclusive('-g', '--break', ['-g', '--break', $word, $file]);

subtest q{Verify that "options" that follow -- aren't factored into the mutual exclusivity} => sub {
    my ( $stdout, $stderr ) = run_ack_with_stderr('-A', 5, $word, $file, '--', '-l');
    ok(@{$stdout} > 0, 'Some lines should appear on standard output');
    is(scalar(@{$stderr}), 1, 'A single line should be present on standard error');
    like($stderr->[0], qr/No such file or directory/, 'The error message should indicate a missing file (-l is a filename here, not an option)');
    is(get_rc(), 0, 'The ack command should not fail');
};

subtest q{Verify that mutually exclusive options in different sources don't cause a problem} => sub {
    my $ackrc = <<'END_ACKRC';
--group
END_ACKRC

    my @stdout = run_ack('--count', $file, {
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
