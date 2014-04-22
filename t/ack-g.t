#!perl -T

use warnings;
use strict;

use Test::More tests => 18;

use lib 't';
use Util;

prep_environment();

subtest 'No starting directory specified' => sub {
    my $regex = 'non';

    my @files = qw( t/foo/non-existent );
    my @args = ( '-g', $regex );
    my ($stdout, $stderr) = run_ack_with_stderr( @args, @files );

    is_empty_array( $stdout, 'No STDOUT for non-existent file' );
    is( scalar @{$stderr}, 1, 'One line of STDERR for non-existent file' );
    like( $stderr->[0], qr/non-existent: No such file or directory/,
        'Correct warning message for non-existent file' );
};

subtest 'regex comes before -g on the command line' => sub {
    my $regex = 'non';

    my @files = qw( t/foo/non-existent );
    my @args = ( $regex, '-g' );
    my ($stdout, $stderr) = run_ack_with_stderr( @args, @files );

    is_empty_array( $stdout, 'No STDOUT for non-existent file' );
    is( scalar @{$stderr}, 1, 'One line of STDERR for non-existent file' );
    like( $stderr->[0], qr/non-existent: No such file or directory/,
        'Correct warning message for non-existent file' );
};

subtest 'No metacharacters' => sub {
    my @expected = qw(
        t/swamp/Makefile
        t/swamp/Makefile.PL
        t/swamp/notaMakefile
    );
    my $regex = 'Makefile';

    my @args  = ( '-g', $regex );
    my @files = qw( t/ );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for $regex" );
};


subtest 'With metacharacters' => sub {
    my @expected = qw(
        t/swamp/html.htm
        t/swamp/html.html
    );
    my $regex = 'swam.......htm';

    my @args  = ( '-g', $regex );
    my @files = qw( t/ );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for $regex" );
};

subtest 'Front anchor' => sub {
    my @expected = qw(
        t/file-permission.t
        t/filetypes.t
        t/filter.t
    );
    my $regex = '^t.fil';

    my @args  = ( '-g', $regex );
    my @files = qw( t );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for $regex" );
};

subtest 'Back anchor' => sub {
    my @expected = qw(
        t/runtests.pl
        t/swamp/options-crlf.pl
        t/swamp/options.pl
        t/swamp/perl.pl
    );
    my $regex = 'pl$';

    my @args  = ( '-g', $regex );
    my @files = qw( t );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for $regex" );
};

subtest 'Case-insensitive via -i' => sub {
    my @expected = qw(
        t/swamp/pipe-stress-freaks.F
    );
    my $regex = 'PIPE';

    my @args  = ( '-i', '-g', $regex );
    my @files = qw( t/swamp );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for -i -g $regex " );
};

subtest 'Case-insensitive via (?i:)' => sub {
    my @expected = qw(
        t/swamp/pipe-stress-freaks.F
    );
    my $regex = '(?i:PIPE)';

    my @files = qw( t/swamp );
    my @args  = ( '-g', $regex );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for $regex" );
};

subtest 'File on command line is always searched' => sub {
    my @expected = ( 't/swamp/#emacs-workfile.pl#' );
    my $regex = 'emacs';

    my @args = ( '-g', $regex );
    my @files = ( 't/swamp/#emacs-workfile.pl#' );

    ack_sets_match( [ @args, @files ], \@expected, 'File on command line is always searched' );
};

subtest 'File on command line is always searched, even with wrong filetype' => sub {
    my @expected = qw(
        t/swamp/parrot.pir
    );
    my $regex = 'parrot';

    my @files = qw( t/swamp/parrot.pir );
    my @args  = ( '--html', '-g', $regex );

    ack_sets_match( [ @args, @files ], \@expected, 'File on command line is always searched, even with wrong type.' );
};

subtest '-Q works on -g' => sub {
    my @expected = qw(
    );
    my $regex = 'ack-g.t$';

    my @files = qw( t );
    my @args  = ( '-Q', '-g', $regex );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for $regex with quotemeta." );

    @expected = (
        't/text/4th-of-july.txt',
        't/text/freedom-of-choice.txt',
        't/text/science-of-myth.txt',
    );
    $regex = 'of';

    @files = qw( t/text );
    @args  = ( '-Q', '-g', $regex );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for $regex with quotemeta." );
};

subtest '-w works on -g' => sub {
    my @expected = qw();
    my $regex = 'free';

    my @args  = ( '-w', '-g', $regex ); # The -w means "free" won't match "freedom"
    my @files = qw( t/text/ );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for $regex with '-w'." );

    @expected = (
        't/text/4th-of-july.txt',
        't/text/freedom-of-choice.txt',
        't/text/science-of-myth.txt',
    );
    $regex = 'of';

    @files = qw( t/text );
    @args  = ( '-w', '-g', $regex );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for $regex with '-w'." );
};

subtest '-v works on -g' => sub {
    my @expected = qw(
        t/text/boy-named-sue.txt
        t/text/me-and-bobbie-mcgee.txt
        t/text/number.txt
        t/text/numbered-text.txt
        t/text/shut-up-be-happy.txt
    );
    my $file_regex = 'of';

    my @args  = ( '-v', '-g', $file_regex );
    my @files = qw( t/text/ );

    ack_sets_match( [ @args, @files ], \@expected, "Looking for file names that do not match $file_regex" );
};

subtest '--smart-case works on -g' => sub {
    my @expected = qw(
        t/swamp/pipe-stress-freaks.F
        t/swamp/crystallography-weenies.f
    );

    my @files = qw( t/swamp );
    my @args  = ( '--smart-case', '-g', 'f$' );

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for f$' );

    @expected = qw(
        t/swamp/pipe-stress-freaks.F
    );
    @args = ( '--smart-case', '-g', 'F$' );

    ack_sets_match( [ @args, @files ], \@expected, 'Looking for f$' );
};

subtest 'test exit codes' => sub {
    my $file_regex = 'foo';
    my @files      = ( 't/text/' );

    run_ack( '-g', $file_regex, @files );
    is( get_rc(), 1, '-g with no matches must exit with 1' );

    $file_regex = 'boy';

    run_ack( '-g', $file_regex, @files );
    is( get_rc(), 0, '-g with matches must exit with 0' );
};

subtest 'test -g on a path' => sub {
    my $file_regex = 'text';
    my @expected   = (
        't/context.t',
        't/text/4th-of-july.txt',
        't/text/boy-named-sue.txt',
        't/text/freedom-of-choice.txt',
        't/text/me-and-bobbie-mcgee.txt',
        't/text/number.txt',
        't/text/numbered-text.txt',
        't/text/science-of-myth.txt',
        't/text/shut-up-be-happy.txt',
    );
    my @args = ( '--sort-files', '-g', $file_regex );

    ack_sets_match( [ @args ], \@expected, 'Make sure -g matches the whole path' );
};

subtest 'test -g with --color' => sub {
    my $file_regex = 'text';
    my $expected_original = <<'END_COLOR';
t/con(text).t
t/(text)/4th-of-july.txt
t/(text)/boy-named-sue.txt
t/(text)/freedom-of-choice.txt
t/(text)/me-and-bobbie-mcgee.txt
t/(text)/number.txt
t/(text)/numbered-(text).txt
t/(text)/science-of-myth.txt
t/(text)/shut-up-be-happy.txt
END_COLOR

    $expected_original = windows_slashify( $expected_original ) if is_windows;

    my @expected   = colorize( $expected_original );

    my @args = ( '--sort-files', '-g', $file_regex );

    my @results = run_ack(@args, '--color');

    is_deeply( \@results, \@expected, 'Colorizing -g output with --color should work');
};

subtest q{test -g without --color; make sure colors don't show} => sub {
    if ( !has_io_pty() ) {
        plan skip_all => 'IO::Pty is required for this test';
        return;
    }

    my $file_regex = 'text';
    my $expected   = <<'END_OUTPUT';
t/context.t
t/text/4th-of-july.txt
t/text/boy-named-sue.txt
t/text/freedom-of-choice.txt
t/text/me-and-bobbie-mcgee.txt
t/text/number.txt
t/text/numbered-text.txt
t/text/science-of-myth.txt
t/text/shut-up-be-happy.txt
END_OUTPUT

    my @args = ( '--sort-files', '-g', $file_regex );

    my $results = run_ack_interactive(@args);

    is( $results, $expected, 'Colorizing -g output without --color should have no color' );
};

done_testing();
