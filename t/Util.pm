
use Carp ();
use File::Next ();
use App::Ack ();
use Cwd ();
use File::Spec ();
use File::Temp ();
use Term::ANSIColor ();
use Test::More;

my $orig_wd;
my @temp_files; # We store temp files here to make sure they're properly reclaimed at interpreter shutdown.

sub check_message {
    my $msg = shift;

    if ( !$msg ) {
        my (undef,undef,undef,$sub) = caller(1);
        Carp::croak( "You must pass a message to $sub" );
    }

    return $msg;
}

sub prep_environment {
    my @ack_args   = qw( ACK_OPTIONS ACKRC ACK_PAGER HOME ACK_COLOR_MATCH ACK_COLOR_FILENAME ACK_COLOR_LINE );
    my @taint_args = qw( PATH CDPATH IFS );
    delete @ENV{ @ack_args, @taint_args };

    if ( is_windows() ) {
        # To pipe, perl must be able to find cmd.exe, so add %SystemRoot%\system32 to the path.
        # See http://kstruct.com/2006/09/13/perl-taint-mode-and-cmdexe/
        $ENV{'SystemRoot'} =~ /([A-Z]:(\\[A-Z0-9_]+)+)/i;
        my $system32_dir = File::Spec->catdir($1,'system32');
        $ENV{'PATH'} = $system32_dir;
    }

    $orig_wd = getcwd_clean();
}

sub is_windows {
    return $^O eq 'MSWin32';
}

sub is_cygwin {
    return $^O eq 'cygwin';
}

sub is_empty_array {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $aref = shift;
    my $msg  = shift;

    my $ok = defined($aref) && (ref($aref) eq 'ARRAY') && (scalar(@{$aref}) == 0);

    if ( !ok( $ok, $msg ) ) {
        diag( explain( $aref ) );
    }
    return $ok;
}

sub is_nonempty_array {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $aref = shift;
    my $msg  = shift;

    my $ok = defined($aref) && (ref($aref) eq 'ARRAY') && (scalar(@{$aref}) > 0);

    if ( !ok( $ok, $msg ) ) {
        diag( explain( $aref ) );
    }
    return $ok;
}

sub first_line_like {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $lines = shift;
    my $re    = shift;
    my $msg   = shift;

    my $ok = like( $lines->[0], $re, $msg );
    diag(explain($lines)) unless $ok;

    return $ok;
}


sub build_ack_invocation {
    my @args = @_;

    my $options;

    foreach my $arg ( @args ) {
        if ( ref($arg) eq 'HASH' ) {
            if ( $options ) {
                Carp::croak('You may not specify more than one options hash');
            }
            else {
                $options = $arg;
            }
        }
    }

    $options ||= {};

    if ( my $ackrc = $options->{ackrc} ) {
        if ( ref($ackrc) eq 'SCALAR' ) {
            my $temp_ackrc = File::Temp->new;
            push @temp_files, $temp_ackrc;

            print { $temp_ackrc } $$ackrc, "\n";
            close $temp_ackrc;
            $ackrc = $temp_ackrc->filename;
        }

        unshift @args, '--ackrc', $ackrc;
    }

    # The --noenv makes sure we don't pull in anything from the user
    #    unless explicitly specified in the test
    if ( !grep { /^--(no)?env$/ } @args ) {
        unshift( @args, '--noenv' );
    }

    if ( $ENV{'ACK_TEST_STANDALONE'} ) {
        unshift( @args, File::Spec->rel2abs( 'ack-standalone', $orig_wd ) );
    }
    else {
        unshift( @args, File::Spec->rel2abs( 'blib/script/ack', $orig_wd ) );
    }

    return @args;
}

# Use this instead of File::Slurp::read_file()
sub read_file {
    my $filename = shift;

    open( my $fh, '<', $filename ) or die "Can't read $filename: \n";
    my @lines = <$fh>;
    close $fh or die;

    return wantarray ? @lines : join( '', @lines );
}

# Use this instead of File::Slurp::write_file()
sub write_file {
    return _write_file( '>', 'create', @_ );
}

# Use this instead of File::Slurp::append_file()
sub append_file {
    return _write_file( '>>', 'append', @_ );
}

sub _write_file {
    my $op       = shift;
    my $verb     = shift;
    my $filename = shift;
    my @lines    = @_;

    open( my $fh, $op, $filename ) or die "Can't $verb $filename: \n";
    for my $line ( @lines ) {
        print {$fh} $line;
    }
    close $fh or die;

    return;
}

sub break_up_lines {
    my $str = shift;

    return split( /\n/, $str );
}

sub reslash_all {
    return map { File::Next::reslash( $_ ) } @_;
}

sub run_ack {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my @args = @_;

    my ($stdout, $stderr) = run_ack_with_stderr( @args );
    @args = grep { ref($_) ne 'HASH' } @args;

    if ( $TODO ) {
        fail( q{Automatically fail stderr check for TODO tests.} );
    }
    else {
        is_empty_array( $stderr, "Should have no output to stderr: ack @args" );
    }

    return wantarray ? @{$stdout} : join( "\n", @{$stdout} );
}

{ # scope for $ack_return_code;

# Capture return code.
our $ack_return_code;

# Run the given command, assuming that the command was created with
# build_ack_invocation (and thus writes its STDERR to $catcherr_file).
#
# Sets $ack_return_code and unlinks the $catcherr_file.
#
# Returns chomped STDOUT and STDERR as two array refs.
sub run_cmd {
    my ( @cmd ) = @_;

    # my $cmd = join( ' ', @cmd );
    # diag( "Running command: $cmd" );

    my $options = {};

    foreach my $arg (@cmd) {
        if ( ref($arg) eq 'HASH' ) {
            $options = $arg;
        }
    }
    @cmd = grep { ref($_) ne 'HASH' } @cmd;

    record_option_coverage(@cmd);

    check_command_for_taintedness( @cmd );

    my ( @stdout, @stderr );

    if ( is_windows() ) {
        require Win32::ShellQuote;
        # Capture stderr & stdout output into these files (only on Win32).
        my $catchout_file = 'stdout.log';
        my $catcherr_file = 'stderr.log';

        open(SAVEOUT, ">&STDOUT") or die "Can't dup STDOUT: $!";
        open(SAVEERR, ">&STDERR") or die "Can't dup STDERR: $!";
        open(STDOUT, '>', $catchout_file) or die "Can't open $catchout_file: $!";
        open(STDERR, '>', $catcherr_file) or die "Can't open $catcherr_file: $!";
        my $cmd = Win32::ShellQuote::quote_system_string(@cmd);
        if ( my $input = $options->{input} ) {
            my $input_command = Win32::ShellQuote::quote_system_string(@{$input});
            $cmd = "$input_command | $cmd";
        }
        system( $cmd );
        close STDOUT;
        close STDERR;
        open(STDOUT, ">&SAVEOUT") or die "Can't restore STDOUT: $!";
        open(STDERR, ">&SAVEERR") or die "Can't restore STDERR: $!";
        close SAVEOUT;
        close SAVEERR;
        @stdout = read_file($catchout_file);
        @stderr = read_file($catcherr_file);
    }
    else {
        my ( $stdout_read, $stdout_write );
        my ( $stderr_read, $stderr_write );

        pipe $stdout_read, $stdout_write
            or Carp::croak( "Unable to create pipe: $!" );

        pipe $stderr_read, $stderr_write
            or Carp::croak( "Unable to create pipe: $!" );

        my $pid = fork();
        if ( $pid == -1 ) {
            Carp::croak( "Unable to fork: $!" );
        }

        if ( $pid ) {
            close $stdout_write;
            close $stderr_write;

            while ( $stdout_read || $stderr_read ) {
                my $rin = '';

                vec( $rin, fileno($stdout_read), 1 ) = 1 if $stdout_read;
                vec( $rin, fileno($stderr_read), 1 ) = 1 if $stderr_read;

                select( $rin, undef, undef, undef );

                if ( $stdout_read && vec( $rin, fileno($stdout_read), 1 ) ) {
                    my $line = <$stdout_read>;

                    if ( defined( $line ) ) {
                        push @stdout, $line;
                    }
                    else {
                        close $stdout_read;
                        undef $stdout_read;
                    }
                }

                if ( $stderr_read && vec( $rin, fileno($stderr_read), 1 ) ) {
                    my $line = <$stderr_read>;

                    if ( defined( $line ) ) {
                        push @stderr, $line;
                    }
                    else {
                        close $stderr_read;
                        undef $stderr_read;
                    }
                }
            }

            waitpid $pid, 0;
        }
        else {
            close $stdout_read;
            close $stderr_read;

            if (my $input = $options->{input}) {
                check_command_for_taintedness( @{$input} );
                open STDIN, '-|', @{$input} or die "Can't open STDIN: $!";
            }

            open STDOUT, '>&', $stdout_write or die "Can't open STDOUT: $!";
            open STDERR, '>&', $stderr_write or die "Can't open STDERR: $!";

            exec @cmd;
        }
    } # end else not Win32

    my ($sig,$core,$rc) = (($? & 127),  ($? & 128) , ($? >> 8));
    $ack_return_code = $rc;
    ## XXX what do do with $core or $sig?

    chomp @stdout;
    chomp @stderr;

    return ( \@stdout, \@stderr );
}


sub get_rc {
    return $ack_return_code;
}

} # scope for $ack_return_code

sub run_ack_with_stderr {
    my @args = @_;

    my @stdout;
    my @stderr;

    my $perl = caret_X();

    @args = build_ack_invocation( @args );
    if ( $ENV{'ACK_TEST_STANDALONE'} ) {
        unshift( @args, $perl );
    }
    else {
        unshift( @args, $perl, "-Mblib=$orig_wd" );
    }

    return run_cmd( @args );
}

# Pipe into ack and return STDOUT and STDERR as array refs.
sub pipe_into_ack_with_stderr {
    my $input = shift;
    my @args = @_;

    my $tempfile;

    if ( ref($input) eq 'SCALAR' ) {
        # We could easily do this without temp files, but that would take
        # slightly more time than I'm willing to spend on this right now.
        $tempfile = File::Temp->new;
        print {$tempfile} $$input . "\n";
        close $tempfile;
        $input = $tempfile->filename;
    }

    return run_ack_with_stderr(@args, {
        # Use Perl since we don't know that 'cat' will exist.
        input => [caret_X(), '-pe1', $input],
    });
}

# Pipe into ack and return STDOUT as array, for arguments see pipe_into_ack_with_stderr.
sub pipe_into_ack {
    my ($stdout, $stderr) = pipe_into_ack_with_stderr( @_ );
    return @$stdout;
}


# Use this one if order is important.
sub lists_match {
    local $Test::Builder::Level = $Test::Builder::Level + 1; ## no critic

    my @actual   = @{+shift};
    my @expected = @{+shift};
    my $msg      = check_message( shift );

    # Normalize all the paths
    for my $path ( @expected, @actual ) {
        $path = File::Next::reslash( $path ); ## no critic (Variables::ProhibitPackageVars)
    }

    return subtest "lists_match( $msg )" => sub {
        plan tests => 1;

        my $rc = eval 'use Test::Differences; 1;';
        if ( $rc ) {
            $ok = eq_or_diff( [@actual], [@expected], $msg );
        }
        else {
            $ok = is_deeply( [@actual], [@expected], $msg );
        }

        if ( !$ok ) {
            diag( explain( actual => [@actual], expected => [@expected] ) );
        }

        return $ok;
    };
}

sub ack_lists_match {
    local $Test::Builder::Level = $Test::Builder::Level + 1; ## no critic

    my $args     = shift;
    my $expected = shift;
    my $message  = check_message( shift );

    my @args     = @{$args};

    my @results = run_ack( @args );

    return subtest "ack_lists_match( $message )" => sub {
        plan tests => 1;

        my $ok = lists_match( \@results, $expected, $message );
        $ok or diag( join( ' ', '$ ack', @args ) );
    };
}

# Use this one if you don't care about order of the lines.
sub sets_match {
    local $Test::Builder::Level = $Test::Builder::Level + 1; ## no critic

    my @actual   = @{+shift};
    my @expected = @{+shift};
    my $msg      = check_message( shift );

    return subtest "sets_match( $msg )" => sub {
        plan tests => 1;

        return lists_match( [sort @actual], [sort @expected], $msg );
    };
}

sub ack_sets_match {
    local $Test::Builder::Level = $Test::Builder::Level + 1; ## no critic

    my $args     = shift;
    my $expected = shift;
    my $message  = check_message( shift );
    my @args     = @{$args};

    return subtest "ack_sets_match( $message )" => sub {
        plan tests => 2;

        my @results = run_ack( @args );
        my $ok = sets_match( \@results, $expected, $message );
        $ok or diag( join( ' ', '$ ack', @args ) );

        return $ok;
    };
}


sub record_option_coverage {
    my ( @command_line ) = @_;

    return unless $ENV{ACK_OPTION_COVERAGE};
    return if $ENV{ACK_STANDALONE}; # We don't need to record the second time around.

    my $record_options = File::Spec->catfile($orig_wd, 'record-options');

    my $perl = caret_X();
    if ( @command_line == 1 ) {
        my $command_line = $command_line[0];

        # strip the command line up until 'ack' is found
        $command_line =~ s/^.*ack\b//;

        $command_line = "$perl -T $record_options $command_line";

        system $command_line;
    }
    else {
        while ( @command_line && $command_line[0] !~ /ack/ ) {
            shift @command_line;
        }
        shift @command_line; # get rid of 'ack' itself
        unshift @command_line, $perl, '-T', $record_options;

        system @command_line;
    }

    return;
}

=head2 colorize( $big_long_string )

Turns a multi-line input string into its corresponding array of lines, with colorized transformations.

    <text> gets turned to filename color.
    {text} gets turned to line number color.
    (text) gets turned to highlight color.

=cut

sub colorize {
    my $input = shift;

    my @lines = split( /\n/, $input );

    for my $line ( @lines ) {
        # File name
        $line =~ s/<(.+?)>/Term::ANSIColor::colored($1, 'bold green')/eg;

        # Line number
        $line =~ s/\{(.+?)\}/Term::ANSIColor::colored($1, 'bold yellow')/eg;

        # Matches
        my $n;
        $n += $line =~ s/\((.+?)\)/Term::ANSIColor::colored($1, 'black on_yellow')/eg;

        $line .= "\033[0m\033[K" if $n;
    }

    return @lines;
}


BEGIN {
    my $has_io_pty = eval {
        require IO::Pty;
        1;
    };

    sub has_io_pty {
        return $has_io_pty;
    }

    if ($has_io_pty) {
        no strict 'refs';
        *run_ack_interactive = sub {
            my ( @args) = @_;

            my @cmd = build_ack_invocation(@args);
            @cmd    = grep { ref($_) ne 'HASH' } @cmd;

            record_option_coverage(@cmd);

            my $pty = IO::Pty->new;

            my $pid = fork;

            if($pid) {
                $pty->close_slave();
                $pty->set_raw();

                if(wantarray) {
                    my @lines;

                    while(<$pty>) {
                        chomp;
                        push @lines, $_;
                    }
                    close $pty;
                    waitpid $pid, 0;
                    return @lines;
                }
                else {
                    my $output = '';

                    while(<$pty>) {
                        $output .= $_;
                    }
                    close $pty;
                    waitpid $pid, 0;
                    return $output;
                }
            }
            else {
                $pty->make_slave_controlling_terminal();
                my $slave = $pty->slave();
                if(-t *STDIN) {
                    # Is there something we can fall back on? Maybe re-opening /dev/console?
                    $slave->clone_winsize_from(\*STDIN);
                }
                $slave->set_raw();

                open STDIN,  '<&', $slave->fileno() or die "Can't open: $!";
                open STDOUT, '>&', $slave->fileno() or die "Can't open: $!";
                open STDERR, '>&', $slave->fileno() or die "Can't open: $!";

                close $slave;

                my $perl = caret_X();

                if ( $ENV{'ACK_TEST_STANDALONE'} ) {
                    unshift( @cmd, $perl );
                }
                else {
                    unshift( @cmd, $perl, "-Mblib=$orig_wd" );
                }

                exec @cmd;
            }
        };
    }
    else {
        no strict 'refs';
        require Test::More;

        *run_ack_interactive = sub {
            local $Test::Builder::Level = $Test::Builder::Level + 1;
            Test::More::fail(<<'END_FAIL');
Your system doesn't seem to have IO::Pty, and the developers
forgot to check in this test file.  Please file a bug report
at https://github.com/petdance/ack2/issues with the name of
the file that generated this failure.
END_FAIL
        };
    }
}

# This should not be treated as a complete list of the available
# options, but it's complete enough to rely on until we find a
# more elegant way to generate this list.
sub get_options {
    return (
        '--ackrc',
        '--after-context',
        '--bar',
        '--before-context',
        '--break',
        '--cathy',
        '--color',
        '--color-filename',
        '--color-lineno',
        '--color-match',
        '--colour',
        '--column',
        '--context',
        '--count',
        '--create-ackrc',
        '--dump',
        '--env',
        '--files-from',
        '--files-with-matches',
        '--files-without-matches',
        '--filter',
        '--flush',
        '--follow',
        '--group',
        '--heading',
        '--help',
        '--help-types',
        '--ignore-ack-defaults',
        '--ignore-case',
        '--ignore-dir',
        '--ignore-directory',
        '--ignore-file',
        '--invert-match',
        '--lines',
        '--literal',
        '--man',
        '--match',
        '--max-count',
        '--no-filename',
        '--no-recurse',
        '--nobreak',
        '--nocolor',
        '--nocolour',
        '--nocolumn',
        '--noenv',
        '--nofilter',
        '--nofollow',
        '--nogroup',
        '--noheading',
        '--noignore-dir',
        '--noignore-directory',
        '--nopager',
        '--nosmart-case',
        '--output',
        '--pager',
        '--passthru',
        '--print0',
        '--recurse',
        '--show-types',
        '--smart-case',
        '--sort-files',
        '--thpppt',
        '--type',
        '--type-add',
        '--type-del',
        '--type-set',
        '--version',
        '--with-filename',
        '--word-regexp',
        '-1',
        '-?',
        '-A',
        '-B',
        '-C',
        '-H',
        '-L',
        '-Q',
        '-R',
        '-c',
        '-f',
        '-g',
        '-h',
        '-i',
        '-l',
        '-m',
        '-n',
        '-o',
        '-r',
        '-s',
        '-v',
        '-w',
        '-x',
    );
}


# This is just a handy diagnostic tool.
sub check_command_for_taintedness {
    my @args = @_;

    my $bad = 0;

    my @tainted;
    for my $arg ( @args ) {
        if ( is_tainted( $arg ) ) {
            push( @tainted, $arg );
        }
    }

    if ( @tainted ) {
        die "Can't execute this command because of taintedness:\nAll args: @args\nTainted:  @tainted\n";
    }

    return;
}


sub is_tainted {
    no warnings qw(void uninitialized);

    return !eval { local $SIG{__DIE__} = 'DEFAULT'; join('', shift), kill 0; 1 };
}


sub untaint {
    my ( $s ) = @_;

    $s =~ /\A(.*)\z/;
    return $1;
}


sub caret_X {
    # XXX How is it $^X can be tainted?  We should not have to untaint it.
    $^X =~ /(.+)/;
    my $perl = $1;

    return $perl;
}


sub getcwd_clean {
    # XXX How is it that this guy is tainted?
    my $wd = Cwd::getcwd();
    $wd =~ /(.+)/;
    return $1;
}


sub windows_slashify {
    my $str = shift;

    $str =~ s{/}{\\}g;

    return $str;
}

1;
