package FilterTest;

use strict;
use warnings;
use base 'Exporter';

use App::Ack::Resource::Basic;
use File::Find;
use Util;
use Test::More;

our @EXPORT = qw(filter_test);

my @swamp_files;

find(sub {
    push @swamp_files, $File::Find::name if -f;
}, 't/swamp');

sub filter_test {
    my ( $filter_args, $expected_matches, $msg ) = @_;

    $msg ||= 'filter test for ' . $filter_args->[0];

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    subtest $msg => sub {
        my $filter = eval {
            App::Ack::Filter->create_filter(@{$filter_args});
        };

        ok($filter) or diag($@);

        my @matches = map {
            $_->name
        } grep {
            $filter->filter($_)
        } map {
            App::Ack::Resource::Basic->new($_)
        } @swamp_files;

        sets_match(\@matches, $expected_matches);
    };
}


1;
