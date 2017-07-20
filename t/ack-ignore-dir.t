#!perl -T

use warnings;
use strict;

use Test::More tests => 45;
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
    t/swamp/groceries/dir.d/fruit
    t/swamp/groceries/dir.d/junk
    t/swamp/groceries/dir.d/CVS/fruit
    t/swamp/groceries/dir.d/CVS/junk
    t/swamp/groceries/dir.d/RCS/fruit
    t/swamp/groceries/dir.d/RCS/junk
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

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    $test_description = $optional_test_description || join( ' ', @{$options} );

    my $filter = join( '|', @{$ignored_directories} );
    @expected = grep { ! m{/(?:$filter)/} } @files_mentioning_apples;

    @results = run_ack( @{$options}, '--noenv', '-l', 'apple', 't/swamp' );

    # ignore everything in .svn directories
    my $svn_regex = quotemeta File::Spec->catfile( '', '.svn', '' ); # the respective filesystem equivalent of '/.svn/'
    @results = grep { ! m/$svn_regex/ } @results;

    return;
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

DASH_IGNORE_DIR_IGNORES_RELATIVE_PATHS: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=' . File::Spec->catdir('t' ,'swamp', 'groceries' , 'another_subdir'), ],
        [ @std_ignore, 'another_subdir',                   ],
        'ignore relative paths instead of just directory names',
    );
    sets_match( \@results, \@expected, $test_description );
}

NOIGNORE_SUBDIR_WINS: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=another_subdir', '--noignore-dir=CVS' ],
        [ 'RCS', 'another_subdir(?!/CVS)' ],
    );

    sets_match( \@results, \@expected, $test_description );
}

IGNORE_DIR_MATCH: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=match:/\w_subdir/' ],
        [ @std_ignore, 'another_subdir', ],
    );
    sets_match( \@results, \@expected, $test_description );
}

IGNORE_DIR_EXT: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=ext:d' ],
        [ @std_ignore, 'dir.d', ],
    );
    sets_match( \@results, \@expected, $test_description );
}

IGNORE_DIR_FIRSTMATCH: {
    my ( $stdout, $stderr ) = run_ack_with_stderr('--ignore-dir=firstlinematch:perl', '--noenv', '-l', 'apple', 't/swamp');

    is(scalar(@{$stdout}), 0, '--ignore-dir=firstlinematch:perl is erroneous and should print nothing to standard output');
    isnt(scalar(@{$stderr}), 0, '--ignore-dir=firstlinematch:perl is erroneous and should print something to standard error');
    like($stderr->[0], qr/Invalid filter specification "firstlinematch" for option '--ignore-dir'/, '--ignore-dir=firstlinematch:perl should report an error message');
}

IGNORE_DIR_MATCH_NOIGNORE_DIR: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=match:/\w_subdir/', '--noignore-dir=CVS' ],
        [ 'RCS', 'another_subdir(?!/CVS)', ],
    );
    sets_match( \@results, \@expected, $test_description );
}

IGNORE_DIR_MATCH_NOIGNORE_DIR_IS: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=match:/\w_subdir/', '--noignore-dir=is:CVS' ],
        [ 'RCS', 'another_subdir(?!/CVS)', ],
    );
    sets_match( \@results, \@expected, $test_description );
}

IGNORE_DIR_MATCH_NOIGNORE_DIR_MATCH: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--ignore-dir=match:/\w_subdir/', '--noignore-dir=match:/^..S/' ],
        [ 'another_subdir(?!/(?:CVS|RCS))', ],
    );
    sets_match( \@results, \@expected, $test_description );
}

NOIGNORE_DIR_RELATIVE_PATHS: {
    set_up_assertion_that_these_options_will_ignore_those_directories(
        [ '--noignore-dir=' . File::Spec->catdir('t' ,'swamp', 'groceries' , 'another_subdir', 'CVS'), ],
        [ 'RCS', '(?<!another_subdir/)CVS', ],
        'no-ignore relative paths instead of just directory names',
    );
    sets_match( \@results, \@expected, $test_description );
}

IGNORE_DIR_DONT_IGNORE_TARGET: {
    my @stdout = run_ack('--ignore-dir=swamp', '-f', 't/swamp');

    isnt(scalar(@stdout), 0, 'Specifying a directory on the command line should override ignoring it');
}

IGNORE_SUBDIR_OF_TARGET: {
    my @stdout = run_ack('--ignore-dir=swamp', '-l', 'quux', 't/swamp');
    is(scalar(@stdout), 0, 'Specifying a directory on the command line should still ignore matching subdirs');

    @stdout = run_ack('-l', 'quux', 't/swamp');
    is(scalar(@stdout), 1, 'Double-check it is found without ignore-dir');
}

# --noignore-dir=firstlinematch
# --ignore-dir=... + --noignore-dir=ext
# --ignore-dir=is + --noignore-dir=match
# --ignore-dir=is + --noignore-dir=ext
# --ignore-dir=match + --noignore-dir=match
# --ignore-dir=match + --noignore-dir=ext
# --ignore-dir=ext + --noignore-dir=match
# --ignore-dir=ext + --noignore-dir=ext
# re-ignore a directory
