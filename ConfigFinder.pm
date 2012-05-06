package App::Ack::ConfigFinder;

=head1 App::Ack::ConfigFinder

=head1 LOCATING CONFIG FILES

First, ack looks for a global ackrc.

=over

=item On Windows, this is `ackrc` in either COMMON_APPDATA or APPDATA.

=item On a non-Windows OS, this is `/etc/ackrc`.

=back

Then, ack looks for a user-specific ackrc.

=over

=item On Windows, this is `$HOME/_ackrc`, if the HOME environment variable is set.

=item On non-Windows systems, this is `$HOME/.ackrc`.

=back

Then, ack looks for a project-specific ackrc file.  ack searches
up the directory hierarchy for the first .ackrc or _ackrc file this is not
one of the ackrc files found in the previous steps.

After ack loads the options from the found ackrc files, ack looks
at the ACKRC_OPTIONS environment variable.

Finally, ack takes settings from the command line.

=cut

use strict;
use warnings;

use App::Ack ();
use Cwd ();
use File::Spec;

BEGIN {
    if($App::Ack::is_windows) {
        require Win32;
    };
}

=head1 METHODS

=head2 new

Creates a new config finder.

=cut

sub new {
    my ( $class ) = @_;

    return bless {}, $class;
}

sub _remove_redundancies {
    my ( @configs ) = @_;

    my %dev_and_inode_seen;

    foreach my $path ( @configs ) {
        my ( $dev, $inode ) = (stat $path)[0, 1];

        if( defined( $dev ) ) { # files that can't be read don't matter
            if( $dev_and_inode_seen{"$dev:$inode"} ) {
                undef $path;
            } else {
                $dev_and_inode_seen{"$dev:$inode"} = 1;
            }
        }
    }
    return grep { defined() } @configs;
}

=head2 $finder->find_config_files

Locates config files, and returns
a list of them.

=cut

sub find_config_files {
    my @config_files;

    if($App::Ack::is_windows) {
        no strict 'subs';
        push @config_files, map { File::Spec->catfile($_, 'ackrc') } (
            Win32::GetFolderPath(Win32::CSIDL_COMMON_APPDATA),
            Win32::GetFolderPath(Win32::CSIDL_APPDATA),
        );
        if(defined(my $home = $ENV{'HOME'})) {
            push @config_files, File::Spec->catfile($home, '_ackrc');
        }
    } else {
        push @config_files, '/etc/ackrc';
        if(defined(my $home = $ENV{'HOME'})) {
            push @config_files, File::Spec->catfile($home, '.ackrc');
        }
    }

    my @dirs = File::Spec->splitdir(Cwd::getcwd());
    while(@dirs) {
        my $ackrc = File::Spec->catfile(@dirs, '.ackrc');
        if(-f $ackrc) {
            push @config_files, $ackrc;
            last;
        }
        $ackrc = File::Spec->catfile(@dirs, '_ackrc');
        if(-f $ackrc) {
            push @config_files, $ackrc;
            last;
        }
        pop @dirs;
    }

    return _remove_redundancies( @config_files );
}

1;
