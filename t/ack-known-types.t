#!perl -T

use strict;
use warnings;

use Test::More tests => 4;

use lib 't';
use Util;

prep_environment();

my @files = qw(
t/swamp/0
t/swamp/Rakefile
t/swamp/parrot.pir
t/swamp/options-crlf.pl
t/swamp/options.pl
t/swamp/javascript.js
t/swamp/html.html
t/swamp/perl-without-extension
t/swamp/sample.rake
t/swamp/perl.cgi
t/swamp/Makefile
t/swamp/pipe-stress-freaks.F
t/swamp/perl.pod
t/swamp/html.htm
t/swamp/perl-test.t
t/swamp/perl.handler.pod
t/swamp/perl.pl
t/swamp/Makefile.PL
t/swamp/MasterPage.master
t/swamp/c-source.c
t/swamp/perl.pm
t/swamp/c-header.h
t/swamp/crystallography-weenies.f
t/swamp/CMakeLists.txt
t/swamp/Sample.ascx
t/swamp/Sample.asmx
t/swamp/sample.asp
t/swamp/sample.aspx
t/swamp/service.svc
t/swamp/stuff.cmake
t/swamp/example.R
t/swamp/fresh.css
t/swamp/lua-shebang-test
);

my @files_no_perl = qw(
t/swamp/Rakefile
t/swamp/parrot.pir
t/swamp/javascript.js
t/swamp/html.html
t/swamp/sample.rake
t/swamp/Makefile
t/swamp/MasterPage.master
t/swamp/pipe-stress-freaks.F
t/swamp/html.htm
t/swamp/c-source.c
t/swamp/c-header.h
t/swamp/crystallography-weenies.f
t/swamp/CMakeLists.txt
t/swamp/Sample.ascx
t/swamp/Sample.asmx
t/swamp/sample.asp
t/swamp/sample.aspx
t/swamp/service.svc
t/swamp/stuff.cmake
t/swamp/example.R
t/swamp/fresh.css
t/swamp/lua-shebang-test
);

ack_sets_match( [ '--known-types', '-f', 't/swamp' ], \@files, '--known-types test #1' );
ack_sets_match( [ '--known-types', '--noperl', '-f', 't/swamp' ], \@files_no_perl, '--known-types test #2' );

ack_sets_match( [ '-k', '-f', 't/swamp' ], \@files, '-k test #1' );
ack_sets_match( [ '-k', '-f', '--noperl', 't/swamp' ], \@files_no_perl, '-k test #2' );
