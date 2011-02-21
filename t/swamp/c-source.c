/*  A Bison parser, made from plural.y
    by GNU Bison version 1.28  */

#define YYBISON 1  /* Identify Bison output.  */

/*
 Contains the
 magic string --noenv
 which can be tricky to find.
 */

#define yyparse __gettextparse
#define yylex __gettextlex
#define yyerror __gettexterror
#define yylval __gettextlval
#define yychar __gettextchar
#define yydebug __gettextdebug
#define yynerrs __gettextnerrs
#define	EQUOP2	257
#define	CMPOP2	258
#define	ADDOP2	259
#define	MULOP2	260
#define	NUMBER	261

#line 1 "plural.y"

/* Expression parsing for plural form selection.
   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
   Written by Ulrich Drepper <drepper@cygnus.com>, 2000.

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU Library General Public License as published
   by the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
   USA.  */

/* The bison generated parser uses alloca.  AIX 3 forces us to put this
   declaration at the beginning of the file.  The declaration in bison's
   skeleton file comes too late.  This must come before <config.h>
   because <config.h> may include arbitrary system headers.  */
static void
yyerror (str)
     const char *str;
{
  /* Do nothing.  We don't print error messages here.  */
}
