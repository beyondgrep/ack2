#!perl -T

use warnings;
use strict;

use Test::More tests => 6;

use lib 't';
use Util;

prep_environment();

DEFAULT_DIR_EXCLUSIONS: {
    my @expected = ( qw(
        t/swamp/0
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
        t/swamp/Makefile.PL
        t/swamp/MasterPage.master
        t/swamp/notaMakefile
        t/swamp/notaRakefile
        t/swamp/notes.md
        t/swamp/options-crlf.pl
        t/swamp/options.pl
        t/swamp/parrot.pir
        t/swamp/perl-test.t
        t/swamp/perl-without-extension
        t/swamp/perl.cgi
        t/swamp/perl.handler.pod
        t/swamp/perl.pl
        t/swamp/perl.pm
        t/swamp/perl.pod
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

    my @args = qw( -f t/swamp );

    ack_sets_match( [ @args ], \@expected, 'DEFAULT_DIR_EXCLUSIONS' );
    is( get_rc(), 0, '-f with matches exits with 0' );
}

COMBINED_FILTERS: {
    my @expected = qw(
        t/swamp/0
        t/swamp/perl.pm
        t/swamp/Rakefile
        t/swamp/options-crlf.pl
        t/swamp/options.pl
        t/swamp/perl-without-extension
        t/swamp/perl.cgi
        t/swamp/Makefile.PL
        t/swamp/perl-test.t
        t/swamp/perl.handler.pod
        t/swamp/perl.pl
        t/swamp/perl.pod
    );

    my @args = qw( -f t/swamp --perl --rake );

    ack_sets_match( [ @args ], \@expected, 'COMBINED_FILTERS' );
    is( get_rc(), 0, '-f with matches exits with 0' );
}

EXIT_CODE: {
    my @expected;

    my @args = qw( -f t/swamp --type-add=baz:ext:baz --baz );

    ack_sets_match( \@args, \@expected, 'EXIT_CODE' );
    is( get_rc(), 1, '-f with no matches exits with 1' );
}

done_testing();
