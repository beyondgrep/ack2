package App::Ack::ConfigDefault;

use warnings;
use strict;

sub options {
    my @options = split( /\n/, _options_block() );
    @options = grep { /./ && !/^#/ } @options;

    return @options;
}

sub _options_block {
    return <<'HERE';
# This is the default ackrc for ack 2.0

# There are four different ways to match
#
# is:  Match the filename exactly
#
# ext: Match the extension of the filename exactly
#
# match: Match the filename against a Perl regular expression
#
# firstlinematch: Match the first 250 characters of the first line
#   of text against a Perl regular expression.  This is only for
#   the --type-add option.


### Directories to ignore

# Bazaar
--ignore-directory=is:.bzr

# Codeville
--ignore-directory=is:.cdv

# Interface Builder
--ignore-directory=is:~.dep
--ignore-directory=is:~.dot
--ignore-directory=is:~.nib
--ignore-directory=is:~.plst

# Git
--ignore-directory=is:.git

# Mercurial
--ignore-directory=is:.hg

# quilt
--ignore-directory=is:.pc

# Subversion
--ignore-directory=is:.svn

# Monotone
--ignore-directory=is:_MTN

# CVS
--ignore-directory=is:CVS

# RCS
--ignore-directory=is:RCS

# SCCS
--ignore-directory=is:SCCS

# darcs
--ignore-directory=is:_darcs

# Vault/Fortress
--ignore-directory=is:_sgbak

# autoconf
--ignore-directory=is:autom4te.cache

# Perl module building
--ignore-directory=is:blib
--ignore-directory=is:_build

# Perl Devel::Cover module's output directory
--ignore-directory=is:cover_db

# Node modules created by npm
--ignore-directory=is:node_modules

# CMake cache
--ignore-directory=is:CMakeFiles

# Eclipse workspace folder
--ignore-directory=is:.metadata

### Files to ignore

# Backup files
--ignore-file=ext:bak
--ignore-file=match:/~$/

# Emacs swap files
--ignore-file=match:/^#.+#$/

# vi/vim swap files
--ignore-file=match:/[._].*\.swp$/

# core dumps
--ignore-file=match:/core\.\d+$/

# minified Javascript
--ignore-file=match:/[.-]min[.]js$/
--ignore-file=match:/[.]js[.]min$/

# minified CSS
--ignore-file=match:/[.]min[.]css$/
--ignore-file=match:/[.]css[.]min$/

# PDFs, because they pass Perl's -T detection
--ignore-file=ext:pdf

# Common graphics, just as an optimization
--ignore-file=ext:gif,jpg,jpeg,png


### Filetypes defined

# Perl http://perl.org/
--type-add=perl:ext:pl,pm,pod,t,psgi
--type-add=perl:firstlinematch:/^#!.*\bperl/

# Perl tests
--type-add=perltest:ext:t

# Makefiles http://www.gnu.org/s/make/
--type-add=make:ext:mk
--type-add=make:ext:mak
--type-add=make:is:makefile
--type-add=make:is:Makefile
--type-add=make:is:GNUmakefile

# Rakefiles http://rake.rubyforge.org/
--type-add=rake:is:Rakefile

# CMake http://www.cmake.org/
--type-add=cmake:is:CMakeLists.txt
--type-add=cmake:ext:cmake

# Actionscript
--type-add=actionscript:ext:as,mxml

# Ada http://www.adaic.org/
--type-add=ada:ext:ada,adb,ads

# ASP http://msdn.microsoft.com/en-us/library/aa286483.aspx
--type-add=asp:ext:asp

# ASP.Net http://www.asp.net/
--type-add=aspx:ext:master,ascx,asmx,aspx,svc

# Assembly
--type-add=asm:ext:asm,s

# Batch
--type-add=batch:ext:bat,cmd

# ColdFusion http://en.wikipedia.org/wiki/ColdFusion
--type-add=cfmx:ext:cfc,cfm,cfml

# Clojure http://clojure.org/
--type-add=clojure:ext:clj

# C
# .xs are Perl C files
--type-add=cc:ext:c,h,xs

# C header files
--type-add=hh:ext:h

# CoffeeScript http://coffeescript.org/
--type-add=coffeescript:ext:coffee

# C++
--type-add=cpp:ext:cpp,cc,cxx,m,hpp,hh,h,hxx

# C#
--type-add=csharp:ext:cs

# CSS http://www.w3.org/Style/CSS/
--type-add=css:ext:css

# Dart http://www.dartlang.org/
--type-add=dart:ext:dart

# Delphi http://en.wikipedia.org/wiki/Embarcadero_Delphi
--type-add=delphi:ext:pas,int,dfm,nfm,dof,dpk,dproj,groupproj,bdsgroup,bdsproj

# Elixir http://elixir-lang.org/
--type-add=elixir:ext:ex,exs

# Emacs Lisp http://www.gnu.org/software/emacs
--type-add=elisp:ext:el

# Erlang http://www.erlang.org/
--type-add=erlang:ext:erl,hrl

# Fortran http://en.wikipedia.org/wiki/Fortran
--type-add=fortran:ext:f,f77,f90,f95,f03,for,ftn,fpp

# Google Go http://golang.org/
--type-add=go:ext:go

# Groovy http://groovy.codehaus.org/
--type-add=groovy:ext:groovy,gtmpl,gpp,grunit,gradle

# Haskell http://www.haskell.org/
--type-add=haskell:ext:hs,lhs

# HTML
--type-add=html:ext:htm,html

# Java http://www.oracle.com/technetwork/java/index.html
--type-add=java:ext:java,properties

# JavaScript
--type-add=js:ext:js

# JSP http://www.oracle.com/technetwork/java/javaee/jsp/index.html
--type-add=jsp:ext:jsp,jspx,jhtm,jhtml

# JSON http://www.json.org/
--type-add=json:ext:json

# Less http://www.lesscss.org/
--type-add=less:ext:less

# Common Lisp http://common-lisp.net/
--type-add=lisp:ext:lisp,lsp

# Lua http://www.lua.org/
--type-add=lua:ext:lua
--type-add=lua:firstlinematch:/^#!.*\blua(jit)?/

# Objective-C
--type-add=objc:ext:m,h

# Objective-C++
--type-add=objcpp:ext:mm,h

# OCaml http://caml.inria.fr/
--type-add=ocaml:ext:ml,mli

# Matlab http://en.wikipedia.org/wiki/MATLAB
--type-add=matlab:ext:m

# Parrot http://www.parrot.org/
--type-add=parrot:ext:pir,pasm,pmc,ops,pod,pg,tg

# PHP http://www.php.net/
--type-add=php:ext:php,phpt,php3,php4,php5,phtml
--type-add=php:firstlinematch:/^#!.*\bphp/

# Plone http://plone.org/
--type-add=plone:ext:pt,cpt,metadata,cpy,py

# Python http://www.python.org/
--type-add=python:ext:py
--type-add=python:firstlinematch:/^#!.*\bpython/

# R http://www.r-project.org/
--type-add=rr:ext:R

# Ruby http://www.ruby-lang.org/
--type-add=ruby:ext:rb,rhtml,rjs,rxml,erb,rake,spec
--type-add=ruby:is:Rakefile
--type-add=ruby:firstlinematch:/^#!.*\bruby/

# Rust http://www.rust-lang.org/
--type-add=rust:ext:rs

# Sass http://sass-lang.com
--type-add=sass:ext:sass,scss

# Scala http://www.scala-lang.org/
--type-add=scala:ext:scala

# Scheme http://groups.csail.mit.edu/mac/projects/scheme/
--type-add=scheme:ext:scm,ss

# Shell
--type-add=shell:ext:sh,bash,csh,tcsh,ksh,zsh,fish
--type-add=shell:firstlinematch:/^#!.*\b(?:ba|t?c|k|z|fi)?sh\b/

# Smalltalk http://www.smalltalk.org/
--type-add=smalltalk:ext:st

# SQL http://www.iso.org/iso/catalogue_detail.htm?csnumber=45498
--type-add=sql:ext:sql,ctl

# Tcl http://www.tcl.tk/
--type-add=tcl:ext:tcl,itcl,itk

# LaTeX http://www.latex-project.org/
--type-add=tex:ext:tex,cls,sty

# Template Toolkit http://template-toolkit.org/
--type-add=tt:ext:tt,tt2,ttml

# Visual Basic
--type-add=vb:ext:bas,cls,frm,ctl,vb,resx

# Verilog
--type-add=verilog:ext:v,vh,sv

# VHDL http://www.eda.org/twiki/bin/view.cgi/P1076/WebHome
--type-add=vhdl:ext:vhd,vhdl

# Vim http://www.vim.org/
--type-add=vim:ext:vim

# XML http://www.w3.org/TR/REC-xml/
--type-add=xml:ext:xml,dtd,xsl,xslt,ent
--type-add=xml:firstlinematch:/<[?]xml/

# YAML http://yaml.org/
--type-add=yaml:ext:yaml,yml
HERE
}

1;
