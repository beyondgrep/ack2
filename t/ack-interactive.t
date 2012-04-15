use strict;
use warnings;

use Test::More;

use lib 't';
use Util;

if(! __PACKAGE__->can('run_ack_interactive')) {
    plan skip_all => q{You need to install IO::Pty to run this test};
    exit(0);
}

plan tests => 3;

prep_environment();

INTERACTIVE_GROUPING_NOCOLOR: {
    my @args  = qw( Sue --nocolor );
    my @files = qw( t/text );

    my $output = run_ack_interactive(@args, @files);

    is $output, <<'END_OUTPUT';
t/text/boy-named-sue.txt
6:Was before he left, he went and named me Sue.
13:I tell ya, life ain't easy for a boy named Sue.
27:Sat the dirty, mangy dog that named me Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
62:Cause I'm the son-of-a-bitch that named you Sue."
70:Bill or George! Anything but Sue! I still hate that name!
72:    -- "A Boy Named Sue", Johnny Cash
END_OUTPUT
}

INTERACTIVE_NOHEADING_NOCOLOR: {
    my @args  = qw( Sue --nocolor --noheading);
    my @files = qw( t/text );

    my $output = run_ack_interactive(@args, @files);

    is $output, <<'END_OUTPUT';
t/text/boy-named-sue.txt:6:Was before he left, he went and named me Sue.
t/text/boy-named-sue.txt:13:I tell ya, life ain't easy for a boy named Sue.
t/text/boy-named-sue.txt:27:Sat the dirty, mangy dog that named me Sue.
t/text/boy-named-sue.txt:34:And I said: "My name is Sue! How do you do! Now you gonna die!"
t/text/boy-named-sue.txt:62:Cause I'm the son-of-a-bitch that named you Sue."
t/text/boy-named-sue.txt:70:Bill or George! Anything but Sue! I still hate that name!
t/text/boy-named-sue.txt:72:    -- "A Boy Named Sue", Johnny Cash
END_OUTPUT
}

INTERACTIVE_NOGROUP_NOCOLOR: {
    my @args  = qw( Sue --nocolor --nogroup);
    my @files = qw( t/text );

    my $output = run_ack_interactive(@args, @files);

    is $output, <<'END_OUTPUT';
t/text/boy-named-sue.txt:6:Was before he left, he went and named me Sue.
t/text/boy-named-sue.txt:13:I tell ya, life ain't easy for a boy named Sue.
t/text/boy-named-sue.txt:27:Sat the dirty, mangy dog that named me Sue.
t/text/boy-named-sue.txt:34:And I said: "My name is Sue! How do you do! Now you gonna die!"
t/text/boy-named-sue.txt:62:Cause I'm the son-of-a-bitch that named you Sue."
t/text/boy-named-sue.txt:70:Bill or George! Anything but Sue! I still hate that name!
t/text/boy-named-sue.txt:72:    -- "A Boy Named Sue", Johnny Cash
END_OUTPUT
}
