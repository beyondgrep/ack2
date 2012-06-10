#!perl

use strict;
use warnings;

use Test::More tests => 5;

use lib 't';
use Util;

use App::Ack;
use Cwd qw( realpath getcwd );
use File::Spec ();
use File::Temp ();

prep_environment();

my $wd = getcwd() or die;

my $tempdir = File::Temp->newdir;

chdir $tempdir->dirname or die;

write_file( '.ackrc', <<'ACKRC' );
--type-add=perl,ext,pl,t,pm
ACKRC

subtest 'without --noenv' => sub {
    local @ARGV = ('-f', 'lib/');
    local $ENV{'ACK_OPTIONS'} = '--perl';

    my @sources = App::Ack::retrieve_arg_sources();

    is_deeply( [ realpath($sources[-6]), @sources[-5..-1] ], [
        realpath(File::Spec->catfile($tempdir->dirname, '.ackrc')),
        [ '--type-add=perl,ext,pl,t,pm' ],
        'ACK_OPTIONS',
        '--perl',
        'ARGV',
        ['-f', 'lib/'],
    ], 'Get back a long list of arguments' );
};

subtest 'with --noenv' => sub {
    local @ARGV = ('--noenv', '-f', 'lib/');
    local $ENV{'ACK_OPTIONS'} = '--perl';

    my @sources = App::Ack::retrieve_arg_sources();

    is_deeply( \@sources, [
        'ARGV',
        ['-f', 'lib/'],
    ], 'Short list comes back because of --noenv' );
};

NOENV_IN_CONFIG: {
    append_file( '.ackrc', "--noenv\n" );

    local $ENV{'ACK_OPTIONS'} = '--perl';

    my ( $stdout, $stderr ) = run_ack_with_stderr('--env', 'perl');
    is @$stdout, 0;
    is @$stderr, 1;
    like $stderr->[0], qr/--noenv found in (?:.*)[.]ackrc/ or diag(explain($stderr));
}

chdir $wd or die; # Go back to the original directory to avoid warnings
