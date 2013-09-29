package App::Ack::Index;

use warnings;
use strict;

=head1 NAME

App::Ack::Index - Indexing functions for ack.

=head1 FUNCTIONS

=head2 ngrams( $str )

Returns a listref of all the 2-letter ngrams in the string.  An
n-gram, for ack's purposes, is two lowercase letters.

The order of the ngrams is not predictable.  There will be no
repeated ngrams.

=cut

sub ngrams {
    my $line = lc( shift );

    my %ng;
    while ( $line =~ /([a-z]{2,})/g ) {
        my $lump = $1;
        my $i = length($lump) - 1;
        while ( $i-- ) {
            ++$ng{substr( $lump, $i, 2 )};
        }
    }

    return [keys %ng];
}

=head1 COPYRIGHT & LICENSE

Copyright 2005-2013 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

=cut

1; # End of App::Ack::Index
