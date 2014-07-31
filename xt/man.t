#!perl

use strict;
use warnings;
use lib 't';

use Test::More;
use Util;

sub strip_special_chars {
    my ( $s ) = @_;

    $s =~ s/.[\b]//g;
    $s =~ s/\e\[?.*?[\@-~]//g;

    return $s;
}

{
    my $man_options;

    sub _populate_man_options {
        my ( $man_output, undef ) = run_ack_with_stderr( '--man' );

        my $in_options_section;

        my @option_lines;

        foreach my $line ( @{$man_output} ) {
            $line = strip_special_chars($line);

            if ( $line =~ /^OPTIONS/ ) {
                $in_options_section = 1;
            }
            elsif ( $in_options_section ) {
                if ( $line =~ /^\S/ ) {
                    $in_options_section = 0;
                    last;
                }
                else {
                    push @option_lines, $line;
                }
            }
        }
        my $min_indent;

        foreach my $line ( @option_lines ) {
            if ( my ( $indent ) = $line =~ /^(\s+)/ ) {
                $indent =~ s/\t/        /;
                $indent = length($indent);

                if ( !defined($min_indent) || $indent < $min_indent ) {
                    $min_indent = $indent;
                }
            }
        }
        $man_options = [];
        foreach my $line ( @option_lines ) {
            if ( $line =~ /^(\s+)/ ) {
                my $indent_str = $1;
                $indent_str    =~ s/\t/        /;
                my $indent     = length($indent_str);

                next unless $indent == $min_indent;

                my @options;

                while ( $line =~ /(-[^\s=,]+)/g ) {
                    my $option = $1;
                    chop $option if $option =~ /\[$/;
                    if ( $option =~ s/^--\[no\]/--/ ) {
                        my $negated_option = $option;
                        substr $negated_option, 2, 0, 'no';
                        push @{$man_options}, $negated_option;
                    }
                    push @{$man_options}, $option;
                }
            }
        }

        return;
    }

    sub get_man_options {
        _populate_man_options() unless $man_options;
        return @{ $man_options };
    }
}

sub check_for_option_in_man_output {
    my ( $expected_option ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my @options = get_man_options();

    my $found;

    foreach my $option ( @options ) {
        if ( $option eq $expected_option ) {
            $found = 1;
            last;
        }
    }

    return ok( $found, "Option '$expected_option' found in --man output" );
}

my @options = get_options();

plan tests => scalar(@options);

prep_environment();

foreach my $option ( @options ) {
    check_for_option_in_man_output( $option );
}
