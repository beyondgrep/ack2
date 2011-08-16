# Matching shebang line

**Q:** From what I understand, shebang matches look for a regular expression
like this:

    m|^#!/usr/bin/(?<interpeter>\w+)|

and looks up `$+{'interpreter'}` in a hash for its corresponding
language (or some similar algorithm).  What if the shebang line is
`#!perl`? Or `#!/usr/bin/env perl`?

# Extensionless files

**Q:** Will it be possible with ack2, to match extension-less files? Ex.
I'd like to match the file `groceries`, but not `groceries.txt`.

# FatPacker

**Q:** Have you looked into using FatPacker at all?  I don't see
anything wrong with your squash system, but people are already
familiar with FatPacker.
