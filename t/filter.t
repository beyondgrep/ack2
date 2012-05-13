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

App::Ack::Filter->register_filter(test => 'TestFilter');

$filter = eval {
    App::Ack::Filter->create_filter('test', qw/foo bar/);
};

ok( $filter, 'Creating a registered filter should succeed' ) or diag($@);
isa_ok( $filter, 'TestFilter', 'Creating a test filter should be a TestFilter' );
is_deeply( $filter, [qw/foo bar/], 'Extra arguments should get passed through to constructor' );


package TestFilter;

use strict;
use warnings;

sub new {
    my ( $class, @args ) = @_;

    return bless \@args, $class;
}

1;
