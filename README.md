# ack 2.0

ack is a code-searching tool, similar to grep but optimized for
programmers searching large trees of source code.  It runs in pure
Perl, is highly portable, and runs on any platform that runs Perl.

ack is written and maintained by Andy Lester (andy@petdance.com).

* Project home page: http://beyondgrep.com/
* Code home page: https://github.com/petdance/ack2
* Issue tracker: https://github.com/petdance/ack2/issues
* Mailing list for users: https://groups.google.com/d/forum/ack-users
* Mailing list for developers: https://groups.google.com/d/forum/ack-dev

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

Build status: [![Build Status](https://travis-ci.org/petdance/ack2.png?branch=dev)](https://travis-ci.org/petdance/ack2)

# Development

Development is *not* done on master.  We use a dev branch named
`dev`, and from there topic branches named for a specific topic.

    master -> dev -> docs
                 \-> speedups
                 \-> issue473

The only time we merge `dev` down to `master` is when doing a
release.  There are no branches off of `master` other than `dev`.
