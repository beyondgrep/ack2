#!perl -T

use warnings;
use strict;

use Test::More tests => 8;

use lib 't';
use Util;

prep_environment();

TRAILING_PUNC: {
    my @expected = (
        'And I said: "My name is Sue! How do you do! Now you gonna die!"',
        'Bill or George! Anything but Sue! I still hate that name!',
    );

    my @files = qw( t/text );
    my @args = qw( Sue! -w -h );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for Sue!' );
}

TRAILING_METACHAR_BACKSLASH_W: {
    my @expected = (
        'At an old saloon on a street of mud,',
        'Kicking and a-gouging in the mud and the blood and the beer.',
    );

    my @files = qw( t/text );
    my @args = qw( mu\w -w -h );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for mu\\w' );
}


TRAILING_METACHAR_DOT: {
    local $TODO = q{I can't figure why the -w works from the command line, but not inside this test};
    my @expected = (
        'At an old saloon on a street of mud,',
        'Kicking and a-gouging in the mud and the blood and the beer.',
    );

    my @files = qw( t/text );
    my @args = ( 'mu.', qw( -w -h ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for mu.' );
}

# Test for issue #443
ALTERNATING_NUMBERS: {
    my @expected = ();

    my @files = qw( t/text/number.txt );

    my @args = ( '650|660|670|680', '-w' );

    ack_lists_match( [ @args, @files ], \@expected, 'Alternations should also respect boundaries when using -w' );
}

done_testing();
