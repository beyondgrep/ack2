#!perl -T

use strict;
use warnings;

use File::Next ();
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

my $freedom = File::Next::reslash( 't/text/freedom-of-choice.txt' );
my $fourth  = File::Next::reslash( 't/text/4th-of-july.txt' );
my $science = File::Next::reslash( 't/text/science-of-myth.txt' );

my @expected = split /\n/, <<"EOF";
$freedom:1:A victim of collision on the open sea
$freedom:3:Sink, swim, go down with the ship
$freedom:6:I'll say it again in the land of the free
$freedom:15:He licked the other
$freedom:24:Seems to be the rule of thumb
$freedom:28:I'll say it again in the land of the free
$freedom:41:He licked the other
$fourth:1:Alone with the morning burning red
$fourth:2:On the canvas in my head
$fourth:6:Just the road and its majesty
$fourth:8:With the world in the rear view
$fourth:11:You were pretty as can be, sitting in the front seat
$fourth:13:And you're happy to be with me on the 4th of July
$fourth:14:We sang "Stranglehold" to the stereo
$fourth:19:Get drawn into the sun
$fourth:22:And there you were
$fourth:25:Staking a claim on the world we found
$fourth:28:You were out of the blue to a boy like me
$fourth:33:In the silence that we shared
$science:3:In the case of Christianity and Judaism there exists the belief
$science:6:The Buddhists believe that the functional aspects override the myth
$science:7:While other religions use the literal core to build foundations with
$science:8:See, half the world sees the myth as fact, and it's seen as a lie by the other half
$science:9:And the simple truth is that it's none of that 'cause
$science:10:Somehow no matter what the world keeps turning
$science:14:In fact, for better understanding we take the facts of science and apply them
$science:15:And if both factors keep evolving then we continue getting information
$science:16:But closing off the possibilities makes it hard to see the bigger picture
$science:18:Consider the case of the woman whose faith helped her make it through
$science:22:And if it works, then it gets the job done
$science:23:Somehow no matter what the world keeps turning
EOF

my $perl = caret_X();
my @lhs_args = ( $perl, '-Mblib', build_ack_invocation( '-g', 'of', 't/text' ) );
my @rhs_args = ( $perl, '-Mblib', build_ack_invocation( '-x', 'the' ) ); # for now

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
