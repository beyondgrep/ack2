#!perl -T

use strict;
use warnings;

use Test::More tests => 6;

use lib 't';
use Util;
use File::Next;

prep_environment();

my @text  = map {
    untaint($_)
} glob( 't/text/s*.txt' );

my $myth  = File::Next::reslash( 't/text/science-of-myth.txt' );
my $happy = File::Next::reslash( 't/text/shut-up-be-happy.txt' );

my @expected = split( /\n/, <<"EOF" );
$myth:3:In the case of Christianity and Judaism there exists the belief
$myth:6:The Buddhists believe that the functional aspects override the myth
$myth:7:While other religions use the literal core to build foundations with
$happy:10:Anyone caught outside the gates of their subdivision sector after curfew will be shot.
$happy:12:Your neighborhood watch officer will be by to collect urine samples in the morning.
$happy:13:Anyone gaught intefering with the collection of urine samples will be shot.
EOF

ack_lists_match( [ '-m', 3, '-w', 'the', @text ], \@expected, 'Should show only 3 lines per file' );

@expected = split( /\n/, <<"EOF" );
$myth:3:In the case of Christianity and Judaism there exists the belief
EOF

ack_lists_match( [ '-1', '-w', 'the', @text ], \@expected, 'We should only get one line back for the entire run, not just per file.' );

DASH_L: {
    my $target   = 'the';
    my @files    = File::Next::reslash( 't/text' );
    my @args     = ( '-m', 3, '-l', '--sort-files', $target );
    my @results  = run_ack( @args, @files );
    my @expected = map { File::Next::reslash( "t/text/$_" ) } (
        '4th-of-july.txt', 'boy-named-sue.txt', 'freedom-of-choice.txt'
    );

    is_deeply(\@results, \@expected);
}
