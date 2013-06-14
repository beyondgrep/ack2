#!perl -Tw

use warnings;
use strict;

use lib 't';
use Util;

use Test::More;

my @files = ( qw( ack ), glob( '*.pm' ), glob( 't/*.t' ) );

plan tests => scalar @files;

for my $file ( @files ) {
    subtest $file => sub {
        plan tests => 2;

        my @lines = read_file( $file );
        my $text = join( '', @lines );

        chomp @lines;
        my $ok = 1;
        for my $line ( @lines ) {
            if ( $line =~ /[^ -~]/ ) {
                my $col = $-[0] + 1;
                diag( "$file has hi-bit characters at $.:$col" );
                $ok = 0;
            }
        }
        ok( $ok, 'No hi-bit characters found' );

        is( index($text, "\t"), -1, "$file should have no embedded tabs" );
    }
}
