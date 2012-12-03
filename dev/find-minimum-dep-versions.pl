#!/usr/bin/env perl

# This script looks through the list of dependencies in
# @dependencies (see below) and tries to find the minimum
# version of each with which ack2 will run.
#
# This script considers each version in isolation, so
# it won't catch things like "Getopt::Long 10 + File::Spec 5 works,
# Getopt::Long 5 + File::Spec 10 works, but Getopt::Long 5 +
# File::Spec 5 doesn't work".  I figured this would be acceptable,
# and I didn't want the script to work through the exponential number
# of combinations.

use strict;
use warnings;
use feature 'say';

use Capture::Tiny qw(capture_merged);
use File::Spec;
use File::Temp;
use MetaCPAN::API;

# ANSI terminal control codes
my $SAVE         = "\e[s";
my $UNSAVE       = "\e[u";
my $ERASE_TO_END = "\e[K";

sub get_releases {
    my ( $module ) = @_;

    my $mcpan  = MetaCPAN::API->new;
    my $distribution = $mcpan->fetch(
        'module/' . $module,
    )->{'distribution'};

    my $from = 0;
    my $hits;
    my @releases;

    do {
        my $result = $mcpan->post(
            release => {
                query => {
                    term => {
                        'release.distribution' => $distribution,
                    },
                },
                filter => {
                    term => {
                        maturity => 'released',
                    },
                },
                sort => [
                    { version => 'asc' },
                ],
                from   => $from,
                fields => [qw/download_url version/],
            },
        );

        $hits  = $result->{'hits'}{'hits'};
        $from += @$hits;

        if(@$hits) {
            foreach my $hit (@$hits) {
                push @releases, {
                    version => $hit->{'fields'}{'version'},
                    url     => $hit->{'fields'}{'download_url'},
                },
            }
        }
    } while(@$hits);

    return @releases;
}

sub bisect (&@) {
    my ( $predicate, @values ) = @_;

    my $low  = 0;
    my $high = @values;
    my $last_good;

    while($low <= $high) {
        my $middle = $low + int(($high - $low) / 2);
        local $_ = $values[$middle];
        my $result = $predicate->($_);

        if($result) {
            $last_good = $_;
            $high = $middle - 1;
        } else {
            $low = $middle + 1;
        }
    }

    return $last_good;
}

my @dependencies = (
    'Carp',
    'Cwd',
    'File::Glob',
    'File::Next',
    'File::Spec',
    'File::Temp',
    'Getopt::Long',
    'Text::ParseWords',
);

my @output;

local $| = 1;
foreach my $dep (@dependencies) {
    print "Testing $dep... $SAVE";

    my @releases = get_releases($dep);
    my $first_good_release = bisect {
        print "$UNSAVE$ERASE_TO_END$_->{'version'}";
        my $tempdir = File::Temp->newdir;
        my $status;
        capture_merged {
            system 'cpanm', '--notest', '--local-lib', $tempdir->dirname, $_->{'url'};

            local $ENV{'PERL5LIB'} = File::Spec->catdir($tempdir->dirname, 'lib/perl5');

            $status = system 'make', 'test';
        };

        $status == 0
    } @releases;

    print "\n";
    push @output, "$dep - $first_good_release->{'version'}";
}

print "\n";
say foreach @output;
