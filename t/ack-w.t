#!perl -T

use warnings;
use strict;

use Test::More tests => 16;

use lib 't';
use Util;

prep_environment();

TRAILING_PUNC: {
    my @expected = (
        'And I said: "My name is Sue! How do you do! Now you gonna die!"',
        'Bill or George! Anything but Sue! I still hate that name!',
    );

    my @files = qw( t/text );
    my @args = qw( Sue! -w -h --sort-files );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for Sue!' );
}

TRAILING_METACHAR_BACKSLASH_W: {
    my @expected = (
        'At an old saloon on a street of mud,',
        'Kicking and a-gouging in the mud and the blood and the beer.',
    );

    my @files = qw( t/text );
    my @args = qw( mu\w -w -h --sort-files );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for mu\\w' );
}


TRAILING_METACHAR_DOT: {
    # Match a three-letter word beginning with 'mu', as a whole word.
    my @expected = (
        'At an old saloon on a street of mud,',
        'Kicking and a-gouging in the mud and the blood and the beer.',
    );

    my @files = qw( t/text );
    my @args = ( 'mu.', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for mu.' );
}

BEGINS_AND_ENDS_WITH_WORD_CHAR: {
    my @expected = (
      'And I said: "My name is Sue! How do you do! Now you gonna die!"',
      "To kill me now, and I wouldn't blame you if you do.",
    );

    my @files = qw( t/text );
    my @args = ( 'do', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for do as whole word' );
}

BEGINS_BUT_NOT_ENDS_WITH_WORD_CHAR: {
    # Match 'us' as a whole word.  The empty parens () at the end of the regexp
    # should not affect what strings it matches.
    #
    my @expected = (
        'Took us all the way to New Orleans',
    );

    my @files = qw( t/text );
    my @args = ( 'us()', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for us with word flag, but regexp does not end with word char' );
}

ENDS_BUT_NOT_BEGINS_WITH_WORD_CHAR: {
    # Match 'one' as a whole word.  The empty parens () at the start of the regexp
    # should not affect what strings it matches.
    #
    my @expected = (
        'If you ain\'t got no one',
        'He said: "Now you just fought one hell of a fight',
        'He picked at one',
        'He picked at one',
        'But I\'d trade all of my tomorrows for one single yesterday',
        'The number one enemy of progress is questions.',
    );

    my @files = qw( t/text );
    my @args = ( '()one', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for one with word flag, but regexp does not begin with word char' );
}

NEITHER_BEGINS_NOR_ENDS_WITH_WORD_CHAR: {
    # Match 'her' as a whole word.  The capturing parens should not affect whether a match is found.
    my @expected = (
        'Consider the case of the woman whose faith helped her make it through',
        'When she was raped and cut up, left for dead in her trunk, her beliefs held true'
    );

    my @files = qw( t/text/science-of-myth.txt );
    my @args = ( '(her)', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for her with word flag, but regexp does not begin or end with word char' );
}

# Test for issue #443
ALTERNATING_NUMBERS: {
    my @expected = ();

    my @files = qw( t/text/number.txt );

    my @args = ( '650|660|670|680', '-w' );

    ack_lists_match( [ @args, @files ], \@expected, 'Alternations should also respect boundaries when using -w' );
}

done_testing();
