use strict;
use warnings;
use lib 't';

use Test::More tests => 11;

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

    local $Test::Builder::Level = $Test::Builder::Level + 1;

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

    is_deeply($got_opts, $expected_opts)       or diag "Options did not match";
    is_deeply($got_targets, $expected_targets) or diag "Targets did not match";
}

my %defaults = (
    after_context  => undef,
    before_context => undef,
);

use_ok 'App::Ack::ConfigLoader';

test_loader
    expected_opts    => { %defaults },
    expected_targets => [],
    'empty inputs should result in default outputs';

test_loader
    argv             => ['-A', '15'],
    expected_opts    => { %defaults, after_context => 15 },
    expected_targets => [],
    '-A should set after_context';

test_loader
    argv             => ['--after-context=15'],
    expected_opts    => { %defaults, after_context => 15 },
    expected_targets => [],
    '--after-context should set after_context';

test_loader
    argv             => ['-B', '15'],
    expected_opts    => { %defaults, before_context => 15 },
    expected_targets => [],
    '-B should set before_context';

test_loader
    argv             => ['--before-context=15'],
    expected_opts    => { %defaults, before_context => 15 },
    expected_targets => [],
    '--before-context should set before_context';
