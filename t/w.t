#!perl -T

use warnings;
use strict;

use Test::More tests => 1;

use lib 't';
use Util;
#use Barfly;

prep_environment();

my $barfly = Barfly->new;
$barfly->read( 't/barfly/dash-w.txt' );
$barfly->run;

exit 0;


package Barfly;

use Test::More;

sub new {
    my $class = shift;

    return bless { blocks => [] }, $class;
}


sub read {
    my $self     = shift;
    my $filename = shift;

    open( my $file, '<', $filename ) or die "Can't read $filename: $!";

    my $block;
    my $section;
    while ( my $line = <$file> ) {
        chomp $line;
        next if $line =~ /^#/;
        next unless $line =~ /./;

        if ( $line =~ /^BEGIN\s*(.*)\s*/ ) {
            !defined($block) or die 'We are already in the middle of a block';

            $block = Barfly::Block->new( $1 );
            $section = undef;
        }
        elsif ( $line eq 'END' ) {
            {use Data::Dumper; local $Data::Dumper::Sortkeys=1; local $Data::Dumper::Trailingcomma=1; warn Dumper( $block )}
            push( @{$self->{blocks}}, $block );
            $block = undef;
            $section = undef;
        }
        elsif ( $line eq 'RUN' || $line eq 'YES' || $line eq 'NO' || $line eq 'YESLINES' ) {
            $section = $line;
        }
        elsif ( $section eq 'YESLINES' ) {
            $block->add_line( $section, $line );
        }
        else {
            $block->add_line( $section, $line );
        }
    }

    return 1;
}


sub run {
    my $self = shift;

    pass();
}


package Barfly::Block;

sub new {
    my $class = shift;
    my $label = shift // die 'Block label cannot be blank';

    return bless {
        label => $label,
    }, $class;
}

sub add_line {
    my $self    = shift;
    my $section = shift;
    my $line    = shift;

    push @{$self->{$section}}, $line;

    return;
}
