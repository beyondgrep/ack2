use strict;
use warnings;

use Test::More tests => 2;

use lib 't';
use Util;

prep_environment();

my @files = qw(
t/swamp/0
t/swamp/Rakefile
t/swamp/parrot.pir
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
t/swamp/c-source.c
t/swamp/perl.pm
t/swamp/c-header.h
t/swamp/crystallography-weenies.f
t/swamp/CMakeLists.txt
t/swamp/stuff.cmake
t/swamp/example.R
);

ack_sets_match( [ '--known-types', '-f', 't/swamp' ], \@files);
