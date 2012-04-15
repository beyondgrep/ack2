use strict;
use warnings;

use Test::More;
use Term::ANSIColor qw(color);

use lib 't';
use Util;

if(! __PACKAGE__->can('run_ack_interactive')) {
    plan skip_all => q{You need to install IO::Pty to run this test};
    exit(0);
}

plan tests => 4;

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

INTERACTIVE_GROUPING_COLOR: {
    my @args  = qw( Sue ); # --color is on by default
    my @files = qw( t/text );

    my $output = run_ack_interactive(@args, @files);

    my $CFN    = color 'bold green';
    my $CRESET = color 'reset';
    my $CLN    = color 'bold yellow';
    my $CM     = color 'black on_yellow';

    is $output, <<"END_OUTPUT";
${CFN}t/text/boy-named-sue.txt$CRESET
${CLN}6${CRESET}:Was before he left, he went and named me ${CM}Sue${CRESET}.
${CLN}13${CRESET}:I tell ya, life ain't easy for a boy named ${CM}Sue${CRESET}.
${CLN}27${CRESET}:Sat the dirty, mangy dog that named me ${CM}Sue${CRESET}.
${CLN}34${CRESET}:And I said: "My name is ${CM}Sue${CRESET}! How do you do! Now you gonna die!"
${CLN}62${CRESET}:Cause I'm the son-of-a-bitch that named you ${CM}Sue${CRESET}."
${CLN}70${CRESET}:Bill or George! Anything but ${CM}Sue${CRESET}! I still hate that name!
${CLN}72${CRESET}:    -- "A Boy Named ${CM}Sue${CRESET}", Johnny Cash
END_OUTPUT
}
