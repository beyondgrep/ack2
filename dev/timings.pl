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
use Time::HiRes qw(gettimeofday tv_interval);

my $SOURCE_DIR = File::Spec->catdir($ENV{HOME}, 'parrot');

sub grab_versions {
    my @acks = @_;

    my @annotated_acks;

    foreach my $ack (@acks) {
        my $version;

        if($ack =~ /standalone/) {
            $version = 'HEAD';
        } else {
            my $output = `$^X $ack --noenv --version 2>&1`;
            if($output =~ /ack\s+(?<version>\d+[.]\d+(_\d+)?)/) {
                $version = $+{'version'};
                $version =~ s/_//;
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
    my ( $invocations, $acks ) = @_;

    my $max_invocation_length = -1;

    foreach my $invocation (@$invocations) {
        my $length = length(join(' ', 'ack', @$invocation));
        if($length > $max_invocation_length) {
            $max_invocation_length = $length;
        }
    }
    my @max_version_lengths = (length('000.00')) x @$acks;

    for(0..$#$acks) {
        if(length($acks->[$_]{'version'}) > $max_version_lengths[$_]) {
            $max_version_lengths[$_] = length($acks->[$_]{'version'});
        }
    }

    return join(' | ', "%${max_invocation_length}s", map {
        "%${_}s"
    } @max_version_lengths) . "\n";
}

sub time_ack {
    my ( $ack, $invocation, $perl ) = @_;

    my @args = ( $perl, $ack->{'path'}, '--noenv', @$invocation );

    if ( $ack->{'path'} =~ /ack1/ ) {
        @args = grep { !/--known/ } @args;
    }

    my $end;
    my $start = [gettimeofday()];
    my $pid   = fork;

    if($pid) {
        waitpid $pid, 0;
        # XXX handle failure?
        $end = [gettimeofday()];
    } else {
        close STDOUT;
        close STDERR;
        exec @args;
        exit 255;
    }

    return tv_interval($start, $end);
}

my @invocations = (
    # normal mode
    [ 'foo', $SOURCE_DIR ],
    [ 'foo', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ 'foo', '--rust', $SOURCE_DIR ], # where there are little/none
    [ 'foo', '--known', $SOURCE_DIR ],

    # -f
    [ '-f', $SOURCE_DIR ],
    [ '-f', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ '-f', '--rust', $SOURCE_DIR ], # where there are little/none
    [ '-f', '--known', $SOURCE_DIR ],

    # -l
    [ 'foo', '-l', $SOURCE_DIR ],
    [ 'foo', '-l', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ 'foo', '-l', '--rust', $SOURCE_DIR ], # where there are little/none
    [ 'foo', '-l', '--known', $SOURCE_DIR ],

    # -c
    [ 'foo', '-c', $SOURCE_DIR ],
    [ 'foo', '-c', '--cc', $SOURCE_DIR ],   # where there are a lot of matches
    [ 'foo', '-c', '--rust', $SOURCE_DIR ], # where there are little/none
    [ 'foo', '-c', '--known', $SOURCE_DIR ],
);

my $perform_store;
my $perfom_clear;
my @use_acks;
my $perl = $^X;

GetOptions(
    'clear'  => \$perfom_clear,
    'store'  => \$perform_store,
    'ack=s@' => \@use_acks,
    'perl=s' => \$perl,
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
    return $a->{'version'} <=> $b->{'version'};
} @acks;

if($previous_timings) {
    splice @acks, -1, 0, {
        version => 'previous',
    };
}

my $format = create_format(\@invocations, \@acks);
my $header = sprintf $format, '', map { $_->{'version'} } @acks;
print $header;
print '-' x (length($header) - 1), "\n"; # -1 for the newline

my %stored_timings;

foreach my $invocation (@invocations) {
    my @timings;

    foreach my $ack (@acks) {
        unless($ack->{'path'}) {
            push @timings, $previous_timings->{join(' ', 'ack', @$invocation)};
            next;
        }
        my $elapsed = time_ack($ack, $invocation, $perl);
        push @timings, $elapsed;

        if($perform_store && $ack->{'store_timings'}) {
            $stored_timings{join(' ', 'ack', @$invocation)} = $elapsed;
        }
    }
    printf $format, join(' ', 'ack', @$invocation), map { sprintf '%.2f', $_ } @timings;
}

if($perform_store) {
    write_file('.timings.json', $json->encode(\%stored_timings));
}
