#!perl -T

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
coffeescript
cpp
csharp
css
delphi
elisp
erlang
fortran
go
groovy
gsp
haskell
hh
html
java
js
json
jsp
less
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
rst
ruby
rust
sass
scala
scheme
shell
smalltalk
sql
swift
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

    my ( undef, $stderr ) = run_ack_with_stderr( @args ); # Throw away stdout. We don't care.
    is_empty_array( $stderr, "--$filetype should print no errors" );
}

done_testing();
