package App::Ack::ConfigLoader;

use strict;
use warnings;

use App::Ack ();
use App::Ack::ConfigDefault ();
use App::Ack::ConfigFinder ();
use App::Ack::Filter;
use App::Ack::Filter::Default;
use Carp 1.04 ();
use Getopt::Long 2.35 ();
use Text::ParseWords 3.1 ();

=head1 FUNCTIONS

=head2 process_args( @sources )

=cut

my @INVALID_COMBINATIONS;

BEGIN {
    my @context  = qw( -A -B -C --after-context --before-context --context );
    my @pretty   = qw( --heading --group --break );
    my @filename = qw( -h -H --with-filename --no-filename );

    @INVALID_COMBINATIONS = (
        # XXX normalize
        [qw(-l)]                 => [@context, @pretty, @filename, qw(-L -o --passthru --output --max-count --column -f -g --show-types)],
        [qw(-L)]                 => [@context, @pretty, @filename, qw(-l -o --passthru --output --max-count --column -f -g --show-types -c --count)],
        [qw(--line)]             => [@context, @pretty, @filename, qw(-l --files-with-matches --files-without-matches -L -o --passthru --match -m --max-count -1 -c --count --column --print0 -f -g --show-types)],
        [qw(-o)]                 => [@context, qw(--output -c --count --column --column -f --show-types)],
        [qw(--passthru)]         => [@context, qw(--output --column -m --max-count -1 -c --count -f -g)],
        [qw(--output)]           => [@context, qw(-c --count -f -g)],
        [qw(--match)]            => [qw(-f -g)],
        [qw(-m --max-count)]     => [qw(-1 -f -g -c --count)],
        [qw(-h --no-filename)]   => [qw(-H --with-filename -f -g --group --heading)],
        [qw(-H --with-filename)] => [qw(-h --no-filename -f -g)],
        [qw(-c --count)]         => [@context, @pretty, qw(--column -f -g)],
        [qw(--column)]           => [qw(-f -g)],
        [@context]               => [qw(-f -g)],
        [qw(-f)]                 => [qw(-g), @pretty],
        [qw(-g)]                 => [qw(-f), @pretty],
    );
}


sub process_filter_spec {
    my ( $spec ) = @_;

    if ( $spec =~ /^(\w+):(\w+):(.*)/ ) {
        my ( $type_name, $ext_type, $arguments ) = ( $1, $2, $3 );

        return ( $type_name,
            App::Ack::Filter->create_filter($ext_type, split(/,/, $arguments)) );
    }
    elsif ( $spec =~ /^(\w+)=(.*)/ ) { # Check to see if we have ack1-style argument specification.
        my ( $type_name, $extensions ) = ( $1, $2 );

        my @extensions = split(/,/, $extensions);
        foreach my $extension ( @extensions ) {
            $extension =~ s/^[.]//;
        }

        return ( $type_name, App::Ack::Filter->create_filter('ext', @extensions) );
    }
    else {
        Carp::croak "invalid filter specification '$spec'";
    }
}


sub uninvert_filter {
    my ( $opt, @filters ) = @_;

    return unless defined $opt->{filters} && @filters;

    # Loop through all the registered filters.  If we hit one that
    # matches this extension and it's inverted, we need to delete it from
    # the options.
    for ( my $i = 0; $i < @{ $opt->{filters} }; $i++ ) {
        my $opt_filter = @{ $opt->{filters} }[$i];

        # XXX Do a real list comparison? This just checks string equivalence.
        if ( $opt_filter->is_inverted() && "$opt_filter->{filter}" eq "@filters" ) {
            splice @{ $opt->{filters} }, $i, 1;
            $i--;
        }
    }
}


sub process_filetypes {
    my ( $opt, $arg_sources ) = @_;

    Getopt::Long::Configure('default', 'no_auto_help', 'no_auto_version'); # start with default options, minus some annoying ones
    Getopt::Long::Configure(
        'no_ignore_case',
        'no_auto_abbrev',
        'pass_through',
    );
    my %additional_specs;

    my $add_spec = sub {
        my ( undef, $spec ) = @_;

        my ( $name, $filter ) = process_filter_spec($spec);

        push @{ $App::Ack::mappings{$name} }, $filter;

        $additional_specs{$name . '!'} = sub {
            my ( undef, $value ) = @_;

            my @filters = @{ $App::Ack::mappings{$name} };
            if ( not $value ) {
                @filters = map { $_->invert() } @filters;
            }
            else {
                uninvert_filter( $opt, @filters );
            }

            push @{ $opt->{'filters'} }, @filters;
        };
    };

    my $set_spec = sub {
        my ( undef, $spec ) = @_;

        my ( $name, $filter ) = process_filter_spec($spec);

        $App::Ack::mappings{$name} = [ $filter ];

        $additional_specs{$name . '!'} = sub {
            my ( undef, $value ) = @_;

            my @filters = @{ $App::Ack::mappings{$name} };
            if ( not $value ) {
                @filters = map { $_->invert() } @filters;
            }

            push @{ $opt->{'filters'} }, @filters;
        };
    };

    my $delete_spec = sub {
        my ( undef, $name ) = @_;

        delete $App::Ack::mappings{$name};
        delete $additional_specs{$name . '!'};
    };

    my %type_arg_specs = (
        'type-add=s' => $add_spec,
        'type-set=s' => $set_spec,
        'type-del=s' => $delete_spec,
    );

    foreach my $source (@{$arg_sources}) {
        my ( $source_name, $args ) = @{$source}{qw/name contents/};

        if ( ref($args) ) {
            # $args are modified in place, so no need to munge $arg_sources
            local @ARGV = @{$args};
            Getopt::Long::GetOptions(%type_arg_specs);
            @{$args} = @ARGV;
        }
        else {
            ( undef, $source->{contents} ) =
                Getopt::Long::GetOptionsFromString($args, %type_arg_specs);
        }
    }

    $additional_specs{'k|known-types'} = sub {
        my ( undef, $value ) = @_;

        my @filters = map { @{$_} } values(%App::Ack::mappings);

        push @{ $opt->{'filters'} }, @filters;
    };

    return \%additional_specs;
}


sub removed_option {
    my ( $option, $explanation ) = @_;

    $explanation ||= '';
    return sub {
        warn "Option '$option' is not valid in ack 2\n$explanation";
        exit 1;
    };
}


sub get_arg_spec {
    my ( $opt, $extra_specs ) = @_;

    my $dash_a_explanation = <<'EOT';
This is because we now have -k/--known-types which makes it only select files
of known types, rather than any text file (which is the behavior of ack 1.x).
You may have options in a .ackrc, or in the ACKRC_OPTIONS environment variable.
Try using the --dump flag.
EOT

=for Adding-Options

    *** IF YOU ARE MODIFYING ACK PLEASE READ THIS ***

    If you plan to add a new option to ack, please make sure of
    the following:

    * Your new option has a test underneath the t/ directory.
    * Your new option is explained when a user invokes ack --help.
      (See App::Ack::show_help)
    * Your new option is explained when a user invokes ack --man.
      (See the POD at the end of ./ack)
    * Add your option to t/config-loader.t
    * Add your option to t/Util.pm#get_options
    * Add your option's description and aliases to dev/generate-completion-scripts.pl
    * Go through the list of options already available, and consider
      whether your new option can be considered mutually exclusive
      with another option.

=cut

    return {
        1                   => sub { $opt->{1} = $opt->{m} = 1 },
        'A|after-context=i' => \$opt->{after_context},
        'B|before-context=i'
                            => \$opt->{before_context},
        'C|context:i'       => sub { shift; my $val = shift; $opt->{before_context} = $opt->{after_context} = ($val || 2) },
        'a'                 => removed_option('-a', $dash_a_explanation),
        'all'               => removed_option('--all', $dash_a_explanation),
        'break!'            => \$opt->{break},
        c                   => \$opt->{count},
        'color|colour!'     => \$opt->{color},
        'color-match=s'     => \$ENV{ACK_COLOR_MATCH},
        'color-filename=s'  => \$ENV{ACK_COLOR_FILENAME},
        'color-lineno=s'    => \$ENV{ACK_COLOR_LINENO},
        'column!'           => \$opt->{column},
        count               => \$opt->{count},
        'create-ackrc'      => sub { print "$_\n" for ( '--ignore-ack-defaults', App::Ack::ConfigDefault::options() ); exit; },
        'env!'              => sub {
            my ( undef, $value ) = @_;

            if ( !$value ) {
                $opt->{noenv_seen} = 1;
            }
        },
        f                   => \$opt->{f},
        'files-from=s'      => \$opt->{files_from},
        'filter!'           => \$App::Ack::is_filter_mode,
        flush               => \$opt->{flush},
        'follow!'           => \$opt->{follow},
        g                   => \$opt->{g},
        G                   => removed_option('-G'),
        'group!'            => sub { shift; $opt->{heading} = $opt->{break} = shift },
        'heading!'          => \$opt->{heading},
        'h|no-filename'     => \$opt->{h},
        'H|with-filename'   => \$opt->{H},
        'i|ignore-case'     => \$opt->{i},
        'ignore-directory|ignore-dir=s' => sub {
                                    my ( undef, $dir ) = @_;

                                    $dir = App::Ack::remove_dir_sep( $dir );
                                    if ( $dir !~ /^(?:is|match):/ ) {
                                        $dir = 'is:' . $dir;
                                    }
                                    push @{ $opt->{idirs} }, $dir;
        },
        'ignore-file=s'     => sub {
                                    my ( undef, $file ) = @_;
                                    push @{ $opt->{ifiles} }, $file;
                               },
        'lines=s'           => sub { shift; my $val = shift; push @{$opt->{lines}}, $val },
        'l|files-with-matches'
                            => \$opt->{l},
        'L|files-without-matches'
                            => \$opt->{L},
        'm|max-count=i'     => \$opt->{m},
        'match=s'           => \$opt->{regex},
        'n|no-recurse'      => \$opt->{n},
        o                   => sub { $opt->{output} = '$&' },
        'output=s'          => \$opt->{output},
        'pager:s'           => sub {
            my ( undef, $value ) = @_;

            $opt->{pager} = $value || $ENV{PAGER};
        },
        'noignore-directory|noignore-dir=s'
                            => sub {
                                my ( undef, $dir ) = @_;

                                # XXX can you do --noignore-dir=match,...?
                                $dir = App::Ack::remove_dir_sep( $dir );
                                if ( $dir !~ /^(?:is|match):/ ) {
                                    $dir = 'is:' . $dir;
                                }
                                if ( $dir !~ /^(?:is|match):/ ) {
                                    Carp::croak("invalid noignore-directory argument: '$dir'");
                                }

                                @{ $opt->{idirs} } = grep {
                                    $_ ne $dir
                                } @{ $opt->{idirs} };

                                push @{ $opt->{no_ignore_dirs} }, $dir;
                            },
        'nopager'           => sub { $opt->{pager} = undef },
        'passthru'          => \$opt->{passthru},
        'print0'            => \$opt->{print0},
        'Q|literal'         => \$opt->{Q},
        'r|R|recurse'       => sub { $opt->{n} = 0 },
        's'                 => \$opt->{dont_report_bad_filenames},
        'show-types'        => \$opt->{show_types},
        'smart-case!'       => \$opt->{smart_case},
        'sort-files'        => \$opt->{sort_files},
        'type=s'            => sub {
            my ( $getopt, $value ) = @_;

            my $cb_value = 1;
            if ( $value =~ s/^no// ) {
                $cb_value = 0;
            }

            my $callback = $extra_specs->{ $value . '!' };

            if ( $callback ) {
                $callback->( $getopt, $cb_value );
            }
            else {
                Carp::croak( "Unknown type '$value'" );
            }
        },
        'u'                 => removed_option('-u'),
        'unrestricted'      => removed_option('--unrestricted'),
        'v|invert-match'    => \$opt->{v},
        'w|word-regexp'     => \$opt->{w},
        'x'                 => sub { $opt->{files_from} = '-' },

        'version'           => sub { App::Ack::print_version_statement(); exit; },
        'help|?:s'          => sub { shift; App::Ack::show_help(@_); exit; },
        'help-types'        => sub { App::Ack::show_help_types(); exit; },
        'man'               => sub { App::Ack::show_man(); exit; },
        $extra_specs ? %{$extra_specs} : (),
    }; # arg_specs
}


sub process_other {
    my ( $opt, $extra_specs, $arg_sources ) = @_;

    # Start with default options, minus some annoying ones.
    Getopt::Long::Configure('default', 'no_auto_help', 'no_auto_version');
    Getopt::Long::Configure(
        'bundling',
        'no_ignore_case',
    );

    my $argv_source;
    my $is_help_types_active;

    foreach my $source (@{$arg_sources}) {
        my ( $source_name, $args ) = @{$source}{qw/name contents/};

        if ( $source_name eq 'ARGV' ) {
            $argv_source = $args;
            last;
        }
    }

    if ( $argv_source ) { # This *should* always be true, but you never know...
        my @copy = @{$argv_source};
        local @ARGV = @copy;

        Getopt::Long::Configure('pass_through');

        Getopt::Long::GetOptions(
            'help-types' => \$is_help_types_active,
        );

        Getopt::Long::Configure('no_pass_through');
    }

    my $arg_specs = get_arg_spec($opt, $extra_specs);

    foreach my $source (@{$arg_sources}) {
        my ( $source_name, $args ) = @{$source}{qw/name contents/};

        my $args_for_source = $arg_specs;

        if ( $source->{project} ) {
            my $illegal = sub {
                die "Options --output, --pager and --match are forbidden in project .ackrc files.\n";
            };

            $args_for_source = { %$args_for_source,
                'output=s' => $illegal,
                'pager:s'  => $illegal,
                'match=s'  => $illegal,
            };
        }

        my $ret;
        if ( ref($args) ) {
            local @ARGV = @{$args};
            $ret = Getopt::Long::GetOptions( %{$args_for_source} );
            @{$args} = @ARGV;
        }
        else {
            ( $ret, $source->{contents} ) =
                Getopt::Long::GetOptionsFromString( $args, %{$args_for_source} );
        }
        if ( !$ret ) {
            if ( !$is_help_types_active ) {
                my $where = $source_name eq 'ARGV' ? 'on command line' : "in $source_name";
                App::Ack::die( "Invalid option $where" );
            }
        }
        if ( $opt->{noenv_seen} ) {
            App::Ack::die( "--noenv found in $source_name" );
        }
    }

    # XXX We need to check on a -- in the middle of a non-ARGV source

    return;
}


sub should_dump_options {
    my ( $sources ) = @_;

    foreach my $source (@{$sources}) {
        my ( $name, $options ) = @{$source}{qw/name contents/};

        if($name eq 'ARGV') {
            my $dump;
            local @ARGV = @{$options};
            Getopt::Long::Configure('default', 'pass_through', 'no_auto_help', 'no_auto_version');
            Getopt::Long::GetOptions(
                'dump' => \$dump,
            );
            @{$options} = @ARGV;
            return $dump;
        }
    }
    return;
}


sub explode_sources {
    my ( $sources ) = @_;

    my @new_sources;

    Getopt::Long::Configure('default', 'pass_through', 'no_auto_help', 'no_auto_version');

    my %opt;
    my $arg_spec = get_arg_spec(\%opt);

    my $add_type = sub {
        my ( undef, $arg ) = @_;

        # XXX refactor?
        if ( $arg =~ /(\w+)=/) {
            $arg_spec->{$1} = sub {};
        }
        else {
            ( $arg ) = split /:/, $arg;
            $arg_spec->{$arg} = sub {};
        }
    };

    my $del_type = sub {
        my ( undef, $arg ) = @_;

        delete $arg_spec->{$arg};
    };

    foreach my $source (@{$sources}) {
        my ( $name, $options ) = @{$source}{qw/name contents/};
        if ( ref($options) ne 'ARRAY' ) {
            $source->{contents} = $options =
                [ Text::ParseWords::shellwords($options) ];
        }

        for my $j ( 0 .. @{$options}-1 ) {
            next unless $options->[$j] =~ /^-/;
            my @chunk = ( $options->[$j] );
            push @chunk, $options->[$j] while ++$j < @{$options} && $options->[$j] !~ /^-/;
            $j--;

            my @copy = @chunk;
            local @ARGV = @chunk;
            Getopt::Long::GetOptions(
                'type-add=s' => $add_type,
                'type-set=s' => $add_type,
                'type-del=s' => $del_type,
            );
            Getopt::Long::GetOptions( %{$arg_spec} );

            push @new_sources, {
                name     => $name,
                contents => \@copy,
            };
        }
    }

    return \@new_sources;
}


sub compare_opts {
    my ( $a, $b ) = @_;

    my $first_a = $a->[0];
    my $first_b = $b->[0];

    $first_a =~ s/^--?//;
    $first_b =~ s/^--?//;

    return $first_a cmp $first_b;
}


sub dump_options {
    my ( $sources ) = @_;

    $sources = explode_sources($sources);

    my %opts_by_source;
    my @source_names;

    foreach my $source (@{$sources}) {
        my ( $name, $contents ) = @{$source}{qw/name contents/};
        if ( not $opts_by_source{$name} ) {
            $opts_by_source{$name} = [];
            push @source_names, $name;
        }
        push @{$opts_by_source{$name}}, $contents;
    }

    foreach my $name (@source_names) {
        my $contents = $opts_by_source{$name};

        print $name, "\n";
        print '=' x length($name), "\n";
        print '  ', join(' ', @{$_}), "\n" foreach sort { compare_opts($a, $b) } @{$contents};
    }

    return;
}


sub remove_default_options_if_needed {
    my ( $sources ) = @_;

    my $default_index;

    foreach my $index ( 0 .. $#{$sources} ) {
        if ( $sources->[$index]{'name'} eq 'Defaults' ) {
            $default_index = $index;
            last;
        }
    }

    return $sources unless defined $default_index;

    my $should_remove = 0;

    # Start with default options, minus some annoying ones.
    Getopt::Long::Configure('default', 'no_auto_help', 'no_auto_version');
    Getopt::Long::Configure(
        'no_ignore_case',
        'no_auto_abbrev',
        'pass_through',
    );

    foreach my $index ( $default_index + 1 .. $#{$sources} ) {
        my ( $name, $args ) = @{$sources->[$index]}{qw/name contents/};

        if (ref($args)) {
            local @ARGV = @{$args};
            Getopt::Long::GetOptions(
                'ignore-ack-defaults' => \$should_remove,
            );
            @{$args} = @ARGV;
        }
        else {
            ( undef, $sources->[$index]{contents} ) = Getopt::Long::GetOptionsFromString($args,
                'ignore-ack-defaults' => \$should_remove,
            );
        }
    }

    Getopt::Long::Configure('default');
    Getopt::Long::Configure('default', 'no_auto_help', 'no_auto_version');

    return $sources unless $should_remove;

    my @copy = @{$sources};
    splice @copy, $default_index, 1;
    return \@copy;
}


sub check_for_mutually_exclusive_options {
    my ( $arg_sources ) = @_;

    my %mutually_exclusive_with;
    my @copy = @{$arg_sources};

    for(my $i = 0; $i < @INVALID_COMBINATIONS; $i += 2) {
        my ( $lhs, $rhs ) = @INVALID_COMBINATIONS[ $i, $i + 1 ];

        foreach my $l_opt ( @{$lhs} ) {
            foreach my $r_opt ( @{$rhs} ) {
                push @{ $mutually_exclusive_with{ $l_opt } }, $r_opt;
                push @{ $mutually_exclusive_with{ $r_opt } }, $l_opt;
            }
        }
    }

    while( @copy ) {
        my %set_opts;

        my $source = shift @copy;
        my ( $source_name, $args ) = @{$source}{qw/name contents/};
        $args = ref($args) ? [ @{$args} ] : [ Text::ParseWords::shellwords($args) ];

        foreach my $opt ( @{$args} ) {
            next unless $opt =~ /^[-+]/;
            last if $opt eq '--';

            if( $opt =~ /^(.*)=/ ) {
                $opt = $1;
            }
            elsif ( $opt =~ /^(-[^-]).+/ ) {
                $opt = $1;
            }

            $set_opts{ $opt } = 1;

            my $mutex_opts = $mutually_exclusive_with{ $opt };

            next unless $mutex_opts;

            foreach my $mutex_opt ( @{$mutex_opts} ) {
                if($set_opts{ $mutex_opt }) {
                    die "Options '$mutex_opt' and '$opt' are mutually exclusive\n";
                }
            }
        }
    }
}


sub process_args {
    my $arg_sources = \@_;

    my %opt = (
        pager => $ENV{ACK_PAGER_COLOR} || $ENV{ACK_PAGER},
    );

    check_for_mutually_exclusive_options($arg_sources);

    $arg_sources = remove_default_options_if_needed($arg_sources);

    if ( should_dump_options($arg_sources) ) {
        dump_options($arg_sources);
        exit(0);
    }

    my $type_specs = process_filetypes(\%opt, $arg_sources);
    process_other(\%opt, $type_specs, $arg_sources);
    while ( @{$arg_sources} ) {
        my $source = shift @{$arg_sources};
        my ( $source_name, $args ) = @{$source}{qw/name contents/};

        # All of our sources should be transformed into an array ref
        if ( ref($args) ) {
            if ( $source_name eq 'ARGV' ) {
                @ARGV = @{$args};
            }
            elsif (@{$args}) {
                Carp::croak "source '$source_name' has extra arguments!";
            }
        }
        else {
            Carp::croak 'The impossible has occurred!';
        }
    }
    my $filters = ($opt{filters} ||= []);

    # Throw the default filter in if no others are selected.
    if ( not grep { !$_->is_inverted() } @{$filters} ) {
        push @{$filters}, App::Ack::Filter::Default->new();
    }
    return \%opt;
}


sub retrieve_arg_sources {
    my @arg_sources;

    my $noenv;
    my $ackrc;

    Getopt::Long::Configure('default', 'no_auto_help', 'no_auto_version');
    Getopt::Long::Configure('pass_through');
    Getopt::Long::Configure('no_auto_abbrev');

    Getopt::Long::GetOptions(
        'noenv'   => \$noenv,
        'ackrc=s' => \$ackrc,
    );

    Getopt::Long::Configure('default', 'no_auto_help', 'no_auto_version');

    my @files;

    if ( !$noenv ) {
        my $finder = App::Ack::ConfigFinder->new;
        @files  = $finder->find_config_files;
    }
    if ( $ackrc ) {
        # We explicitly use open so we get a nice error message.
        # XXX This is a potential race condition!.
        if(open my $fh, '<', $ackrc) {
            close $fh;
        }
        else {
            die "Unable to load ackrc '$ackrc': $!"
        }
        push( @files, { path => $ackrc } );
    }

    push @arg_sources, {
        name     => 'Defaults',
        contents => [ App::Ack::ConfigDefault::options_clean() ],
    };

    foreach my $file ( @files) {
        my @lines = App::Ack::ConfigFinder::read_rcfile($file->{path});

        if(@lines) {
            push @arg_sources, {
                name     => $file->{path},
                contents => \@lines,
                project  => $file->{project},
            };
        }
    }

    if ( $ENV{ACK_OPTIONS} && !$noenv ) {
        push @arg_sources, {
            name     => 'ACK_OPTIONS',
            contents => $ENV{ACK_OPTIONS},
        };
    }

    push @arg_sources, {
        name     => 'ARGV',
        contents => [ @ARGV ],
    };

    return @arg_sources;
}

1; # End of App::Ack::ConfigLoader
