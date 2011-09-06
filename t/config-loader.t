use strict;
use warnings;
use lib 't';

use Test::Builder;
use Test::Deep::NoTest qw(cmp_details deep_diag); # ditch this eventually (?)
use Test::More tests => 2;

use Carp qw(croak);
use File::Temp;
use MockFinder;

sub indent {
    my ( $s ) = @_;

    $s =~ s/^/  /gm;

    return $s;
}

sub write_file {
    my ( $filename, $contents ) = @_;

    my $fh;
    open $fh, '>', $filename or croak $!;
    print $fh $contents;
    close $fh;
}

sub test_loader {
    my $name = pop if @_ % 2;
    my %opts = @_;

    my $tb = Test::Builder->new;

    my ( $env, $argv, $expected_opts, $expected_targets ) =
        delete @opts{qw/env argv expected_opts expected_targets/};

    $env  = '' unless defined $env;
    $argv = [] unless defined $argv;

    my @files = map {
        $opts{$_}
    } sort { 
        my ( $a_end ) = $a =~ /(\d+)/;
        my ( $b_end ) = $b =~ /(\d+)/;

        $a_end <=> $b_end
    } grep { /^file\d+/ } keys %opts; 
    my @tempfiles;
    foreach my $contents (@files) {
        my $file = File::Temp->new;
        print $file $contents;
        close $file;
        push @tempfiles, $file;
    }

    my ( $got_opts, $got_targets );

    do {
        local $ENV{'ACK_OPTIONS'} = $env;
        local @ARGV               = @$argv;

        my $finder = MockFinder->new(map { $_->filename } @tempfiles);
        my $loader = App::Ack::ConfigLoader->new(
            finder => $finder,
        );

        $got_opts    = $loader->options;
        $got_targets = $loader->targets;
    };

    my $diag_prefix    = 'Options did not match';
    my ( $ok, $stack ) = cmp_details($got_opts, $expected_opts);
    if($ok) {
        $diag_prefix = 'Targets did not match';
        ( $ok, $stack ) = cmp_details($got_targets, $expected_targets);
    }

    return $tb->ok($ok, $name) || $tb->diag("$diag_prefix\n" . indent(deep_diag($stack), 2));
}

use_ok 'App::Ack::ConfigLoader';

test_loader
    expected_opts    => {},
    expected_targets => [],
    'empty inputs should result in empty outputs';
