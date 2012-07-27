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

NO_PAGER: {
    my @args = qw(--nocolor Sue t/text);

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
6:Was before he left, he went and named me Sue.
13:I tell ya, life ain't easy for a boy named Sue.
27:Sat the dirty, mangy dog that named me Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
62:Cause I'm the son-of-a-bitch that named you Sue."
70:Bill or George! Anything but Sue! I still hate that name!
72:    -- "A Boy Named Sue", Johnny Cash
END_TEXT

    my @got = run_ack_interactive(@args);

    lists_match(\@got, \@expected);
}

PAGER: {
    my @args = qw(--nocolor --pager=./test-pager Sue t/text);

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
6:Was before he left, he went and named me Sue.
13:I tell ya, life ain't easy for a boy named Sue.
27:Sat the dirty, mangy dog that named me Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
62:Cause I'm the son-of-a-bitch that named you Sue."
70:Bill or George! Anything but Sue! I still hate that name!
72:    -- "A Boy Named Sue", Johnny Cash
END_TEXT

    my @got = run_ack_interactive(@args);

    lists_match(\@got, \@expected);
}

PAGER_WITH_OPTS: {
    my @args = ('--nocolor', '--pager=./test-pager --skip=2', 'Sue', 't/text');

    my @expected = split /\n/, <<'END_TEXT';
t/text/boy-named-sue.txt
13:I tell ya, life ain't easy for a boy named Sue.
34:And I said: "My name is Sue! How do you do! Now you gonna die!"
70:Bill or George! Anything but Sue! I still hate that name!
END_TEXT

    my @got = run_ack_interactive(@args);

    lists_match(\@got, \@expected);
}
