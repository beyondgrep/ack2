use strict;
use warnings;

use Cwd qw(getcwd);
use File::Temp;
use Test::More tests => 12;
use lib 't';
use Util;

prep_environment();

my $wd = getcwd();

my $tempdir = File::Temp->newdir;

chdir $tempdir->dirname;
write_file '.ackrc', "--frobnicate\n";

my $output;

$output = run_ack( '--env', '--help' );
like $output, qr/Usage: ack/;

{
    local $TODO = '--help-types is painful to work with';

    $output = run_ack( '--env', '--help-types' );
    like $output, qr/Usage: ack/;
}

{
    ($output, my $stderr) = run_ack_with_stderr( '--env', '--man' );
    # Don't worry if man complains about long lines,
    # or if the terminal doesn't handle Unicode:
    is( scalar(grep !/can't\ break\ line
                     |Wide\ character\ in\ print
                     |Unknown\ escape\ E<0x[[:xdigit:]]+>/x, @{$stderr}),
        0,
        "Should have no output to stderr: ack --env --man" )
        or diag( join( "\n", "STDERR:", @{$stderr} ) );

    if (is_win32()) {
        like join("\n", @{$output}[0,1]), qr/^NAME\s+ack(?:-standalone)?\s/;
    } else {
        like $output->[0], qr/ACK(?:-STANDALONE)?\Q(1)\E/;
    }
}

$output = run_ack( '--env', '--thpppt' );
like $output, qr/ack --thpppt/;

$output = run_ack( '--env', '--bar' );
like $output, qr/It's a grep/;

$output = run_ack( '--env', '--version' );
like $output, qr/ack 2[.]\d+/;

chdir $wd;
