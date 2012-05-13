#!perl

use strict;
use warnings;
use lib 't';

use Test::More;

use Carp qw(croak);
use File::Temp;

use File::Slurp qw( read_file );

use App::Ack::Filter::Default;
use App::Ack::ConfigLoader;


sub test_loader {
    pop if @_ % 2;

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

        $a_end <=> $b_end;
    } grep { /^file\d+/ } keys %opts;
    foreach my $contents (@files) {
        my $file = File::Temp->new;
        print {$file} $contents;
        close $file or die $!;
    }

    my ( $got_opts, $got_targets );

    do {
        local $ENV{'ACK_OPTIONS'} = $env;
        local @ARGV;

        my @arg_sources = (
            ARGV => $argv,
            map { $_ => scalar read_file($_) } @files,
        );

        $got_opts    = App::Ack::ConfigLoader::process_args( @arg_sources );
        $got_targets = [ @ARGV ];
    };

    is_deeply( $got_opts, $expected_opts, 'Options match' )       or diag 'Options did not match';
    is_deeply( $got_targets, $expected_targets, 'Targets match' ) or diag 'Targets did not match';

    return;
}

my %defaults = (
    after_context     => undef,
    all               => undef,
    before_context    => undef,
    'break'           => undef,
    color             => undef,
    column            => undef,
    count             => undef,
    f                 => undef,
    files_from        => undef,
    filters           => [ App::Ack::Filter::Default->new ],
    flush             => undef,
    follow            => undef,
    g                 => undef,
    h                 => undef,
    H                 => undef,
    heading           => undef,
    i                 => undef,
    l                 => undef,
    m                 => undef,
    n                 => undef,
    output            => undef,
    pager             => undef,
    passthru          => undef,
    print0            => undef,
    Q                 => undef,
    regex             => undef,
    show_types        => undef,
    smart_case        => undef,
    sort_files        => undef,
    u                 => undef,
    v                 => undef,
    w                 => undef,
);

test_loader(
    expected_opts    => { %defaults },
    expected_targets => [],
    'empty inputs should result in default outputs'
);

test_loader(
    argv             => ['-A', '15'],
    expected_opts    => { %defaults, after_context => 15 },
    expected_targets => [],
    '-A should set after_context'
);

test_loader(
    argv             => ['--after-context=15'],
    expected_opts    => { %defaults, after_context => 15 },
    expected_targets => [],
    '--after-context should set after_context'
);

test_loader(
    argv             => ['-B', '15'],
    expected_opts    => { %defaults, before_context => 15 },
    expected_targets => [],
    '-B should set before_context'
);

test_loader(
    argv             => ['--before-context=15'],
    expected_opts    => { %defaults, before_context => 15 },
    expected_targets => [],
    '--before-context should set before_context'
);

done_testing;
