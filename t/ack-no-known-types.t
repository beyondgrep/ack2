#!perl

use strict;
use warnings;

use File::Find;
use Test::More tests => 2;

use lib 't';
use Util;

prep_environment();

my @files = split "\n", # using qw() produces the warning "Possible attempt to put comments in qw() list"
qq(t/swamp/0
t/swamp/c-header.h
t/swamp/c-source.c
t/swamp/CMakeLists.txt
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
t/swamp/not-an-#emacs-workfile#
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
t/swamp/stuff.cmake);

ack_sets_match( [ '--no-known-types', '-f', 't/swamp' ], \@files, '--no-known-types test' );

ack_sets_match( [ '-K', '-f', 't/swamp' ], \@files, '-K test' );
