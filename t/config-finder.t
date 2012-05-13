#!perl

use strict;
use warnings;

use Cwd qw(getcwd realpath);
use File::Spec;
use File::Temp;
use File::Slurp qw( write_file );
use Test::Builder;
use Test::More tests => 21;

use App::Ack::ConfigFinder;


sub touch_ackrc {
    my $filename = shift || '.ackrc';
    write_file( $filename, '' );

    return;
}

sub no_home (&) { ## no critic (ProhibitSubroutinePrototypes)
    my ( $fn ) = @_;

    my $home = delete $ENV{'HOME'}; # localized delete isn't supported in
                                    # earlier perls
    $fn->();
    $ENV{'HOME'} = $home;

    return;
}

my $finder;

sub expect_ackrcs {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $expected = shift;
    my $name     = shift;

    my @got      = map { realpath($_) } $finder->find_config_files;
    @{$expected} = map { realpath($_) } @{$expected};
    is_deeply( \@got, $expected, 'Lines match' ) or diag(explain(\@got));

    return;
}

my @global_files;

if ( $^O eq 'MSWin32') {
    require Win32;

    no strict 'subs';

    @global_files = (
        Win32::GetFolderPath(Win32::CSIDL_COMMON_APPDATA),
        Win32::GetFolderPath(Win32::CSIDL_APPDATA),
    );
}
else {
    @global_files = (
        '/etc/ackrc',
        File::Spec->catfile($ENV{'HOME'}, '.ackrc'),
    );
}

my $wd      = getcwd;
my $tempdir = File::Temp->newdir;
chdir $tempdir->dirname;

$finder = App::Ack::ConfigFinder->new;
expect_ackrcs \@global_files, 'having no project file should return only the top level files';

no_home {
    expect_ackrcs [ $global_files[0] ], 'only system-wide ackrc is returned if HOME is not defined with no project files';
};

mkdir 'foo';
mkdir File::Spec->catdir('foo', 'bar');
mkdir File::Spec->catdir('foo', 'bar', 'baz');

chdir File::Spec->catdir('foo', 'bar', 'baz');

touch_ackrc;
expect_ackrcs [ @global_files, File::Spec->rel2abs('.ackrc')], 'a project file in the same directory should be detected';
no_home {
    expect_ackrcs [ $global_files[0], File::Spec->rel2abs('.ackrc')], 'a project file in the same directory should be detected';
};

unlink '.ackrc';

my $project_file = File::Spec->catfile($tempdir->dirname, 'foo', 'bar', '.ackrc');
touch_ackrc $project_file;
expect_ackrcs [ @global_files, $project_file ], 'a project file in the parent directory should be detected';
no_home {
    expect_ackrcs [ $global_files[0], $project_file ], 'a project file in the parent directory should be detected';
};
unlink $project_file;

$project_file = File::Spec->catfile($tempdir->dirname, 'foo', '.ackrc');
touch_ackrc $project_file;
expect_ackrcs [ @global_files, $project_file ], 'a project file in the grandparent directory should be detected';
no_home {
    expect_ackrcs [ $global_files[0], $project_file ], 'a project file in the grandparent directory should be detected';
};

touch_ackrc;

expect_ackrcs [ @global_files, File::Spec->rel2abs('.ackrc')], 'a project file in the same directory should be detected, even with another one above it';
no_home {
    expect_ackrcs [ $global_files[0], File::Spec->rel2abs('.ackrc')], 'a project file in the same directory should be detected, even with another one above it';
};

unlink '.ackrc';
unlink $project_file;

touch_ackrc '_ackrc';
expect_ackrcs [ @global_files, File::Spec->rel2abs('_ackrc')], 'a project file in the same directory should be detected';
no_home {
    expect_ackrcs [ $global_files[0], File::Spec->rel2abs('_ackrc')], 'a project file in the same directory should be detected';
};

unlink '_ackrc';

$project_file = File::Spec->catfile($tempdir->dirname, 'foo', '_ackrc');
touch_ackrc $project_file;
expect_ackrcs [ @global_files, $project_file ], 'a project file in the grandparent directory should be detected';
no_home {
    expect_ackrcs [ $global_files[0], $project_file ], 'a project file in the grandparent directory should be detected';
};

touch_ackrc '_ackrc';
expect_ackrcs [ @global_files, File::Spec->rel2abs('_ackrc')], 'a project file in the same directory should be detected, even with another one above it';
no_home {
    expect_ackrcs [ $global_files[0], File::Spec->rel2abs('_ackrc')], 'a project file in the same directory should be detected, even with another one above it';
};

unlink $project_file;
touch_ackrc;
expect_ackrcs [ @global_files, File::Spec->rel2abs('.ackrc')], '.ackrc should be preferred to _ackrc';
no_home {
    expect_ackrcs [ $global_files[0], File::Spec->rel2abs('.ackrc')], '.ackrc should be preferred to _ackrc';
};

unlink '.ackrc';
$project_file = File::Spec->catfile($tempdir->dirname, 'foo', '.ackrc');
touch_ackrc $project_file;
expect_ackrcs [ @global_files, File::Spec->rel2abs('_ackrc')], 'a lower-level _ackrc should be preferred to a higher-level .ackrc';
no_home {
    expect_ackrcs [ $global_files[0], File::Spec->rel2abs('_ackrc')], 'a lower-level _ackrc should be preferred to a higher-level .ackrc';
};

unlink '_ackrc';

do {
    local $ENV{'HOME'} = File::Spec->catdir($tempdir->dirname, 'foo');

    my $user_file = File::Spec->catfile($tempdir->dirname, 'foo', '.ackrc');
    touch_ackrc $user_file;

    expect_ackrcs [ $global_files[0], $user_file ], q{don't load the same ackrc file twice};
};

chdir $wd;
