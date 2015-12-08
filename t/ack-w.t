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
    # Because the . at the end of the regular expression is not a word
    # character, a word boundary is not required after the match.
    my @expected = (
        "And he didn't leave very much for my Ma and me",
        'Well, he must have thought that it was quite a joke',
        'At an old saloon on a street of mud,',
        'Kicking and a-gouging in the mud and the blood and the beer.',
        'He kicked like a mule and he bit like a crocodile.',
        'Science and religion are not mutually exclusive',
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
    # The last character of the regexp is not a word, disabling the word boundary check at the end of the match.
    my @expected = (
        'But use your freedom of choice',
        'Took us all the way to New Orleans',
        'While other religions use the literal core to build foundations with',
    );

    my @files = qw( t/text );
    my @args = ( 'us()', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for us with word flag, but regexp does not end with word char' );
}

ENDS_BUT_NOT_BEGINS_WITH_WORD_CHAR: {
    # The first character of the regexp is not a word, disabling the word boundary check at the start of the match.
    my @expected = (
        'Alone with the morning burning red',
        'If you ain\'t got no one',
        'He said: "Now you just fought one hell of a fight',
        'He picked at one',
        'He picked at one',
        'Through all kinds of weather and everything we done',
        'But I\'d trade all of my tomorrows for one single yesterday',
        'If you\'ve ever questioned beliefs that you\'ve hold, you\'re not alone',
        'And the simple truth is that it\'s none of that \'cause',
        'And if it works, then it gets the job done',
        'Anyone caught outside the gates of their subdivision sector after curfew will be shot.',
        'Anyone gaught intefering with the collection of urine samples will be shot.',
        'The number one enemy of progress is questions.',
        'At last everything is done for you.',
    );

    my @files = qw( t/text );
    my @args = ( '()one', qw( -w -h --sort-files ) );

    ack_lists_match( [ @args, @files ], \@expected, 'Looking for one with word flag, but regexp does not begin with word char' );
}

NEITHER_BEGINS_NOR_ENDS_WITH_WORD_CHAR: {
    # Because the regular expression doesn't begin or end with a word character, the 'words mode' doesn't affect the match.
    my @expected = (
        'In the case of Christianity and Judaism there exists the belief',
        'While other religions use the literal core to build foundations with',
        'See, half the world sees the myth as fact, and it\'s seen as a lie by the other half',
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
