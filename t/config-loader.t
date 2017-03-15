#!perl -T

use strict;
use warnings;
use lib 't';
use Util;

use Test::More tests => 37;

use Carp qw(croak);
use File::Temp;

use App::Ack::Filter::Default;
use App::Ack::ConfigLoader;

delete @ENV{qw( PAGER ACK_PAGER ACK_PAGER_COLOR ACK_OPTIONS )};

my %defaults = (
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

# --after_context, --before_context
for my $option ( qw( after_context before_context ) ) {
    my $long_arg = $option;
    $long_arg =~ s/_/-/ or die;

    test_loader(
        argv             => [ "--$long_arg=15" ],
        expected_opts    => { %defaults, $option => 15 },
        expected_targets => [],
        "--$long_arg=15 should set $option to 15",
    );

    test_loader(
        argv             => [ "--$long_arg=0" ],
        expected_opts    => { %defaults, $option => 0 },
        expected_targets => [],
        "--$long_arg=0 should set $option to 0",
    );

    test_loader(
        argv             => [ "--$long_arg" ],
        expected_opts    => { %defaults, $option => 2 },
        expected_targets => [],
        "--$long_arg without a value should default $option to 2",
    );

    test_loader(
        argv             => [ "--$long_arg=-43" ],
        expected_opts    => { %defaults, $option => 2 },
        expected_targets => [],
        "--$long_arg with a negative value should default $option to 2",
    );

    my $short_arg = '-' . uc substr( $option, 0, 1 );
    test_loader(
        argv             => [ $short_arg, 15 ],
        expected_opts    => { %defaults, $option => 15 },
        expected_targets => [],
        "$short_arg 15 should set $option to 15",
    );

    test_loader(
        argv             => [ $short_arg, 0 ],
        expected_opts    => { %defaults, $option => 0 },
        expected_targets => [],
        "$short_arg 0 should set $option to 0",
    );

    test_loader(
        argv             => [ $short_arg ],
        expected_opts    => { %defaults, $option => 2 },
        expected_targets => [],
        "$short_arg without a value should default $option to 2",
    );

    test_loader(
        argv             => [ $short_arg, '-43' ],
        expected_opts    => { %defaults, $option => 2 },
        expected_targets => [],
        "$short_arg with a negative value should default $option to 2",
    );
}

test_loader(
    argv             => ['-C', 5],
    expected_opts    => { %defaults, after_context => 5, before_context => 5 },
    expected_targets => [],
    '-C sets both before_context and after_context'
);

test_loader(
    argv             => ['-C'],
    expected_opts    => { %defaults, after_context => 2, before_context => 2 },
    expected_targets => [],
    '-C sets both before_context and after_context, with default'
);

test_loader(
    argv             => ['-C', 0],
    expected_opts    => { %defaults, after_context => 0, before_context => 0 },
    expected_targets => [],
    '-C sets both before_context and after_context, with zero overriding default'
);

test_loader(
    argv             => ['-C', -43],
    expected_opts    => { %defaults, after_context => 2, before_context => 2 },
    expected_targets => [],
    '-C with invalid value sets both before_context and after_context to default'
);

test_loader(
    argv             => ['--context=5'],
    expected_opts    => { %defaults, after_context => 5, before_context => 5 },
    expected_targets => [],
    '--context sets both before_context and after_context'
);

test_loader(
    argv             => ['--context'],
    expected_opts    => { %defaults, after_context => 2, before_context => 2 },
    expected_targets => [],
    '--context sets both before_context and after_context, with default'
);

test_loader(
    argv             => ['--context=0'],
    expected_opts    => { %defaults, after_context => 0, before_context => 0 },
    expected_targets => [],
    '--context sets both before_context and after_context, with zero overriding default'
);

test_loader(
    argv             => ['--context=-43'],
    expected_opts    => { %defaults, after_context => 2, before_context => 2 },
    expected_targets => [],
    '--context with invalid value sets both before_context and after_context to default'
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
