
use File::Next ();
use App::Ack ();
use Cwd ();
use File::Spec ();

my $orig_wd;

sub prep_environment {
    delete @ENV{qw( ACK_OPTIONS ACKRC ACK_PAGER HOME )};
    $orig_wd = Cwd::getcwd();
}

# capture stderr output into this file
my $catcherr_file = 'stderr.log';

sub is_win32 {
    return $^O =~ /Win32/;
}

# capture-stderr is executing ack and storing the stderr output in
# $catcherr_file in a portable way.
#
# The quoting of command line arguments depends on the OS
sub build_command_line {
    my @args = @_;

    my %options;

    if ( ref( $args[-1] ) eq 'HASH' ) {
        %options = %{ pop @args };
    }

    if ( is_win32() ) {
        for ( @args ) {
            s/(\\+)$/$1$1/;     # Double all trailing backslashes
            s/"/\\"/g;          # Backslash all quotes
            $_ = qq{"$_"};
        }
    }
    else {
        @args = map { quotemeta $_ } @args;
    }
    if ( !$options{no_capture} ) {
        unshift @args, File::Spec->catfile($orig_wd, 'capture-stderr'),
            $catcherr_file;
    }

    return "$^X -T @args";
}

sub build_ack_command_line {
    my @args = @_;

    # The --noenv makes sure we don't pull in anything from the user
    #    unless explicitly specified in the test
    if ( !grep { /^--(no)?env$/ } @args ) {
        unshift( @args, '--noenv' );
    }
    # --ackrc makes sure we pull in "default" definitions
    if( !grep { /^--ackrc=/ } @args) {
        unshift( @args, '--ackrc=' . File::Spec->catfile($orig_wd, './ackrc') );
    }

    return build_command_line( File::Spec->catfile($orig_wd, 'ack'), @args );
}

sub slurp {
    my $iter = shift;

    my @files;
    while ( defined ( my $file = $iter->() ) ) {
        push( @files, $file );
    }

    return @files;
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

sub run_ack {
    my @args = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ($stdout, $stderr) = run_ack_with_stderr( @args );

    if ( $TODO ) {
        fail( q{Automatically fail stderr check for TODO tests.} );
    }
    else {
        is( scalar @{$stderr}, 0, "Should have no output to stderr: ack @args" )
            or diag( join( "\n", "STDERR:", @{$stderr} ) );
    }

    return wantarray ? @{$stdout} : join( "\n", @{$stdout} );
}

{ # scope for $ack_return_code;

# capture returncode
our $ack_return_code;

# run the given command, assuming that the command was created with
# build_ack_command_line (and thus writes its STDERR to $catcherr_file).
#
# sets $ack_return_code and unlinks the $catcherr_file
#
# returns chomped STDOUT and STDERR as two array refs
sub run_cmd {
    my $cmd = shift;

    # diag( "Running command: $cmd" );

    record_option_coverage($cmd);
    my @stdout = `$cmd`;
    my ($sig,$core,$rc) = (($? & 127),  ($? & 128) , ($? >> 8));
    $ack_return_code = $rc;
    ## XXX what do do with $core or $sig?

    my @stderr;
    open( my $fh, '<', $catcherr_file ) or die $!;
    while ( <$fh> ) {
        push( @stderr, $_ );
    }
    close $fh or die $!;
    unlink $catcherr_file;

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

    my $cmd = build_ack_command_line( @args );

    return run_cmd($cmd);
}

# pipe into ack and return STDOUT and STDERR as array refs
sub pipe_into_ack_with_stderr {
    my $input = shift;
    my @args = @_;

    my $cmd = build_ack_command_line( @args );
    $cmd = "$^X -pe1 $input | $cmd";

    my ($stdout, $stderr) = run_cmd( $cmd );
    return ( $stdout, $stderr );
}

# pipe into ack and return STDOUT as array, for arguments see pipe_into_ack_with_stderr
sub pipe_into_ack {
    my ($stdout, $stderr) = pipe_into_ack_with_stderr( @_ );
    return @$stdout;
}


# Use this one if order is important
sub lists_match {
    my @actual = @{+shift};
    my @expected = @{+shift};
    my $msg = shift;

    # Normalize all the paths
    for my $path ( @expected, @actual ) {
        $path = File::Next::reslash( $path ); ## no critic (Variables::ProhibitPackageVars)
    }

    local $Test::Builder::Level = $Test::Builder::Level + 1; ## no critic

    eval 'use Test::Differences';
    if ( !$@ ) {
        return eq_or_diff( [@actual], [@expected], $msg );
    }
    else {
        return is_deeply( [@actual], [@expected], $msg );
    }
}

sub ack_lists_match {
    my $args     = shift;
    my $expected = shift;
    my $message  = shift;
    my @args     = @{$args};

    my @results = run_ack( @args );
    my $ok = lists_match( \@results, $expected, $message );
    $ok or diag( join( ' ', '$ ack', @args ) );

    return $ok;
}

# Use this one if you don't care about order of the lines
sub sets_match {
    my @actual = @{+shift};
    my @expected = @{+shift};
    my $msg = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1; ## no critic
    return lists_match( [sort @actual], [sort @expected], $msg );
}

sub ack_sets_match {
    my $args     = shift;
    my $expected = shift;
    my $message  = shift;
    my @args     = @{$args};

    my @results = run_ack( @args );
    my $ok = sets_match( \@results, $expected, $message );
    $ok or diag( join( ' ', '$ ack', @args ) );

    return $ok;
}


sub is_filetype {
    my $filename = shift;
    my $wanted_type = shift;

    for my $maybe_type ( App::Ack::filetypes( $filename ) ) {
        return 1 if $maybe_type eq $wanted_type;
    }

    return;
}

sub record_option_coverage {
    my ( $command_line ) = @_;

    return unless $ENV{ACK_OPTION_COVERAGE};

    # strip the command line up until 'ack' is found
    $command_line =~ s/^.*ack\b//;

    $command_line = $^X . ' ' . File::Spec->catfile($orig_wd, 'record-options')
        . ' ' .  $command_line;

    system $command_line;

    return;
}

BEGIN {
    my $ok = eval {
        require IO::Pty;
        1;
    };

    if($ok) {
        no strict 'refs';
        *run_ack_interactive = sub {
            my ( @args) = @_;

            my $cmd = build_ack_command_line(@args, {
                no_capture => 1,
            });

            record_option_coverage($cmd);

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
                    return @lines;
                } else {
                    my $output = '';

                    while(<$pty>) {
                        $output .= $_;
                    }
                    close $pty;
                    return $output;
                }
            } else {
                $pty->make_slave_controlling_terminal();
                my $slave = $pty->slave();
                $slave->clone_winsize_from(\*STDIN);
                $slave->set_raw();

                open STDIN,  '<&', $slave->fileno();
                open STDOUT, '>&', $slave->fileno();
                open STDERR, '>&', $slave->fileno();

                close $slave;

                exec $cmd;
            }
        };
    }
}

1;
