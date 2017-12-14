#!perl -T

use strict;
use warnings;

use Test::More tests => 2;

use lib 't';
use Util;

sub do_parent {
    my %params = @_;

    my ( $stdout_read, $stderr_read, $stdout_lines, $stderr_lines ) =
        @params{qw/stdout_read stderr_read stdout_lines stderr_lines/};

    while ( $stdout_read || $stderr_read ) {
        my $rin = '';

        vec( $rin, fileno($stdout_read), 1 ) = 1 if $stdout_read;
        vec( $rin, fileno($stderr_read), 1 ) = 1 if $stderr_read;

        select( $rin, undef, undef, undef );

        if ( $stdout_read && vec( $rin, fileno($stdout_read), 1 ) ) {
            my $line = <$stdout_read>;

            if ( defined( $line ) ) {
                push @{$stdout_lines}, $line;
            }
            else {
                close $stdout_read;
                undef $stdout_read;
            }
        }

        if ( $stderr_read && vec( $rin, fileno($stderr_read), 1 ) ) {
            my $line = <$stderr_read>;

            if ( defined( $line ) ) {
                push @{$stderr_lines}, $line;
            }
            else {
                close $stderr_read;
                undef $stderr_read;
            }
        }
    }

    chomp @{$stdout_lines};
    chomp @{$stderr_lines};

    return;
}

prep_environment();

my $ozy__ = reslash( 't/text/ozymandias.txt' );
my $raven = reslash( 't/text/raven.txt' );

my @expected = line_split( <<"HERE" );
$ozy__:6:Tell that its sculptor well those passions read
$ozy__:8:The hand that mocked them, and the heart that fed:
$ozy__:13:Of that colossal wreck, boundless and bare
$raven:17:So that now, to still the beating of my heart, I stood repeating
$raven:26:That I scarce was sure I heard you" -- here I opened wide the door: --
$raven:29:Deep into that darkness peering, long I stood there wondering, fearing,
$raven:38:"Surely," said I, "surely that is something at my window lattice;
$raven:59:For we cannot help agreeing that no living human being
$raven:65:That one word, as if his soul in that one word he did outpour.
$raven:75:Till the dirges of his Hope that melancholy burden bore
$raven:88:On the cushion's velvet lining that the lamplight gloated o'er,
$raven:107:By that Heaven that bends above us, by that God we both adore,
$raven:113:"Be that word our sign of parting, bird or fiend!" I shrieked, upstarting:
$raven:115:Leave no black plume as a token of that lie thy soul hath spoken!
$raven:122:And his eyes have all the seeming of a demon's that is dreaming,
$raven:124:And my soul from out that shadow that lies floating on the floor
HERE

my $perl = caret_X();
my @lhs_args = ( $perl, '-Mblib', build_ack_invocation( '--sort-files', '-g', '[vz]', 't/text' ) );
my @rhs_args = ( $perl, '-Mblib', build_ack_invocation( '-x', '-i', 'that' ) );

if ( $ENV{'ACK_TEST_STANDALONE'} ) {
    @lhs_args = grep { $_ ne '-Mblib' } @lhs_args;
    @rhs_args = grep { $_ ne '-Mblib' } @rhs_args;
}

my ($stdout, $stderr);

if ( is_windows() ) {
    ($stdout, $stderr) = run_cmd("@lhs_args | @rhs_args");
}
else {
    my ( $stdout_read, $stdout_write );
    my ( $stderr_read, $stderr_write );
    my ( $lhs_rhs_read, $lhs_rhs_write );

    pipe( $stdout_read, $stdout_write );
    pipe( $stderr_read, $stderr_write );
    pipe( $lhs_rhs_read, $lhs_rhs_write );

    my $lhs_pid;
    my $rhs_pid;

    $lhs_pid = fork();

    if ( !defined($lhs_pid) ) {
        die 'Unable to fork';
    }

    if ( $lhs_pid ) {
        $rhs_pid = fork();

        if ( !defined($rhs_pid) ) {
            kill TERM => $lhs_pid;
            waitpid $lhs_pid, 0;
            die 'Unable to fork';
        }
    }

    if ( $rhs_pid ) { # parent
        close $stdout_write;
        close $stderr_write;
        close $lhs_rhs_write;
        close $lhs_rhs_read;

        do_parent(
            stdout_read  => $stdout_read,
            stderr_read  => $stderr_read,
            stdout_lines => ($stdout = []),
            stderr_lines => ($stderr = []),
        );

        waitpid $lhs_pid, 0;
        waitpid $rhs_pid, 0;
    }
    elsif ( $lhs_pid ) { # right-hand-side child
        close $stdout_read;
        close $stderr_read;
        close $stderr_write;
        close $lhs_rhs_write;

        open STDIN, '<&', $lhs_rhs_read or die "Can't open: $!";
        open STDOUT, '>&', $stdout_write or die "Can't open: $!";
        close STDERR;

        exec @rhs_args;
    }
    else { # left-hand side child
        close $stdout_read;
        close $stdout_write;
        close $lhs_rhs_read;
        close $stderr_read;

        open STDOUT, '>&', $lhs_rhs_write or die "Can't open: $!";
        open STDERR, '>&', $stderr_write or die "Can't open: $!";
        close STDIN;

        exec @lhs_args;
    }
}

sets_match( $stdout, \@expected, __FILE__ );
is_empty_array( $stderr );
