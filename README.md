# Build status of dev branch

* Linux [![Build Status](https://travis-ci.org/beyondgrep/ack2.png?branch=dev)](https://travis-ci.org/beyondgrep/ack2)
* Windows [![Build Status](https://ci.appveyor.com/api/projects/status/github/beyondgrep/ack2)](https://ci.appveyor.com/project/petdance/ack2)
* [CPAN Testers](http://cpantesters.org/distro/A/ack.html)

# ack 2

ack is a code-searching tool, similar to grep but optimized for
programmers searching large trees of source code.  It runs in pure
Perl, is highly portable, and runs on any platform that runs Perl.

ack is written and maintained by Andy Lester (andy@petdance.com).

* Project home page: https://beyondgrep.com/
* Code home page: https://github.com/beyondgrep/ack2
* Issue tracker: https://github.com/beyondgrep/ack2/issues
* Mailing list for announcements: https://groups.google.com/d/forum/ack-announcements
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

# Development

[Developer's Guide](DEVELOPERS.md)

[Design Guide](DESIGN.md)
