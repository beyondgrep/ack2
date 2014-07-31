#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin;
use File::Spec;

my $ok = eval { require Test::Perl::Critic::Progressive; 1 };
if ( !$ok ) {
    plan skip_all => 'T::P::C::Progressive required for this test';
    exit;
}

my @files = (
    File::Spec->catfile($FindBin::Bin, '..', 'ack'),
    map { glob }
    map { File::Spec->catfile($FindBin::Bin, '..', @{$_}) }
    (['*.pm'], ['t', '*.t'])
);

Test::Perl::Critic::Progressive::set_critic_args(
    -profile => File::Spec->catfile($FindBin::Bin, '..', 'perlcriticrc'),
);
Test::Perl::Critic::Progressive::progressive_critic_ok(@files);
