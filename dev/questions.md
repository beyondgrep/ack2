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

# More Questions (2011-11-04)

**Q:** When adding a filetype to match a file by extension, regex, or name,
is this comparison case-insenstive? (I'm assuming yes)

**A:** I think that we have to go with case-insensitive, yes.  I
think anything that would rely on something other than that is just
asking for disaster.

**Q:** How about a --check option to just validate that your ackrc is ok?

**A:** Yes, please.

**Q:** Some people might want to install ack via cpan, and sometimes in a perlbrew.  Maybe
another "global" location is needed for ackrc in cases like these? (see File::ShareDir)

**A:** We have to have one ackrc to start with.  I don't think we
want it as a compile-time option or anything like that.  It has to
be /etc/ackrc, and then overrideable via some environment option.

**Q:** Should we worry about character encodings in filenames when adding file types? I'm thinking
this might be something for Ack 2.1.

**A:** No, leave for later.

**Q:** Should --noenv be allowed in config files/ACK\_OPTIONS (ex. if I want to skip my .ackrc, or /etc/ackrc)

**A:** No, --noenv should only be allowed on the command line.  We
should have a test for that.

**Q:** Should we have a --config option for manually adding config files?

**A:** I can imagine a need, but let's not do it if nobody asks for it.

# Ignore Rules (2011-11-13)

**Q:** When a user (or config file) says --ignore-dir=CVS, I'm assuming Ack ignores ./CVS/, ./foo/CVS/, ./foo/bar/CVS/, etc?

**Q:** When a user (or config file) says --ignore-dir=t/swamp, does Ack ignore ./t/swamp/, ./foo/t/swamp/, ./foo/bar/t/swamp/, etc?

**Q:** When a user (or config file) says --ignore-file=foo.txt, does Ack ignore ./foo.txt, ./bar/foo.txt, etc?

**Q:** When a user (or config file) says --ignore-file=docs/foo.txt, does Ack ignore ./docs/foo.txt, ./bar/docs/foo.txt, etc?
