#!perl

use strict;
use warnings;
use lib 't';

use FilterTest;
use Test::More tests => 1;

use App::Ack::Filter::Default;

App::Ack::Filter->register_filter('default' => 'App::Ack::Filter::Default');

filter_test(
    [ 'default' ], [
        't/swamp/#emacs-workfile.pl#',
        't/swamp/0',
        't/swamp/c-header.h',
        't/swamp/c-source.c',
        't/swamp/crystallography-weenies.f',
        't/swamp/example.R',
        't/swamp/file.bar',
        't/swamp/file.foo',
        't/swamp/html.htm',
        't/swamp/html.html',
        't/swamp/incomplete-last-line.txt',
        't/swamp/javascript.js',
        't/swamp/Makefile',
        't/swamp/Makefile.PL',
        't/swamp/not-an-#emacs-workfile#',
        't/swamp/notaMakefile',
        't/swamp/notaRakefile',
        't/swamp/options.pl',
        't/swamp/options.pl.bak',
        't/swamp/parrot.pir',
        't/swamp/perl-test.t',
        't/swamp/perl-without-extension',
        't/swamp/perl.cgi',
        't/swamp/perl.pl',
        't/swamp/perl.pm',
        't/swamp/perl.pod',
        't/swamp/pipe-stress-freaks.F',
        't/swamp/Rakefile',
        't/swamp/sample.rake',
        't/swamp/blib/ignore.pir',
        't/swamp/blib/ignore.pm',
        't/swamp/blib/ignore.pod',
        't/swamp/groceries/fruit',
        't/swamp/groceries/junk',
        't/swamp/groceries/meat',
        't/swamp/groceries/another_subdir/fruit',
        't/swamp/groceries/another_subdir/junk',
        't/swamp/groceries/another_subdir/meat',
        't/swamp/groceries/another_subdir/CVS/fruit',
        't/swamp/groceries/another_subdir/CVS/junk',
        't/swamp/groceries/another_subdir/CVS/meat',
        't/swamp/groceries/another_subdir/RCS/fruit',
        't/swamp/groceries/another_subdir/RCS/junk',
        't/swamp/groceries/another_subdir/RCS/meat',
        't/swamp/groceries/CVS/fruit',
        't/swamp/groceries/CVS/junk',
        't/swamp/groceries/CVS/meat',
        't/swamp/groceries/RCS/fruit',
        't/swamp/groceries/RCS/junk',
        't/swamp/groceries/RCS/meat',
        't/swamp/groceries/subdir/fruit',
        't/swamp/groceries/subdir/junk',
        't/swamp/groceries/subdir/meat',
        't/swamp/stuff.cmake',
        't/swamp/CMakeLists.txt',
    ], 'only non-binary files should be matched'
);
