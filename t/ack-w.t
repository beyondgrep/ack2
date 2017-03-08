#!perl -T

use warnings;
use strict;

use Test::More tests => 18;

use lib 't';
use Util;

prep_environment();

PLAIN_WORD: {
    my @expected = (
        'Was before he left, he went and named me Sue.',
        'I tell ya, life ain\'t easy for a boy named Sue.',
        'Sat the dirty, mangy dog that named me Sue.',
        'And I said: "My name is Sue! How do you do! Now you gonna die!"',
        'Cause I\'m the son-of-a-bitch that named you Sue."',
        'Bill or George! Anything but Sue! I still hate that name!',
        '    -- "A Boy Named Sue", Johnny Cash',
    );

    my @files = qw( t/text );
    my @args = qw( Sue -w -h --sort-files );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for Sue as a word' );
}

PLAIN_WORD_WITH_TRAILING_PUNC: {
    my @expected = ();

    my @files = qw( t/text );
    my @args = qw( Sue! -w -h --sort-files );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for Sue! as a word' );
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
    # It's OK to have a metacharacter at the end.  It's still a word.
    my @expected = (
        'At an old saloon on a street of mud,',
        'Kicking and a-gouging in the mud and the blood and the beer.',
    );

    my @files = qw( t/text );
    my @args = ( 'mu.', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for mu.' );
}

BEGINS_AND_ENDS_WITH_WORD_CHAR: {
    # Normal case of whole word match.
    my @expected = (
      'And I said: "My name is Sue! How do you do! Now you gonna die!"',
      "To kill me now, and I wouldn't blame you if you do.",
    );

    my @files = qw( t/text );
    my @args = ( 'do', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for do as whole word' );
}

BEGINS_BUT_NOT_ENDS_WITH_WORD_CHAR: {
    # Punctuation at the end is OK to have.  It doesn't affect wordness.
    my @expected = (
        'Took us all the way to New Orleans',
    );

    my @files = qw( t/text );
    my @args = ( 'us()', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for us with word flag, but regexp does not end with word char' );
}

ENDS_BUT_NOT_BEGINS_WITH_WORD_CHAR: {
    # Punctuation at the beginning is OK to have.  It doesn't affect wordness.
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
    # Wrapping the regex in parens doesn't affect wordness.
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
