#!perl -T

use strict;
use warnings;

use Test::More tests => 5;

use lib 't';
use Util;

use App::Ack::ConfigLoader;
use Cwd qw( realpath );
use File::Spec ();
use File::Temp ();

sub is_global_file {
    my ( $filename ) = @_;

    return unless -f $filename;

    my ( undef, $dir ) = File::Spec->splitpath($filename);
    $dir = File::Spec->canonpath($dir);

    my (undef, $wd) = File::Spec->splitpath(getcwd_clean(), 1);
    $wd = File::Spec->canonpath($wd);

    return $wd !~ /^\Q$dir\E/;
}

sub remove_defaults_and_globals {
    my ( @sources ) = @_;

    return grep {
        $_->{name} ne 'Defaults' && !is_global_file($_->{name})
    } @sources;
}

prep_environment();

my $wd = getcwd_clean() or die;

my $tempdir = File::Temp->newdir;

chdir $tempdir->dirname or die;

write_file( '.ackrc', <<'ACKRC' );
--type-add=perl:ext:pl,t,pm
ACKRC

subtest 'without --noenv' => sub {
    local @ARGV = ('-f', 'lib/');
    local $ENV{'ACK_OPTIONS'} = '--perl';

    my @sources = App::Ack::ConfigLoader::retrieve_arg_sources();
    @sources    = remove_defaults_and_globals(@sources);

    is_deeply( \@sources, [
        {
            name     => File::Spec->canonpath(realpath(File::Spec->catfile($tempdir->dirname, '.ackrc'))),
            contents => [ '--type-add=perl:ext:pl,t,pm' ],
            project  => 1,
        },
        {
            name     => 'ACK_OPTIONS',
            contents => '--perl',
        },
        {
            name     => 'ARGV',
            contents => ['-f', 'lib/'],
        },
    ], 'Get back a long list of arguments' );
};

subtest 'with --noenv' => sub {
    local @ARGV = ('--noenv', '-f', 'lib/');
    local $ENV{'ACK_OPTIONS'} = '--perl';

    my @sources = App::Ack::ConfigLoader::retrieve_arg_sources();
    @sources    = remove_defaults_and_globals(@sources);

    is_deeply( \@sources, [
        {
            name     => 'ARGV',
            contents => ['-f', 'lib/'],
        },
    ], 'Short list comes back because of --noenv' );
};

NOENV_IN_CONFIG: {
    append_file( '.ackrc', "--noenv\n" );

    local $ENV{'ACK_OPTIONS'} = '--perl';

    my ( $stdout, $stderr ) = run_ack_with_stderr('--env', 'perl');
    is_empty_array( $stdout );
    is( @{$stderr}, 1 );
    like( $stderr->[0], qr/--noenv found in (?:.*)[.]ackrc/ ) or diag(explain($stderr));
}

chdir $wd or die; # Go back to the original directory to avoid warnings
