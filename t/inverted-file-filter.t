#!perl -T

use strict;
use warnings;
use lib 't';

use Test::More tests => 2;
use Util;

prep_environment();

EXCLUDE_ONLY: {
    my @expected = ( qw(
        t/swamp/c-header.h
        t/swamp/c-source.c
        t/swamp/crystallography-weenies.f
        t/swamp/example.R
        t/swamp/file.bar
        t/swamp/file.foo
        t/swamp/fresh.css
        t/swamp/groceries/another_subdir/fruit
        t/swamp/groceries/another_subdir/junk
        t/swamp/groceries/another_subdir/meat
        t/swamp/groceries/fruit
        t/swamp/groceries/junk
        t/swamp/groceries/meat
        t/swamp/groceries/subdir/fruit
        t/swamp/groceries/subdir/junk
        t/swamp/groceries/subdir/meat
        t/swamp/html.htm
        t/swamp/html.html
        t/swamp/incomplete-last-line.txt
        t/swamp/javascript.js
        t/swamp/lua-shebang-test
        t/swamp/Makefile
        t/swamp/MasterPage.master
        t/swamp/notaMakefile
        t/swamp/notaRakefile
        t/swamp/notes.md
        t/swamp/parrot.pir
        t/swamp/pipe-stress-freaks.F
        t/swamp/Rakefile
        t/swamp/Sample.ascx
        t/swamp/Sample.asmx
        t/swamp/sample.asp
        t/swamp/sample.aspx
        t/swamp/sample.rake
        t/swamp/service.svc
        t/swamp/stuff.cmake
        t/swamp/CMakeLists.txt
        ),
        't/swamp/not-an-#emacs-workfile#',
    );

    my @args = qw( --noperl -f t/swamp );

    ack_sets_match( [ @args ], \@expected, 'Exclude only' );
}

INCLUDE_PLUS_EXCLUDE_ONLY: {
    my @expected = qw(
        t/swamp/0
        t/swamp/perl.pm
        t/swamp/options-crlf.pl
        t/swamp/options.pl
        t/swamp/perl-without-extension
        t/swamp/perl.cgi
        t/swamp/Makefile.PL
        t/swamp/perl-test.t
        t/swamp/perl.pl
    );

    my @args = ( '--type-add=pod:ext:pod', '--perl', '--nopod', '-f', 't/swamp' );

    ack_sets_match( [ @args ], \@expected, 'Include plus exclude only' );
}
