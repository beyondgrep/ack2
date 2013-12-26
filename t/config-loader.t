#!perl -T

use strict;
use warnings;
use lib 't';
use Util;

use Test::More;

use Carp qw(croak);
use File::Temp;

use App::Ack::Filter::Default;
use App::Ack::ConfigLoader;

delete @ENV{qw( PAGER ACK_PAGER ACK_PAGER_COLOR ACK_OPTIONS )};

my %defaults = (
    after_context             => undef,
    before_context            => undef,
    'break'                   => undef,
    color                     => undef,
    column                    => undef,
    count                     => undef,
    dont_report_bad_filenames => undef,
    f                         => undef,
    files_from                => undef,
    filters                   => [ App::Ack::Filter::Default->new ],
    flush                     => undef,
    follow                    => undef,
    g                         => undef,
    h                         => undef,
    H                         => undef,
    heading                   => undef,
    i                         => undef,
    l                         => undef,
    L                         => undef,
    m                         => undef,
    n                         => undef,
    output                    => undef,
    pager                     => undef,
    passthru                  => undef,
    print0                    => undef,
    Q                         => undef,
    regex                     => undef,
    show_types                => undef,
    smart_case                => undef,
    sort_files                => undef,
    v                         => undef,
    w                         => undef,
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

# XXX These tests should all be replicated to work off of the ack command line
#     tools instead of its internal APIs!
do {
    local $ENV{'ACK_PAGER'} = './test-pager --skip=2';

    test_loader(
        argv             => [],
        expected_opts    => { %defaults, pager => './test-pager --skip=2' },
        expected_targets => [],
        'ACK_PAGER should set the default pager',
    );

    test_loader(
        argv             => ['--pager=./test-pager'],
        expected_opts    => { %defaults, pager => './test-pager' },
        expected_targets => [],
        '--pager should override ACK_PAGER',
    );

    test_loader(
        argv             => ['--nopager'],
        expected_opts    => { %defaults },
        expected_targets => [],
        '--nopager should suppress ACK_PAGER',
    );
};

do {
    local $ENV{'ACK_PAGER_COLOR'} = './test-pager --skip=2';

    test_loader(
        argv             => [],
        expected_opts    => { %defaults, pager => './test-pager --skip=2' },
        expected_targets => [],
        'ACK_PAGER_COLOR should set the default pager',
    );

    test_loader(
        argv             => ['--pager=./test-pager'],
        expected_opts    => { %defaults, pager => './test-pager' },
        expected_targets => [],
        '--pager should override ACK_PAGER_COLOR',
    );

    test_loader(
        argv             => ['--nopager'],
        expected_opts    => { %defaults },
        expected_targets => [],
        '--nopager should suppress ACK_PAGER_COLOR',
    );

    local $ENV{'ACK_PAGER'} = './test-pager --skip=3';

    test_loader(
        argv             => [],
        expected_opts    => { %defaults, pager => './test-pager --skip=2' },
        expected_targets => [],
        'ACK_PAGER_COLOR should override ACK_PAGER',
    );

    test_loader(
        argv             => ['--pager=./test-pager'],
        expected_opts    => { %defaults, pager => './test-pager' },
        expected_targets => [],
        '--pager should override ACK_PAGER_COLOR and ACK_PAGER',
    );

    test_loader(
        argv             => ['--nopager'],
        expected_opts    => { %defaults },
        expected_targets => [],
        '--nopager should suppress ACK_PAGER_COLOR and ACK_PAGER',
    );
};

do {
    local $ENV{'PAGER'} = './test-pager';

    test_loader(
        argv             => [],
        expected_opts    => { %defaults },
        expected_targets => [],
        q{PAGER doesn't affect ack by default},
    );

    test_loader(
        argv             => ['--pager'],
        expected_opts    => { %defaults, pager => './test-pager' },
        expected_targets => [],
        'PAGER is used if --pager is specified with no argument',
    );

    test_loader(
        argv             => ['--pager=./test-pager --skip=2'],
        expected_opts    => { %defaults, pager => './test-pager --skip=2' },
        expected_targets => [],
        'PAGER is not used if --pager is specified with an argument',
    );

    # XXX what if --pager is specified but PAGER isn't set?
};

done_testing;


sub test_loader {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    die 'Must pass key/value pairs, plus a message at the end' unless @_ % 2 == 1;

    my $msg  = pop;
    my %opts = @_;

    return subtest "test_loader( $msg )" => sub {
        plan tests => 2;

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
                { name => 'ARGV', contents => $argv },
                map { +{ name => $_, contents => scalar read_file($_) } } @files,
            );

            $got_opts    = App::Ack::ConfigLoader::process_args( @arg_sources );
            $got_targets = [ @ARGV ];
        };

        is_deeply( $got_opts, $expected_opts, 'Options match' );
        is_deeply( $got_targets, $expected_targets, 'Targets match' );
    };
}
