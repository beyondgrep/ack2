#!perl -T

use warnings;
use strict;

use Test::More tests => 6;

use lib 't';
use Util;
use Term::ANSIColor;

prep_environment();


my @HIGHLIGHT = qw( --color --group --sort-files );

BASIC: {
    my @args  = qw( beliefs t/text/ );

    my $expected_original = <<'END';
<t/text/science-of-myth.txt>
{1}:If you've ever questioned (beliefs) that you've hold, you're not alone
{19}:When she was raped and cut up, left for dead in her trunk, her (beliefs) held true
END

    $expected_original = windows_slashify( $expected_original ) if is_windows;

    my @expected = colorize( $expected_original );

    my @results = run_ack( @args, @HIGHLIGHT );

    is_deeply( \@results, \@expected, 'Basic highlights match' );
}


METACHARACTERS: {
    my @args  = qw( \w*din\w* t/text/ );
    my $expected_original = <<'END';
<t/text/4th-of-july.txt>
{24}:(Riding) shotgun from town to town

<t/text/me-and-bobbie-mcgee.txt>
{8}:(Holdin)' Bobbie's hand in mine
{24}:To be (holding) Bobbie's body next to mine

<t/text/science-of-myth.txt>
{14}:In fact, for better (understanding) we take the facts of science and apply them
END

    $expected_original = windows_slashify( $expected_original ) if is_windows;

    my @expected = colorize( $expected_original );

    my @results = run_ack( @args, @HIGHLIGHT );

    is_deeply( \@results, \@expected, 'Metacharacters match' );
}


CONTEXT: {
    my @args  = qw( love -C1 t/text/ );

    my $expected_original = <<'END';
<t/text/4th-of-july.txt>
{11}-You were pretty as can be, sitting in the front seat
{12}:Looking at me, telling me you (love) me,
{13}-And you're happy to be with me on the 4th of July

<t/text/shut-up-be-happy.txt>
{4}-Stay in your homes.
{5}:Do not attempt to contact (love)d ones, insurance agents or attorneys.
{6}-Shut up.
END

    $expected_original = windows_slashify( $expected_original ) if is_windows;

    my @expected = colorize( $expected_original );

    my @results = run_ack( @args, @HIGHLIGHT );

    is_deeply( \@results, \@expected, 'Context is all good' );
}
