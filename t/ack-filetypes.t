#!perl

use strict;
use warnings;

use Test::More;

use lib 't';
use Util;

prep_environment();

my @filetypes = qw(
actionscript
ada
asm
batch
cc
cfmx
clojure
cpp
csharp
css
delphi
elisp
erlang
fortran
go
groovy
haskell
hh
html
java
js
jsp
lisp
lua
make
objc
objcpp
ocaml
parrot
perl
php
plone
python
rake
ruby
scala
scheme
shell
smalltalk
sql
tcl
tex
tt
vb
verilog
vhdl
vim
xml
yaml
);

plan tests => scalar(@filetypes);

foreach my $filetype ( @filetypes ) {
    my @args = ( '-f', "--$filetype" );

    my ( undef, $stderr ) = run_ack_with_stderr( @args ); # throw away stdout;
                                                          # we don't care
    is( scalar @{$stderr}, 0, "--$filetype should print no errors" )
        or diag(explain($stderr));
}

done_testing();
