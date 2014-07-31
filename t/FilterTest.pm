package FilterTest;

use strict;
use warnings;
use base 'Exporter';

use App::Ack::Resource::Basic;
use File::Next;
use Util;
use Test::More;

our @EXPORT = qw(filter_test);

sub swamp_files {
    my @swamp_files;

    my $files = File::Next::files( 't/swamp' );
    while ( my $file = $files->() ) {
        push( @swamp_files, $file );
    }

    return @swamp_files;
}

sub filter_test {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $filter_args      = shift;
    my $expected_matches = shift;
    my $msg              = shift or die 'Must pass a message to filter_test()';

    return subtest "filter_test($msg)" => sub {
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
        } swamp_files();

        sets_match(\@matches, $expected_matches, $msg);
    };
}


1;
