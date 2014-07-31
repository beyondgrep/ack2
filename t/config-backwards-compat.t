#!perl -T

use strict;
use warnings;

use lib 't';
use Util;
use File::Temp;
use File::Next ();
use Test::More tests => 3;

prep_environment();

my $old_config = <<'END_CONFIG';
# Always sort
--sort-files

# I'm tired of grouping
--noheading
--break

# Handle .pmc files
--type-set=pmc=.pmc

# Handle .hwd files
--type-set=hwd=.hwd

# Handle .md files
--type-set=md=.mkd
--type-add=md=.md

# Handle .textile files
--type-set=textile=.textile

# Hooray for smart-case!
--smart-case

--ignore-dir=nytprof
END_CONFIG

my $temp_config = File::Temp->new;
print { $temp_config } $old_config;
close $temp_config;

my @args = ( '--ackrc=' . $temp_config->filename, '--md', 'One', 't/swamp/' );

my $file = File::Next::reslash('t/swamp/notes.md');
my $line = 3;

my ( $stdout, $stderr ) = run_ack_with_stderr( @args );
is( scalar(@{$stdout}), 1, 'Got back exactly one line' );
like $stdout->[0], qr/\Q$file:$line\E.*[*] One/;
is_empty_array( $stderr, 'No output to stderr' );
