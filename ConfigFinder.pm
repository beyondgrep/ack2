package App::Ack::ConfigFinder;

=head1 App::Ack::ConfigFinder

=cut

use strict;
use warnings;

use App::Ack ();
use Cwd ();
use File::Spec;

if($App::Ack::is_windows) {
    require Win32;
};

=head1 METHODS

=head2 new

Creates a new config finder.

=cut

sub new {
    my ( $class ) = @_;

    return bless {}, $class;
}

=head2 $finder->find_config_files

Locates config files, and returns
a list of them.

=cut

sub find_config_files {
    my @config_files;

    if($App::Ack::is_windows) {
        no strict 'subs';
        push @config_files, (
            Win32::GetFolderPath(Win32::CSIDL_COMMON_APPDATA),
            Win32::GetFolderPath(Win32::CSIDL_APPDATA),
        );
    } else {
        push @config_files, '/etc/ackrc' unless $App::Ack::is_windows;
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
        pop @dirs;
    }

    return @config_files;
}

1;
