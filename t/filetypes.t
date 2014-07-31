#!perl -T

use warnings;
use strict;

use Test::More;
use File::Next;

use lib 't';
use Util;

my %types_for_file;

sub populate_filetypes {
    my ( $type_lines, undef ) = run_ack_with_stderr('--help-types');

    my @types_to_try;

    foreach my $line (@{$type_lines}) {
        if($line =~ /^\s+--\[no\](\w+)/) {
            push @types_to_try, $1;
        }
    }

    foreach my $type (@types_to_try) {
        my ( $filenames, undef ) = run_ack_with_stderr('-f', "--$type",
            't/swamp', 't/etc');

        foreach my $filename ( @{$filenames} ) {
            push @{ $types_for_file{$filename} }, $type;
        }
    }

    return;
}

# XXX implement me with --show-types!
sub filetypes {
    my $filename = File::Next::reslash(shift);

    if ( !%types_for_file ) {
        populate_filetypes();
    }

    return @{ $types_for_file{$filename} || [] };
}

sub is_filetype {
    my ( $filename, $wanted_type ) = @_;

    for my $maybe_type ( filetypes( $filename ) ) {
        return 1 if $maybe_type eq $wanted_type;
    }

    return;
}

prep_environment();

sets_match( [filetypes( 't/swamp/perl.pod' )], [qw( parrot perl )], 'foo.pod can be multiple things' );
sets_match( [filetypes( 't/swamp/perl.pm' )], [qw( perl )], 't/swamp/perl.pm' );
sets_match( [filetypes( 't/swamp/Makefile.PL' )], [qw( perl )], 't/swamp/Makefile.PL' );
sets_match( [filetypes( 'Unknown.wango' )], [], 'Unknown' );

ok(  is_filetype( 't/swamp/perl.pod', 'perl' ), 'foo.pod can be perl' );
ok(  is_filetype( 't/swamp/perl.pod', 'parrot' ), 'foo.pod can be parrot' );
ok( !is_filetype( 't/swamp/perl.pod', 'ruby' ), 'foo.pod cannot be ruby' );
ok(  is_filetype( 't/swamp/perl.handler.pod', 'perl' ), 'perl.handler.pod can be perl' );
ok(  is_filetype( 't/swamp/Makefile', 'make' ), 'Makefile is a makefile' );
ok(  is_filetype( 't/swamp/Rakefile', 'rake' ), 'Rakefile is a rakefile' );

is_empty_array( [filetypes('t/swamp/#emacs-workfile.pl#')], 'correctly skip files starting and ending with hash mark' );

MATCH_VIA_CONTENT: {
    my %lookups = (
        't/swamp/Makefile'          => 'make',
        't/swamp/Makefile.PL'       => 'perl',
        't/etc/shebang.php.xxx'     => 'php',
        't/etc/shebang.pl.xxx'      => 'perl',
        't/etc/shebang.py.xxx'      => 'python',
        't/etc/shebang.rb.xxx'      => 'ruby',
        't/etc/shebang.sh.xxx'      => 'shell',
        't/etc/buttonhook.xml.xxx'  => 'xml',
    );
    for my $filename ( sort keys %lookups ) {
        my $type = $lookups{$filename};
        sets_match( [filetypes( $filename )], [ $type ], "Checking $filename" );
    }
}

done_testing;
