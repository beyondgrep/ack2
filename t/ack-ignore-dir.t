#!perl

use warnings;
use strict;

use Test::More tests => 26;
use File::Spec;

use lib 't';
use Util;

prep_environment();

my @files_mentioning_apples = qw(
    t/swamp/groceries/fruit
    t/swamp/groceries/junk
    t/swamp/groceries/another_subdir/fruit
    t/swamp/groceries/another_subdir/junk
    t/swamp/groceries/another_subdir/CVS/fruit
    t/swamp/groceries/another_subdir/CVS/junk
    t/swamp/groceries/another_subdir/RCS/fruit
    t/swamp/groceries/another_subdir/RCS/junk
    t/swamp/groceries/subdir/fruit
    t/swamp/groceries/subdir/junk
    t/swamp/groceries/CVS/fruit
    t/swamp/groceries/CVS/junk
    t/swamp/groceries/RCS/fruit
    t/swamp/groceries/RCS/junk
);
my @std_ignore = qw( RCS CVS );

my( @expected, @results, $test_description );

sub set_up_assertion_that_these_options_will_ignore_those_directories {
    my( $options, $ignored_directories, $optional_test_description ) = @_;
    $test_description = $optional_test_description || join( ' ', @{$options} );

    my $filter = join( '|', @{$ignored_directories} );
    @expected = grep { ! m{/(?:$filter)/} } @files_mentioning_apples;

    @results = run_ack( @{$options}, '--noenv', '-la', 'apple', 't/swamp' );

    # ignore everything in .svn directories
    my $svn_regex = quotemeta File::Spec->catfile( '', '.svn', '' ); # the respective filesystem equivalent of '/.svn/'
    @results = grep { ! m/$svn_regex/ } @results;

    return;
}

FILES_HAVE_BEEN_SET_UP_AS_EXPECTED: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '-u',  ],
        [        ],
        'test data contents are as expected',
    );
    sets_match( \@results, \@expected, $test_description );
}

DASH_IGNORE_DIR: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=subdir',  ],
        [ @std_ignore, 'subdir',  ],
    );
    sets_match( \@results, \@expected, $test_description );
}

DASH_IGNORE_DIR_WITH_SLASH: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=subdir/',  ],
        [ @std_ignore, 'subdir',  ],
    );
    sets_match( \@results, \@expected, $test_description );
}

DASH_IGNORE_DIR_MULTIPLE_TIMES: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=subdir', '--ignore-dir=another_subdir', ],
        [ @std_ignore, 'subdir',              'another_subdir', ],
    );
    sets_match( \@results, \@expected, $test_description );
}

DASH_NOIGNORE_DIR: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--noignore-dir=CVS', ],
        [ 'RCS',                ],
    );
    sets_match( \@results, \@expected, $test_description );
}

DASH_NOIGNORE_DIR_MULTIPLE_TIMES: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--noignore-dir=CVS', '--noignore-dir=RCS', ],
        [                                             ],
    );
    sets_match( \@results, \@expected, $test_description );
}

DASH_IGNORE_DIR_WITH_DASH_NOIGNORE_DIR: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--noignore-dir=CVS', '--ignore-dir=subdir', ],
        [ 'RCS',                             'subdir', ],
    );
    sets_match( \@results, \@expected, $test_description );
}

LAST_ONE_LISTED_WINS: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--noignore-dir=CVS', '--ignore-dir=CVS', ],
        [ @std_ignore,                              ],
    );
    sets_match( \@results, \@expected, $test_description );

    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--noignore-dir=CVS', '--ignore-dir=CVS', '--noignore-dir=CVS', ],
        [ 'RCS',                                                          ],
    );
    sets_match( \@results, \@expected, $test_description );

    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=subdir', '--noignore-dir=subdir', ],
        [ @std_ignore,                                    ],
    );
    sets_match( \@results, \@expected, $test_description );

    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=subdir', '--noignore-dir=subdir', '--ignore-dir=subdir', ],
        [ @std_ignore,                                                 'subdir', ],
    );
    sets_match( \@results, \@expected, $test_description );
}

DASH_U_BEATS_THE_PANTS_OFF_IGNORE_DIR_ANY_DAY_OF_THE_WEEK: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '-u', '--ignore-dir=subdir', ],
        [                              ],
    );
    sets_match( \@results, \@expected, $test_description );
}

DASH_IGNORE_DIR_IGNORES_RELATIVE_PATHS: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=' . File::Spec->catdir('t' ,'swamp', 'groceries' , 'another_subdir'), ],
        [ @std_ignore, 'another_subdir',                   ],
        'ignore relative paths instead of just directory names',
    );
    sets_match( \@results, \@expected, $test_description );
}
