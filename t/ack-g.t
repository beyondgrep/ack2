#!perl

use warnings;
use strict;

use Test::More tests => 13;

use lib 't';
use Util;

prep_environment();

subtest 'No starting directory specified' => sub {
    my $regex = 'non';

    my @files = qw( t/foo/non-existent );
    my @args = ( '-g', $regex );
    my ($stdout, $stderr) = run_ack_with_stderr( @args, @files );

    is( scalar @{$stdout}, 0, 'No STDOUT for non-existent file' );
    is( scalar @{$stderr}, 1, 'One line of STDERR for non-existent file' );
    like( $stderr->[0], qr/non-existent: No such file or directory/,
        'Correct warning message for non-existent file' );
};

subtest 'regex comes before -g on the command line' => sub {
    my $regex = 'non';

    my @files = qw( t/foo/non-existent );
    my @args = ( $regex, '-g' );
    my ($stdout, $stderr) = run_ack_with_stderr( @args, @files );

    is( scalar @{$stdout}, 0, 'No STDOUT for non-existent file' );
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

    my @files = qw( t/ );
    my @args = ( '-g', $regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, "Looking for $regex" );
};


subtest 'With metacharacters' => sub {
    my @expected = qw(
        t/swamp/html.htm
        t/swamp/html.html
    );
    my $regex = 'swam.......htm';

    my @files = qw( t/ );
    my @args = ( '-g', $regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, "Looking for $regex" );
};

subtest 'Front anchor' => sub {
    my @expected = qw(
        t/filter.t
    );
    my $regex = '^t.fil';

    my @files = qw( t );
    my @args = ( '-g', $regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, "Looking for $regex" );
};

subtest 'Back anchor' => sub {
    my @expected = qw(
        t/swamp/options.pl
        t/swamp/perl.pl
    );
    my $regex = 'pl$';

    my @files = qw( t );
    my @args = ( '-g', $regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, "Looking for $regex" );
};

subtest 'Case-insensitive via -i' => sub {
    my @expected = qw(
        t/swamp/pipe-stress-freaks.F
    );
    my $regex = 'PIPE';

    my @files = qw( . );
    my @args = ( '-i', '-g', $regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, "Looking for -i -g $regex " );
};

subtest 'Case-insensitive via (?i:)' => sub {
    my @expected = qw(
        t/swamp/pipe-stress-freaks.F
    );
    my $regex = '(?i:PIPE)';

    my @files = qw( . );
    my @args = ( '-g', $regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, "Looking for $regex" );
};

subtest 'File on command line is always searched' => sub {
    my @expected = ( 't/swamp/#emacs-workfile.pl#' );
    my $regex = 'emacs';

    my @files = ( 't/swamp/#emacs-workfile.pl#' );
    my @args = ( '-g', $regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, 'File on command line is always searched' );
};

subtest 'File on command line is always searched, even with wrong filetype' => sub {
    my @expected = qw(
        t/swamp/parrot.pir
    );
    my $regex = 'parrot';

    my @files = qw( t/swamp/parrot.pir );
    my @args = ( '--html', '-g', $regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, 'File on command line is always searched, even with wrong type.' );
};

subtest '-Q works on -g' => sub {
    my @expected = qw(
    );
    my $regex = 'ack-g.t$';

    my @files = qw( t );
    my @args = ( '-Q', '-g', $regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, "Looking for $regex with quotemeta." );
};

subtest '-w works on -g' => sub {
    my @expected = qw();
    my $regex = 'free';

    my @files = qw( t/text/ );
    my @args = ( '-w', '-g', $regex ); # The -w means "free" won't match "freedom"
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, "Looking for $regex with '-w'." );
};

subtest '-v works on -g' => sub {
    my @expected = qw(
        t/text/boy-named-sue.txt
        t/text/me-and-bobbie-mcgee.txt
        t/text/shut-up-be-happy.txt
    );
    my $file_regex = 'of';

    my @files = qw( t/text/ );
    my @args = ( '-v', '-g', $file_regex );
    my @results = run_ack( @args, @files );

    sets_match( \@results, \@expected, "Looking for file names that do not match $file_regex" );
};
