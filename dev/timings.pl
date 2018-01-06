#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use 5.10.0;

use Getopt::Long;
use File::Slurp qw(read_dir read_file write_file);
use File::Spec;
use JSON;
use List::MoreUtils qw(any);
use Term::ANSIColor qw(colored);
use Time::HiRes qw(gettimeofday tv_interval);

my $SOURCE_DIR = File::Spec->catdir($ENV{HOME}, 'parrot');

unless ( -d $SOURCE_DIR ) {
    die "Expecting to find parrot in $SOURCE_DIR - get it from github.com/parrot/parrot";
}

sub grab_versions {
    my @acks = @_;

    my @annotated_acks;

    foreach my $ack (@acks) {
        my $version;

        if($ack =~ /standalone/) {
            $version = 'HEAD';
        }
        else {
            my $output = `$^X $ack --noenv --version 2>&1`;
            if($output =~ /ack\s+(?<version>\d+[.]\d+(_\d+)?)/) {
                $version = $+{'version'};
            } else {
                # XXX uh-oh
            }
        }

        push @annotated_acks, {
            path    => $ack,
            version => $version,
        };

        if($version eq 'HEAD') {
            $annotated_acks[-1]{'store_timings'} = 1;
        }
    }

    return @annotated_acks;
}

sub create_format {
    my ( $invocations, $acks, $show_colors ) = @_;

    my $max_invocation_length = -1;

    foreach my $invocation (@$invocations) {
        my $length = length(join(' ', 'ack', @$invocation));
        if($length > $max_invocation_length) {
            $max_invocation_length = $length;
        }
    }

    my @max_version_lengths = (length(color('000.00'))) x @$acks;

    for(0..$#$acks) {
        if(length($acks->[$_]{'version'}) > $max_version_lengths[$_]) {
            $max_version_lengths[$_] = length($acks->[$_]{'version'});
        }
    }

    return join(' | ', "%${max_invocation_length}s", map {
        "%${_}s"
    } @max_version_lengths) . "\n";
}

my $num_iterations = 1;

sub time_ack {
    my ( $ack, $invocation, $perl ) = @_;

    my @args = ( $perl, $ack->{'path'}, '--noenv', @$invocation );

    if ( $ack->{'path'} =~ /ack-1/ ) {
        @args = grep { !/--known/ } @args;
    }

    my $end;
    my $start = [gettimeofday()];
    for ( 1 .. $num_iterations ) {
        my ( $read, $write );
        pipe $read, $write;
        my $pid   = fork;

        my $has_error_lines;

        if($pid) {
            close $write;
            while(<$read>) {
                $has_error_lines = 1;
            }
            waitpid $pid, 0;
            return if $has_error_lines;
        } else {
            close $read;
            open STDOUT, '>', File::Spec->devnull;
            open STDERR, '>&', $write;
            exec @args;
            exit 255;
        }
    }
    $end = [gettimeofday()];

    return tv_interval($start, $end) / $num_iterations;
}

my $show_colors;

sub color {
    my ( $previous_value, $value );

    if ( @_ == 2 ) {
        ( $previous_value, $value ) = @_;
    }
    else {
        ( $value ) = @_;
    }

    return $value if !$show_colors;
    return $value if !defined($value);

    return colored(['white'], $value) if !defined($previous_value);

    if ( $previous_value < $value ) {
        return colored(['red'], $value);
    }
    else {
        return colored(['green'], $value);
    }
}

my @invocations = (
    # normal mode
    [ 'foo', $SOURCE_DIR ],
    [ 'foo', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ 'foo', '--lisp', $SOURCE_DIR ], # where there are little/none
    [ 'foo', '--known', $SOURCE_DIR ],

    # -f
    [ '-f', $SOURCE_DIR ],
    [ '-f', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ '-f', '--lisp', $SOURCE_DIR ], # where there are little/none
    [ '-f', '--known', $SOURCE_DIR ],

    # -l
    [ 'foo', '-l', $SOURCE_DIR ],
    [ 'foo', '-l', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ 'foo', '-l', '--lisp', $SOURCE_DIR ], # where there are little/none
    [ 'foo', '-l', '--known', $SOURCE_DIR ],

    # -c
    [ 'foo', '-c', $SOURCE_DIR ],
    [ 'foo', '-c', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ 'foo', '-c', '--lisp', $SOURCE_DIR ], # where there are little/none
    [ 'foo', '-c', '--known', $SOURCE_DIR ],

    # -A
    [ 'foo', '-A10', $SOURCE_DIR ],
    [ 'foo', '-A10', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ 'foo', '-A10', '--lisp', $SOURCE_DIR ], # where there are little/none
    [ 'foo', '-A10', '--known', $SOURCE_DIR ],

    # -B
    [ 'foo', '-B10', $SOURCE_DIR ],
    [ 'foo', '-B10', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ 'foo', '-B10', '--lisp', $SOURCE_DIR ], # where there are little/none
    [ 'foo', '-B10', '--known', $SOURCE_DIR ],

    # -C
    [ 'foo', '-C10', $SOURCE_DIR ],
    [ 'foo', '-C10', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ 'foo', '-C10', '--lisp', $SOURCE_DIR ], # where there are little/none
    [ 'foo', '-C10', '--known', $SOURCE_DIR ],
);

my $perform_store;
my $perfom_clear;
my @use_acks;
my $perl = $^X;

GetOptions(
    'clear'   => \$perfom_clear,
    'store'   => \$perform_store,
    'color'   => \$show_colors,
    'times=i' => \$num_iterations,
    'ack=s@'  => \@use_acks,
    'perl=s'  => \$perl,
);

if($perfom_clear) {
    unlink('.timings.json');
}

my $json = JSON->new->utf8->pretty;
my $previous_timings;
if(-e '.timings.json') {
    $previous_timings = $json->decode(scalar(read_file('.timings.json')));
}

my @acks = map { File::Spec->catfile('garage', $_) } read_dir('garage');
push @acks, 'ack-standalone';
@acks = grep { !/_/ } @acks;  # Skip dev versions

@acks = grab_versions(@acks);
if(@use_acks) {
    foreach my $ack (@acks) {
        next if $ack->{'version'} eq 'HEAD';
        next if $ack->{'version'} eq 'previous';
        unless(any { $_ eq $ack->{'version'} } @use_acks) {
            undef $ack;
        }
    }
    @acks = grep { defined() } @acks;
}
@acks = sort {
    return 1  if $a->{'version'} eq 'HEAD';
    return -1 if $b->{'version'} eq 'HEAD';
    return eval($a->{'version'}) + 0 <=> eval($b->{'version'}) + 0;
} @acks;

if($previous_timings) {
    splice @acks, -1, 0, {
        version => 'previous',
    };
}

my $format = create_format(\@invocations, \@acks, $show_colors);
my $header = sprintf $format, '', map { color($_->{'version'})  } @acks;
print $header;
print '-' x (length($header) - 1), "\n"; # -1 for the newline

my %stored_timings;

foreach my $invocation (@invocations) {
    my @timings;

    my $previous_timing;

    foreach my $ack (@acks) {
        my $elapsed;

        if($ack->{'path'}) {
            $elapsed = time_ack($ack, $invocation, $perl);
        } else {
            $elapsed = $previous_timings->{join(' ', 'ack', @$invocation)};
        }

        if(defined $elapsed) {
            $elapsed = sprintf('%.2f', $elapsed);
        }
        push @timings, color($previous_timing, $elapsed);
        $previous_timing = $elapsed if defined $elapsed;

        if($perform_store && $ack->{'store_timings'}) {
            $stored_timings{join(' ', 'ack', @$invocation)} = $elapsed;
        }
    }
    printf $format, join(' ', 'ack', @$invocation), map { defined() ? $_ : color('x_x') } @timings;
}

if($perform_store) {
    write_file('.timings.json', $json->encode(\%stored_timings));
}

__DATA__

TODO:

  * Percentage slowdown per invocation
  * Overall stats dump at the end.
  * Stop passing bad options to 1.x (--rust, --known)
