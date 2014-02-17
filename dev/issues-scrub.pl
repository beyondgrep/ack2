#!/usr/bin/env perl

# This script is intended for Ack maintainers; we *really* like our items
# in the issue tracker to be properly labelled and have milestones.  So
# this script finds any that don't satisfy both criteria and lets the
# maintainer know.

use strict;
use warnings;
use feature 'say';

use Net::GitHub;

sub retrieve_issues {
    my $gh     = Net::GitHub->new;
    $gh->set_default_user_repo('petdance', 'ack2');
    my $issue  = $gh->issue;
    my @issues = $issue->repos_issues( { state => 'open', per_page => 100 });

    while($issue->has_next_page) {
        push @issues, $issue->next_page;
    }

    return @issues;
}

my @issues = retrieve_issues();

foreach my $issue (@issues) {
    my $is_pull_request = defined($issue->{'pull_request'}{'html_url'});

    next if $is_pull_request;

    my $labels    = $issue->{'labels'};
    my $milestone = $issue->{'milestone'};
    my $url       = $issue->{'html_url'};
    my $number    = $issue->{'number'};

    say "Issue #$number has no labels! ($url)" unless @{$labels};
    say "Issue #$number has no milestone! ($url)" unless $milestone;
}
