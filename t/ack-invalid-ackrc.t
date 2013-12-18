#!perl -T

use strict;
use warnings;

use File::Temp;
use List::Util qw(sum);
use Test::More;
use lib 't';
use Util;

plan skip_all => q{Don't yet have a reliable way to ignore the Unicode complaints from Pod::Perldoc};

my @types = (
    perl   => [qw{.pl .pod .pl .t}],
    python => [qw{.py}],
    ruby   => [qw{.rb Rakefile}],
);

plan tests => sum(map { ref($_) ? scalar(@$_) : 1 } @types) + 14;

prep_environment();

my $wd = getcwd_clean();

my $tempdir = File::Temp->newdir;

chdir $tempdir->dirname;
write_file '.ackrc', "--frobnicate\n";

my $output;

$output = run_ack( '--env', '--help' );
like $output, qr/Usage: ack/;

{
    my $stderr;

    ( $output, $stderr ) = run_ack_with_stderr( '--env', '--help-types' );
    like join("\n", @{$output}), qr/Usage: ack/;

    $stderr = join("\n", @{$stderr});
    like $stderr, qr/Unknown option: frobnicate/;

    # the following was shamelessly copied from ack-help-types.t
    for (my $i = 0; $i < @types; $i += 2) {
        my ( $type, $checks ) = @types[ $i , $i + 1 ];

        my ( $matching_line ) = grep { /--\[no\]$type/ } @{$output};

        ok $matching_line;

        foreach my $check (@{$checks}) {
            like $matching_line, qr/\Q$check\E/;
        }
    }
}

{
    ($output, my $stderr) = run_ack_with_stderr( '--env', '--man' );
    # Don't worry if man complains about long lines,
    # or if the terminal doesn't handle Unicode:
    is( scalar(grep !m{can't\ break\ line
                     |Wide\ character\ in\ print
                     |Unknown\ escape\ E<0x[[:xdigit:]]+>}x, @{$stderr}),
        0,
        'Should have no output to stderr: ack --env --man' )
        or diag( join( "\n", 'STDERR:', @{$stderr} ) );

    if ( is_windows() ) {
        like( join("\n", @{$output}[0,1]), qr/^NAME\s+ack(?:-standalone)?\s/ );
    }
    else {
        like( $output->[0], qr/ACK(?:-STANDALONE)?\Q(1)\E/ );
    }
}

$output = run_ack( '--env', '--thpppt' );
like( $output, qr/ack --thpppt/ );

$output = run_ack( '--env', '--bar' );
like( $output, qr/It's a grep/ );

$output = run_ack( '--env', '--cathy' );
like $output, qr/CHOCOLATE/;

$output = run_ack( '--env', '--version' );
like $output, qr/ack 2[.]\d+/;

chdir $wd;
