#!perl -T

use strict;
use warnings;

use lib 't';
use Util;

use Cwd qw(realpath);
use File::Spec;
use File::Temp;
use Test::Builder;
use Test::More;

use App::Ack::ConfigFinder;

my $tmpdir = $ENV{'TMPDIR'};
my $home   = $ENV{'HOME'};

for ( $tmpdir, $home ) {
    s{/$}{} if defined;
}

if ( $tmpdir && ($tmpdir =~ /^\Q$home/) ) {
    plan skip_all => "Your \$TMPDIR ($tmpdir) is set to a descendant directory of your home directory.  This test is known to fail with such a setting.  Please set your TMPDIR to something else to get this test to pass.";
    exit;
}

plan tests => 26;

# Set HOME to a known value, so we get predictable results:
$ENV{'HOME'} = realpath('t/home');

# Clear the users ACKRC so it doesn't throw out expect_ackrcs().
delete $ENV{'ACKRC'};

sub touch_ackrc {
    my $filename = shift || '.ackrc';
    write_file( $filename, () );

    return;
}

{
# The tests blow up on Windows if the global files don't exist,
# so here we create them if they don't, keeping track of the ones
# we make so we can delete them later.
my @created_globals;

sub set_up_globals {
    my (@files) = @_;

    foreach my $path (@files) {
        my $filename = $path->{path};
        if ( not -e $filename ) {
            touch_ackrc( $filename );
            push @created_globals, $path;
        }
    }

    return;
}

sub clean_up_globals {
    foreach my $path (@created_globals) {
        my $filename = $path->{path};
        unlink $filename or warn "Couldn't unlink $path";
    }

    return;
}

}
sub no_home (&) { ## no critic (ProhibitSubroutinePrototypes)
    my ( $fn ) = @_;

    my $home = delete $ENV{'HOME'}; # Localized delete isn't supported in earlier Perls.
    $fn->();
    $ENV{'HOME'} = $home; # XXX this won't work on exceptions...

    return;
}

my $finder;

sub expect_ackrcs {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $expected = shift;
    my $name     = shift;

    my @got      = $finder->find_config_files;
    my @expected = @{$expected};

    foreach my $element (@got, @expected) {
        $element->{'path'} = realpath($element->{'path'});
    }
    is_deeply( \@got, \@expected, $name ) or diag(explain(\@got));

    return;
}

my @global_files;

if ( is_windows() ) {
    require Win32;

    @global_files = map { +{ path => File::Spec->catfile($_, 'ackrc') } } (
        Win32::GetFolderPath(Win32::CSIDL_COMMON_APPDATA()),
        Win32::GetFolderPath(Win32::CSIDL_APPDATA()),
    );
}
else {
    @global_files = (
        { path => '/etc/ackrc' },
    );
}

if ( is_windows() || is_cygwin() ) {
    set_up_globals( @global_files );
}

my @std_files = (@global_files, { path => File::Spec->catfile($ENV{'HOME'}, '.ackrc') });

my $wd      = getcwd_clean();
my $tempdir = File::Temp->newdir;
chdir $tempdir->dirname;

$finder = App::Ack::ConfigFinder->new;
expect_ackrcs \@std_files, 'having no project file should return only the top level files';

no_home {
    expect_ackrcs \@global_files, 'only system-wide ackrc is returned if HOME is not defined with no project files';
};

mkdir 'foo';
mkdir File::Spec->catdir('foo', 'bar');
mkdir File::Spec->catdir('foo', 'bar', 'baz');

chdir File::Spec->catdir('foo', 'bar', 'baz');

touch_ackrc( '.ackrc' );
expect_ackrcs [ @std_files, { project => 1, path => File::Spec->rel2abs('.ackrc') }], 'a project file in the same directory should be detected';
no_home {
    expect_ackrcs [ @global_files, { project => 1, path => File::Spec->rel2abs('.ackrc') } ], 'a project file in the same directory should be detected';
};

unlink '.ackrc';

my $project_file = File::Spec->catfile($tempdir->dirname, 'foo', 'bar', '.ackrc');
touch_ackrc( $project_file );
expect_ackrcs [ @std_files, { project => 1, path => $project_file } ], 'a project file in the parent directory should be detected';
no_home {
    expect_ackrcs [ @global_files, { project => 1, path => $project_file } ], 'a project file in the parent directory should be detected';
};
unlink $project_file;

$project_file = File::Spec->catfile($tempdir->dirname, 'foo', '.ackrc');
touch_ackrc( $project_file );
expect_ackrcs [ @std_files, { project => 1, path => $project_file } ], 'a project file in the grandparent directory should be detected';
no_home {
    expect_ackrcs [ @global_files, { project => 1, path => $project_file } ], 'a project file in the grandparent directory should be detected';
};

touch_ackrc( '.ackrc' );

expect_ackrcs [ @std_files, { project => 1, path => File::Spec->rel2abs('.ackrc') } ], 'a project file in the same directory should be detected, even with another one above it';
no_home {
    expect_ackrcs [ @global_files, { project => 1, path => File::Spec->rel2abs('.ackrc') } ], 'a project file in the same directory should be detected, even with another one above it';
};

unlink '.ackrc';
unlink $project_file;

touch_ackrc( '_ackrc' );
expect_ackrcs [ @std_files, { project => 1, path => File::Spec->rel2abs('_ackrc') } ], 'a project file in the same directory should be detected';
no_home {
    expect_ackrcs [ @global_files, { project => 1, path => File::Spec->rel2abs('_ackrc') } ], 'a project file in the same directory should be detected';
};

unlink '_ackrc';

$project_file = File::Spec->catfile($tempdir->dirname, 'foo', '_ackrc');
touch_ackrc( $project_file );
expect_ackrcs [ @std_files, { project => 1, path => $project_file } ], 'a project file in the grandparent directory should be detected';
no_home {
    expect_ackrcs [ @global_files, { project => 1, path => $project_file } ], 'a project file in the grandparent directory should be detected';
};

touch_ackrc( '_ackrc' );
expect_ackrcs [ @std_files, { project => 1, path => File::Spec->rel2abs('_ackrc') } ], 'a project file in the same directory should be detected, even with another one above it';
no_home {
    expect_ackrcs [ @global_files, { project => 1, path => File::Spec->rel2abs('_ackrc') } ], 'a project file in the same directory should be detected, even with another one above it';
};

unlink $project_file;
touch_ackrc( '.ackrc' );
my $ok = eval { $finder->find_config_files };
my $err = $@;
ok( !$ok, '.ackrc + _ackrc is error' );
like( $err, qr/contains both \.ackrc and _ackrc/, 'Got the expected error' );

no_home {
    $ok = eval { $finder->find_config_files };
    $err = $@;
    ok( !$ok, '.ackrc + _ackrc is error' );
    like( $err, qr/contains both \.ackrc and _ackrc/, 'Got the expected error' );
};

unlink '.ackrc';
$project_file = File::Spec->catfile($tempdir->dirname, 'foo', '.ackrc');
touch_ackrc( $project_file );
expect_ackrcs [ @std_files, { project => 1, path => File::Spec->rel2abs('_ackrc') }], 'a lower-level _ackrc should be preferred to a higher-level .ackrc';
no_home {
    expect_ackrcs [ @global_files, { project => 1, path => File::Spec->rel2abs('_ackrc') } ], 'a lower-level _ackrc should be preferred to a higher-level .ackrc';
};

unlink '_ackrc';

do {
    local $ENV{'HOME'} = File::Spec->catdir($tempdir->dirname, 'foo');

    my $user_file = File::Spec->catfile($tempdir->dirname, 'foo', '.ackrc');
    touch_ackrc( $user_file );

    expect_ackrcs [ @global_files, { path => $user_file } ], q{don't load the same ackrc file twice};
    unlink($user_file);
};

do {
    chdir $tempdir->dirname;
    local $ENV{'HOME'} = File::Spec->catfile($tempdir->dirname, 'foo');

    my $user_file = File::Spec->catfile($ENV{'HOME'}, '.ackrc');
    touch_ackrc( $user_file );

    my $ackrc = File::Temp->new;
    close $ackrc;
    local $ENV{'ACKRC'} = $ackrc->filename;

    expect_ackrcs [ @global_files, { path => $ackrc->filename } ], q{ACKRC overrides user's HOME ackrc};
    unlink $ackrc->filename;

    expect_ackrcs [ @global_files, { path => $user_file } ], q{ACKRC doesn't override if it doesn't exist};

    touch_ackrc( $ackrc->filename );
    chdir 'foo';
    expect_ackrcs [ @global_files, { path => $ackrc->filename}, { project => 1, path => $user_file } ], q{~/.ackrc should still be found as a project ackrc};
    unlink $ackrc->filename;
};

chdir $wd;
clean_up_globals();
