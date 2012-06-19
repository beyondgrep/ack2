#!perl

use warnings;
use strict;

use Test::More tests => 1;

use lib 't';
use Util;

prep_environment();


subtest 'No restrictions on type' => sub {
    my $expected = <<'HERE';
t/etc/buttonhook.xml.xxx => xml
t/etc/shebang.empty.xxx =>
t/etc/shebang.foobar.xxx =>
t/etc/shebang.php.xxx => php
t/etc/shebang.pl.xxx => perl
t/etc/shebang.py.xxx => python
t/etc/shebang.rb.xxx => ruby
t/etc/shebang.sh.xxx => shell
HERE
    my @expected = reslash_all( break_up_lines( $expected ) );

    my @args = qw( -f --show-types t/etc );
    ack_sets_match( [ @args ], \@expected );
};

done_testing();
