package App::Ack::Resource;

use App::Ack;

use warnings;
use strict;

sub FAIL {
    require Carp;
    Carp::confess( 'Must be overloaded' );
}

=head1 SYNOPSIS

This is the base class for App::Ack::Resource and any resources
that derive from it.

=head1 METHODS

=head2 new( $filename )

Opens the file specified by I<$filename> and returns a filehandle and
a flag that says whether it could be binary.

If there's a failure, it throws a warning and returns an empty list.

=cut

sub new {
    FAIL();
}

=head2 $res->name()

Returns the name of the resource.

=cut

sub name {
    FAIL();
}

=head2 $res->is_binary()

Tells whether the resource is binary.  If it is, and ack finds a
match in the file, then ack will not try to display a match line.

=cut

sub is_binary {
    FAIL();
}


=head2 $res->needs_line_scan( \%opts )

API: Tells if the resource needs a line-by-line scan.  This is a big
optimization because if you can tell from the outset that the pattern
is not found in the resource at all, then there's no need to do the
line-by-line iteration.  If in doubt, return true.

Base: Slurp up an entire file up to 100K, see if there are any
matches in it, and if so, let us know so we can iterate over it
directly.  If it's bigger than 100K or the match is inverted, we
have to do the line-by-line, too.

=cut

sub needs_line_scan {
    FAIL();
}

=head2 $res->reset()

Resets the resource back to the beginning.  This is only called if
C<needs_line_scan()> is true, but not always if C<needs_line_scan()>
is true.

=cut

sub reset {
    FAIL();
}

=head2 $res->next_text()

API: Gets the next line of text from the resource.  Returns true
if there is one, or false if not.

Sets C<$_> with the line of text, and C<$.> for the ID number of
the text.  This basically emulates a call to C<< <$fh> >>.

=cut

sub next_text {
    FAIL();
}

=head2 $res->close()

API: Close the resource.

=cut

sub close {
    FAIL();
}

1;
