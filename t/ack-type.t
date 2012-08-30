#!perl

use strict;
use warnings;
use lib 't';

use Test::More tests => 10;
use File::Next ();
use Util;

prep_environment();

TEST_TYPE: {
    my @expected = split( /\n/, <<'EOF' );
t/swamp/0:1:#!/usr/bin/perl -w
t/swamp/Makefile.PL:1:#!perl -T
t/swamp/options-crlf.pl:1:#!/usr/bin/env perl
t/swamp/options.pl:1:#!/usr/bin/env perl
t/swamp/perl-test.t:1:#!perl -T
t/swamp/perl-without-extension:1:#!/usr/bin/perl -w
t/swamp/perl.cgi:1:#!perl -T
t/swamp/perl.pl:1:#!perl -T
t/swamp/perl.pm:1:#!perl -T
EOF

    foreach my $line ( @expected ) {
        $line =~ s/^(.*?)(?=:)/File::Next::reslash( $1 )/ge;
    }

    my @args    = ( '--type=perl', '--nogroup', '--noheading', '--nocolor' );
    my @files   = ( 't/swamp' );
    my $target  = 'perl';

    my @results = run_ack( @args, $target, @files );
    sets_match( \@results, \@expected );
}

TEST_NOTYPE: {
    my @expected = split( /\n/, <<'EOF' );
t/swamp/c-header.h:1:/*    perl.h
t/swamp/Makefile:1:# This Makefile is for the ack extension to perl.
EOF

    foreach my $line ( @expected ) {
        $line =~ s/^(.*?)(?=:)/File::Next::reslash( $1 )/ge;
    }

    my @args    = ( '--type=noperl', '--nogroup', '--noheading', '--nocolor' );
    my @files   = ( 't/swamp' );
    my $target  = 'perl';

    my @results = run_ack( @args, $target, @files );
    sets_match( \@results, \@expected );
}

TEST_UNKNOWN_TYPE: {
    my @args   = ( '--ignore-ack-defaults', '--type-add=perl:ext:pl',
        '--type=foo', '--nogroup', '--noheading', '--nocolor' );
    my @files  = ( 't/swamp' );
    my $target = 'perl';

    my ( $stdout, $stderr ) = run_ack_with_stderr( @args, $target, @files );

    is scalar(@$stdout), 0;
    ok scalar(@$stderr) > 0;
    like $stderr->[0], qr/Unknown type 'foo'/ or diag(explain($stderr));
}

TEST_NOTYPES: {
    my @args   = ( '--ignore-ack-defaults', '--type=perl', '--nogroup',
        '--noheading', '--nocolor' );
    my @files  = ( 't/swamp' );
    my $target = 'perl';

    my ( $stdout, $stderr ) = run_ack_with_stderr( @args, $target, @files );

    is scalar(@$stdout), 0;
    ok scalar(@$stderr) > 0;
    like $stderr->[0], qr/Unknown type 'perl'/ or diag(explain($stderr));
}
