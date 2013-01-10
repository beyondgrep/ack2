#!perl

use strict;
use warnings;

use Test::More tests => 5;

use App::Ack::Filter;

my $filter;

$filter = eval {
    App::Ack::Filter->create_filter('test');
};

ok( !$filter, 'Creating an unknown filter should fail' );
like( $@, qr/unknown filter/i, 'Got the expected error' );

$INC{'App/Ack/Filter/test.pm'} = 1;

$filter = eval {
    App::Ack::Filter->create_filter('test', qw/foo bar/);
};

ok( $filter, 'Creating a registered filter should succeed' ) or diag($@);
isa_ok( $filter, 'App::Ack::Filter::test', 'Creating a test filter should be a App::Ack::Filter::test' );
is_deeply( $filter, [qw/foo bar/], 'Extra arguments should get passed through to constructor' );


package App::Ack::Filter::test;

use strict;
use warnings;

sub new {
    my ( $class, @args ) = @_;

    return bless \@args, $class;
}

1;
