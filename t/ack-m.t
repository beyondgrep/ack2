use strict;
use warnings;

use Test::More tests => 4;

use lib 't';
use Util;

prep_environment();

my $target_file = File::Next::reslash( 't/text/boy-named-sue.txt' );

my @expected = split( /\n/, <<"EOF" );
$target_file:6:Was before he left, he went and named me Sue.
$target_file:13:I tell ya, life ain't easy for a boy named Sue.
$target_file:27:Sat the dirty, mangy dog that named me Sue.
$target_file:34:And I said: "My name is Sue! How do you do! Now you gonna die!"
$target_file:62:Cause I'm the son-of-a-bitch that named you Sue."
EOF

ack_lists_match( [ '-m', 5, 'Sue', 't/text' ], \@expected );

@expected = split( /\n/, <<"EOF" );
$target_file:6:Was before he left, he went and named me Sue.
EOF

ack_lists_match( [ '-1', 'Sue', 't/text' ], \@expected );
