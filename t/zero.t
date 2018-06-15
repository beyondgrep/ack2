#!perl -T

=pod

Long ago there was a problem where ack would ignore a file named
"0" because 0 is a false value in Perl.  Here we check to make sure
we don't fall prey to that again.

=cut

use warnings;
use strict;

use Test::More tests => 2;

use lib 't';
use Util;

prep_environment();

my $swamp = 't/swamp';

my @actual_swamp_perl = map { "$swamp/$_" } qw(
    0
    constitution-100k.pl
    Makefile.PL
    options.pl
    options-crlf.pl
    perl.cgi
    perl.handler.pod
    perl.pl
    perl.pm
    perl.pod
    perl-test.t
    perl-without-extension
);

DASH_F: {
    my @args = qw( -f --perl );

    ack_sets_match( [ @args, $swamp ], \@actual_swamp_perl, 'DASH_F' );
}

DASH_F_CWD: {
    my @args = qw( -f --perl --sort-files );

    my @swamp_basenames = map { s{^$swamp/}{}r } @actual_swamp_perl;

    my $wd = getcwd_clean();
    safe_chdir('t/swamp');
    ack_sets_match( [ @args, '.' ], \@swamp_basenames, 'DASH_F_CWD:' );
    safe_chdir($wd);
}
