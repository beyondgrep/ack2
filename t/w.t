#!perl -T

use warnings;
use strict;

use Test::More tests => 6;

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

    my @blocks = @{$self->{blocks}} or return fail( 'No blocks found!' );

    for my $block ( @blocks ) {
        $block->run;
    }
}


package Barfly::Block;

use Test::More;
use Util;

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
        my @command_lines = @{$self->{RUN} // []} or die 'No RUN lines specified!';

        # Set up scratch file
        my @yes = @{$self->{YES} // []};
        my @no  = @{$self->{NO} // []};

        my $tempfile = File::Temp->new();
        print {$tempfile} join( "\n", @yes, @no );
        close $tempfile;

        diag $tempfile->filename;

        for my $command_line ( @command_lines ) {
            subtest $command_line => sub {
                plan tests => 2;

                $command_line =~ /(.*)/;
                $command_line = $1;

                my @args = split( / /, $command_line );
                @args > 1 or die "Invalid command line: $command_line";
                shift @args eq 'ack' or die 'Command line must begin with ack';

                my @results = main::run_ack( @args, $tempfile->filename );
                main::lists_match( \@results, \@yes, $command_line );
            };
        }
    };
}
