# ack 2.0

ack 2.0 is a text searching utility optimized for searching trees of source code.

# Building

ack requires Perl 5.8.8 or higher.  Perl 5.8.8 was released January 2006.

    # Required
    perl Makefile.PL
    make
    make test
    sudo make install # for a system-wide installation (recommended)
    # - or -
    make ack-standalone
    cp ack-standalone ~/bin/ack2 # for a personal installation

# Development

Development is *not* done on master.  We use a dev branch named
`dev`, and from there topic branches named for a specific topic.

    master -> dev -> docs
                 \-> speedups
                 \-> issue473

The only time we merge `dev` down to `master` is when doing a
release.  There are no branches off of `master` other than `dev`.
