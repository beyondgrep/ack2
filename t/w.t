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
$barfly->run( 'Dash W tests' );

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

    $self->{filename} = $filename;

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
            push( @{$self->{blocks}}, $block );
            $block = undef;
            $section = undef;
        }
        elsif ( $line eq 'RUN' || $line eq 'YES' || $line eq 'NO' || $line eq 'YESLINES' ) {
            $section = $line;
        }
        else {
            $block->add_line( $section, $line );
        }
    }

    return 1;
}


sub run {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $self = shift;
    my $msg  = shift // die 'Must pass a message to Barfly->run';

    return subtest $msg => sub {
        my @blocks = @{$self->{blocks}} or return fail( 'No blocks found!' );

        plan tests => scalar @blocks;
        for my $block ( @blocks ) {
            $block->run;
        }
    };
}


package Barfly::Block;

use Test::More;

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


sub run {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $self = shift;

    return subtest $self->{label} => sub {
        my @command_lines = @{$self->{RUN}} or die 'No RUN lines specified!';
        pass( $_ ) for @command_lines;
    };
}
