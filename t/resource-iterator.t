#!perl -T

use warnings;
use strict;

use Test::More tests => 1;
use File::Next 0.22;

use lib 't';
use Util;

prep_environment();

sub slurp {
    my $iter = shift;

    my @files;
    while ( defined ( my $file = $iter->() ) ) {
        push( @files, $file );
    }

    return @files;
}

UNFILTERED: {
    my $iter =
        File::Next::files( {
            file_filter    => undef,
            descend_filter => undef,
        }, 't/swamp' );

    my @files = slurp( $iter );

    sets_match( \@files, [qw(
            t/swamp/0
            t/swamp/blib/ignore.pir
            t/swamp/blib/ignore.pm
            t/swamp/blib/ignore.pod
            t/swamp/c-header.h
            t/swamp/c-source.c
            t/swamp/crystallography-weenies.f
            t/swamp/example.R
            t/swamp/file.bar
            t/swamp/file.foo
            t/swamp/fresh.css
            t/swamp/fresh.css.min
            t/swamp/fresh.min.css
            t/swamp/groceries/another_subdir/CVS/fruit
            t/swamp/groceries/another_subdir/CVS/junk
            t/swamp/groceries/another_subdir/CVS/meat
            t/swamp/groceries/another_subdir/fruit
            t/swamp/groceries/another_subdir/junk
            t/swamp/groceries/another_subdir/meat
            t/swamp/groceries/another_subdir/RCS/fruit
            t/swamp/groceries/another_subdir/RCS/junk
            t/swamp/groceries/another_subdir/RCS/meat
            t/swamp/groceries/CVS/fruit
            t/swamp/groceries/CVS/junk
            t/swamp/groceries/CVS/meat
            t/swamp/groceries/fruit
            t/swamp/groceries/junk
            t/swamp/groceries/meat
            t/swamp/groceries/RCS/fruit
            t/swamp/groceries/RCS/junk
            t/swamp/groceries/RCS/meat
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
            t/swamp/minified.js.min
            t/swamp/minified.min.js
            t/swamp/moose-andy.jpg
            t/swamp/notaMakefile
            t/swamp/notaRakefile
            t/swamp/notes.md
            t/swamp/options-crlf.pl
            t/swamp/options.pl
            t/swamp/options.pl.bak
            t/swamp/parrot.pir
            t/swamp/perl-test.t
            t/swamp/perl-without-extension
            t/swamp/perl.cgi
            t/swamp/perl.pl
            t/swamp/perl.handler.pod
            t/swamp/perl.pm
            t/swamp/perl.pod
            t/swamp/perl.tar.gz
            t/swamp/perltoot.jpg
            t/swamp/pipe-stress-freaks.F
            t/swamp/Rakefile
            t/swamp/Sample.ascx
            t/swamp/Sample.asmx
            t/swamp/sample.asp
            t/swamp/sample.aspx
            t/swamp/sample.rake
            t/swamp/service.svc
            t/swamp/solution8.tar
            t/swamp/stuff.cmake
            t/swamp/CMakeLists.txt
            ),
            't/swamp/#emacs-workfile.pl#',
            't/swamp/not-an-#emacs-workfile#',
        ], 'UNFILTERED' );
}

done_testing();
