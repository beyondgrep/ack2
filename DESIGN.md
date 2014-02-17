# ack2 design

Here we try to document ack's design, including design decisions
that have already been made, so that we don't keep rehashing them.

# Design choices that are inviolate.

* ack will not do replacing of text.  It is not a replacement for sed.

* ack will only use core Perl modules and File::Next.  No other modules may be required.

* ack must be able to be built as a single-file standalone file.

* ack must be cross-platform.  Specifically, it must run on Windows.

# Design questions that have been investigated

## Would ack be faster if we used the integer pragma?

It seems not.  Brian M. Carlson investigated this and reported his
findings here: https://github.com/petdance/ack2/issues/398

There seemed to be no effect.
