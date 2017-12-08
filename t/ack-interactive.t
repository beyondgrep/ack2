#!perl -T

use strict;
use warnings;

use Test::More;
use Term::ANSIColor qw(color);

use lib 't';
use Util;

if ( not has_io_pty() ) {
    plan skip_all => q{You need to install IO::Pty to run this test};
    exit(0);
}

plan tests => 6;

prep_environment();

INTERACTIVE_GROUPING_NOCOLOR: {
    my @args  = qw( free --nocolor --sort-files );
    my @files = qw( t/text );

    my $output = run_ack_interactive(@args, @files);

    is $output, <<'END_OUTPUT';
t/text/bill-of-rights.txt
4:or prohibiting the free exercise thereof; or abridging the freedom of
10:A well regulated Militia, being necessary to the security of a free State,

t/text/constitution.txt
32:Number of free Persons, including those bound to Service for a Term

t/text/gettysburg.txt
23:shall have a new birth of freedom -- and that government of the people,
END_OUTPUT
}

INTERACTIVE_NOHEADING_NOCOLOR: {
    my @args  = qw( free --nocolor --noheading --sort-files );
    my @files = qw( t/text );

    my $output = run_ack_interactive(@args, @files);

    is $output, <<'END_OUTPUT';
t/text/bill-of-rights.txt:4:or prohibiting the free exercise thereof; or abridging the freedom of
t/text/bill-of-rights.txt:10:A well regulated Militia, being necessary to the security of a free State,
t/text/constitution.txt:32:Number of free Persons, including those bound to Service for a Term
t/text/gettysburg.txt:23:shall have a new birth of freedom -- and that government of the people,
END_OUTPUT
}

INTERACTIVE_NOGROUP_NOCOLOR: {
    my @args  = qw( free --nocolor --nogroup --sort-files );
    my @files = qw( t/text );

    my $output = run_ack_interactive(@args, @files);

    is $output, <<'END_OUTPUT';
t/text/bill-of-rights.txt:4:or prohibiting the free exercise thereof; or abridging the freedom of
t/text/bill-of-rights.txt:10:A well regulated Militia, being necessary to the security of a free State,
t/text/constitution.txt:32:Number of free Persons, including those bound to Service for a Term
t/text/gettysburg.txt:23:shall have a new birth of freedom -- and that government of the people,
END_OUTPUT
}

INTERACTIVE_GROUPING_COLOR: {
    my @args  = qw( free --sort-files ); # --color is on by default
    my @files = qw( t/text );

    my $CFN      = color 'bold green';
    my $CRESET   = color 'reset';
    my $CLN      = color 'bold yellow';
    my $CM       = color 'black on_yellow';
    my $LINE_END = "\e[0m\e[K";

    my @expected_lines = split( /\n/, <<"EOF" );
${CFN}t/text/bill-of-rights.txt${CRESET}
${CLN}4${CRESET}:or prohibiting the ${CM}free${CRESET} exercise thereof; or abridging the ${CM}free${CRESET}dom of$LINE_END
${CLN}10${CRESET}:A well regulated Militia, being necessary to the security of a ${CM}free${CRESET} State,$LINE_END

${CFN}t/text/constitution.txt${CRESET}
${CLN}32${CRESET}:Number of ${CM}free${CRESET} Persons, including those bound to Service for a Term$LINE_END

${CFN}t/text/gettysburg.txt${CRESET}
${CLN}23${CRESET}:shall have a new birth of ${CM}free${CRESET}dom -- and that government of the people,$LINE_END
EOF

    my @lines = run_ack_interactive(@args, @files);

    lists_match( \@lines, \@expected_lines, 'INTERACTIVE_GROUPING_COLOR' );
}

INTERACTIVE_SINGLE_TARGET: {
    my @args = qw( (nevermore) -i --nocolor );
    my @files = qw( t/text/raven.txt );

    my $output = run_ack_interactive(@args, @files);

    is $output, <<'END_OUTPUT';
    Quoth the Raven, "Nevermore."
    With such name as "Nevermore."
    Then the bird said, "Nevermore."
    Of 'Never -- nevermore.'
    Meant in croaking "Nevermore."
    She shall press, ah, nevermore!
    Quoth the Raven, "Nevermore."
    Quoth the Raven, "Nevermore."
    Quoth the Raven, "Nevermore."
    Quoth the Raven, "Nevermore."
    Shall be lifted--nevermore!
END_OUTPUT
}

INTERACTIVE_NOCOLOR_REGEXP_CAPTURE: {
    my @args = qw( (nevermore) -i --nocolor );
    my @files = qw( t/text/raven.txt );

    my $output = run_ack_interactive(@args, @files);

    is $output, <<'END_OUTPUT';
    Quoth the Raven, "Nevermore."
    With such name as "Nevermore."
    Then the bird said, "Nevermore."
    Of 'Never -- nevermore.'
    Meant in croaking "Nevermore."
    She shall press, ah, nevermore!
    Quoth the Raven, "Nevermore."
    Quoth the Raven, "Nevermore."
    Quoth the Raven, "Nevermore."
    Quoth the Raven, "Nevermore."
    Shall be lifted--nevermore!
END_OUTPUT
}
