package App::Ack::ConfigLoader;

use strict;
use warnings;

use Carp ();
use Getopt::Long ();

=head1 App::Ack::ConfigLoader

=head1 FUNCTIONS

=head2 process_args( @sources )



=cut

sub process_filetypes {
    Getopt::Long::Configure('default'); # start with default options
    Getopt::Long::Configure(
        'no_ignore_case',
        'no_auto_abbrev',
        'pass_through',
    );
    my @types;

    my %type_arg_specs = (
        'type-add=s' => sub { shift; push @types, shift; },
        'type-set=s' => sub { shift; push @types, shift; },
    );
}

sub process_other {
    my @arg_sources = @_;

    Getopt::Long::Configure('default'); # start with default options
    Getopt::Long::Configure(
        'no_ignore_case',
        'no_auto_abbrev',
    );

    my @idirs;
    my @ifiles;

    my %opt;
    my %arg_specs = (
        1                   => sub { $opt{1} = $opt{m} = 1 },
        'A|after-context=i' => \$opt{after_context},
        'B|before-context=i'
                            => \$opt{before_context},
        'C|context:i'       => sub { shift; my $val = shift; $opt{before_context} = $opt{after_context} = ($val || 2) },
        'a|all-types'       => \$opt{all},
        'break!'            => \$opt{break},
        c                   => \$opt{count},
        'color|colour!'     => \$opt{color},
        'color-match=s'     => \$ENV{ACK_COLOR_MATCH},
        'color-filename=s'  => \$ENV{ACK_COLOR_FILENAME},
        'color-lineno=s'    => \$ENV{ACK_COLOR_LINENO},
        'column!'           => \$opt{column},
        count               => \$opt{count},
        'env!'              => sub { }, # ignore this option, it is handled beforehand
        f                   => \$opt{f},
        'filter!'           => \$App::Ack::is_filter_mode,
        flush               => \$opt{flush},
        'follow!'           => \$opt{follow},
        'g=s'               => sub { shift; $opt{G} = shift; $opt{f} = 1 },
        'G=s'               => \$opt{G},
        'group!'            => sub { shift; $opt{heading} = $opt{break} = shift },
        'heading!'          => \$opt{heading},
        'h|no-filename'     => \$opt{h},
        'H|with-filename'   => \$opt{H},
        'i|ignore-case'     => \$opt{i},
        'ignore-directory|ignore-dir=s'
                            => sub { shift; push @idirs,  shift; },
        'ignore-file=s'     => sub { shift; push @ifiles, shift; },
        'invert-file-match' => \$opt{invert_file_match},
        'lines=s'           => sub { shift; my $val = shift; push @{$opt{lines}}, $val },
        'l|files-with-matches'
                            => \$opt{l},
        'L|files-without-matches'
                            => sub { $opt{l} = $opt{v} = 1 },
        'm|max-count=i'     => \$opt{m},
        'match=s'           => \$opt{regex},
        'n|no-recurse'      => \$opt{n},
        o                   => sub { $opt{output} = '$&' },
        'output=s'          => \$opt{output},
        'pager=s'           => \$opt{pager},
        'nopager'           => sub { $opt{pager} = undef },
        'passthru'          => \$opt{passthru},
        'print0'            => \$opt{print0},
        'Q|literal'         => \$opt{Q},
        'r|R|recurse'       => sub { $opt{n} = 0 },
        'show-types'        => \$opt{show_types},
        'smart-case!'       => \$opt{smart_case},
        'sort-files'        => \$opt{sort_files},
        'u|unrestricted'    => \$opt{u},
        'v|invert-match'    => \$opt{v},
        'w|word-regexp'     => \$opt{w},

        'version'           => sub { App::Ack::print_version_statement(); exit; },
        'help|?:s'          => sub { shift; App::Ack::show_help(@_); exit; },
        'help-types'        => sub { App::Ack::show_help_types(); exit; },
        'man'               => sub {
            require Pod::Usage;
            Pod::Usage::pod2usage({
                -verbose => 2,
                -exitval => 0,
            });
        }, # man sub
    ); # arg_specs

    # XXX Have to update arg_specs based on new types
    my @leftovers = @arg_sources;
    while ( @leftovers ) {
        my ($source_name, $args) = splice( @leftovers, 0, 2 );

        my $ret;
        if ( ref($args) ) {
            $ret = Getopt::Long::GetOptionsFromArray( $args, %arg_specs );
        }
        else {
            $ret = Getopt::Long::GetOptionsFromString( $args, %arg_specs );
        }
        if ( !$ret ) {
            my $where = $source_name eq 'ARGV' ? 'on command line' : "in $source_name";
            App::Ack::die( "Invalid option $where" );
        }
    }

    # XXX
    # At this point, none of the sources should have unparsed args except for @ARGV.
    # If any sources other than @ARGV have stuff in them, then throw an error.
    # Otherwise, put what's left from @ARGV source into @ARGV.
    # Also we need to check on a -- in the middle of a non-ARGV source

    return \%opt;
}

sub process_args {
    return process_other(@_);
}

1;
