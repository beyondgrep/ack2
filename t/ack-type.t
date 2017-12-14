#!perl -T

use strict;
use warnings;
use lib 't';

use Cwd ();
use Test::More tests => 16;
use Util;

prep_environment();

my @SWAMP = qw( t/swamp );

TEST_TYPE: {
    my @expected = line_split( <<'HERE' );
t/swamp/0:1:#!/usr/bin/perl -w
t/swamp/Makefile.PL:1:#!perl -T
t/swamp/options-crlf.pl:1:#!/usr/bin/env perl
t/swamp/options.pl:1:#!/usr/bin/env perl
t/swamp/perl-test.t:1:#!perl -T
t/swamp/perl-without-extension:1:#!/usr/bin/perl -w
t/swamp/perl.cgi:1:#!perl -T
t/swamp/perl.pl:1:#!perl -T
t/swamp/perl.pm:1:#!perl -T
HERE

    foreach my $line ( @expected ) {
        $line =~ s/^(.*?)(?=:)/reslash( $1 )/ge;
    }

    my @args    = qw( --type=perl --nogroup --noheading --nocolor );
    my @files   = @SWAMP;
    my $target  = 'perl';

    my @results = run_ack( @args, $target, @files );
    sets_match( \@results, \@expected, 'TEST_TYPE' );
}

TEST_NOTYPE: {
    my @expected = line_split( <<'HERE' );
t/swamp/c-header.h:1:/*    perl.h
t/swamp/Makefile:1:# This Makefile is for the ack extension to perl.
HERE

    foreach my $line ( @expected ) {
        $line =~ s/^(.*?)(?=:)/reslash( $1 )/ge;
    }

    my @args    = qw( --type=noperl --nogroup --noheading --nocolor );
    my @files   = @SWAMP;
    my $target  = 'perl';

    my @results = run_ack( @args, $target, @files );
    sets_match( \@results, \@expected, 'TEST_NOTYPE' );
}

TEST_UNKNOWN_TYPE: {
    my @args   = qw( --ignore-ack-defaults --type-add=perl:ext:pl --type=foo --nogroup --noheading --nocolor );
    my @files   = @SWAMP;
    my $target = 'perl';

    my ( $stdout, $stderr ) = run_ack_with_stderr( @args, $target, @files );

    is_empty_array( $stdout, 'Should have no lines back' );
    first_line_like( $stderr, qr/Unknown type 'foo'/ );
}

TEST_NOTYPES: {
    my @args   = qw( --ignore-ack-defaults --type=perl --nogroup --noheading --nocolor );
    my @files  = @SWAMP;
    my $target = 'perl';

    my ( $stdout, $stderr ) = run_ack_with_stderr( @args, $target, @files );

    is_empty_array( $stdout, 'Should have no lines back' );
    first_line_like( $stderr, qr/Unknown type 'perl'/ );
}

TEST_NOTYPE_OVERRIDE: {
    my @expected = (
        reslash('t/swamp/html.htm') . ':2:<html><head><title>Boring test file </title></head>',
        reslash('t/swamp/html.html') . ':2:<html><head><title>Boring test file </title></head>',
    );

    my @lines = run_ack( '--nohtml', '--html', '--sort-files', '<title>', @SWAMP );
    is_deeply( \@lines, \@expected );
}

TEST_TYPE_OVERRIDE: {
    my @lines = run_ack( '--html', '--nohtml', '<title>', @SWAMP );
    is_empty_array( \@lines );
}

TEST_NOTYPE_ACKRC_CMD_LINE_OVERRIDE: {
    my $ackrc = <<'HERE';
--nohtml
HERE

    my @expected = (
        reslash('t/swamp/html.htm') . ':2:<html><head><title>Boring test file </title></head>',
        reslash('t/swamp/html.html') . ':2:<html><head><title>Boring test file </title></head>',
    );

    my @lines = run_ack('--html', '--sort-files', '<title>', @SWAMP, {
        ackrc => \$ackrc,
    });
    is_deeply( \@lines, \@expected );
}

TEST_TYPE_ACKRC_CMD_LINE_OVERRIDE: {
    my $ackrc = <<'HERE';
--html
HERE

    my @expected;

    my @lines = run_ack('--nohtml', '<title>', @SWAMP, {
        ackrc => \$ackrc,
    });
    is_deeply( \@lines, \@expected );
}
