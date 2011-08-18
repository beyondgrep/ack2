# Matching multiple interpreters on the shebang line (2011-08-16)

**Q:** From what I understand, shebang matches look for a regular expression
like this:

    m|^#!/usr/bin/(?<interpeter>\w+)|

and looks up `$+{'interpreter'}` in a hash for its corresponding
language (or some similar algorithm).  What if the shebang line is
`#!perl`? Or `#!/usr/bin/env perl`?

**A:** The rules for filetypes are all going to be defined in one of the various `ackrc` files.

For example, here are config lines for detecting Perl files:

    --type-add=perl,ext,pod
    --type-add=perl,ext,pl
    --type-add=perl,ext,pm
    --type-add=perl,firstlinematch,/perl/

In this case, the `firstlinematch` type says "If the first line of
the file matches the regex `/perl/` (where the slashes are regex
delimiters, not part of a path we expect to match).

# Extensionless files (2011-08-16)

**Q:** Will it be possible with ack2, to match extension-less files? Ex.
I'd like to match the file `groceries`, but not `groceries.txt`.

**A:** Yes, definitely.  As with checking the shebang lines, the rules are in the `ackrc` file.

Here are sample lines for matching a makefile:

    --type-add=make,ext,mk
    --type-add=make,ext,mak
    --type-add=make,is,makefile
    --type-add=make,is,gnumakefile

These rules would match the files `foo.mk`, `foo.mak` and `makefile`,
but would not match `makefile.in` or `test.makefile`.

**Q:** What if I want to search all files in a directory structure with no extension?  Can
I do `--type-add=plain,ext,`?

**A:** In ack 2.0, the default will be to search all text files.
Filetypes only come into it if you want to exclude or include by
type.

That said, I'm wondering if we need a meta-type of "unknown".

# FatPacker (2011-08-16)

**Q:** Have you looked into using FatPacker at all?  I don't see
anything wrong with your squash system, but people are already
familiar with FatPacker.

**A:** I know of it, but unless there's benefit in using it over
the existing squash, I don't want to use it.  The only external
dependency ack should have is on File::Next.
