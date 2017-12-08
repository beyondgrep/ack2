# Ack Developer's Guide

This is a guide intended to help new developers work on ack.  You may also want to read
[CONTRIBUTING.md](https://github.com/beyondgrep/ack2/blob/dev/CONTRIBUTING.md).

## Helper Scripts

### tack

The `tack` script runs ack from repository root using the module files placed under `blib/lib` via
the build process.  It's a quick and easy way to try out new code, or to check some debugging
output.  Since it relies on the module files under `blib/lib`, make sure you run `make` before
running `tack`!

### ack-standalone

This script is built by the `make ack-standalone` rule, and is a single file distribution of ack.
The `make ack-standalone` rule uses the `squash` script to perform the actual building.

### squash

Takes a list of Perl source files and builds a single Perl script containing all of the input
files.

### dev/timings.pl

Times ack in a number of common scenarios.  We currently use a checkout of the Parrot repository
for testing, as it's a medium sized codebase.  `dev/timings.pl` expects a checkout of the Parrot
repository in your `$HOME` directory.  See `dev/timings.pl --help` for more information on its
options.

### dev/display-option-coverage.pl

The test suite can build what we call an "option coverage" file if the `ACK_OPTION_COVERAGE`
environment variable is set to a truthy value.  The option coverage file lists all of the options
provided to the various options provided to the various invocations of ack used in the test suite.
`dev/display-options-coverage.pl` reads this file and prints the options that are *not* used in
the test suite.  This helps find new options that haven't had tests written for them yet.

### Helpful Makefile rules

#### nytprof

Runs ack through `Devel::NYTProf`.

#### timings

Shorthand for `dev/timings.pl`.

## Running Tests

### `make test`

Runs the `make test_classic` and `make test_standalone` rules.

### `make test_classic`

Runs the test suite using the module files in the repository.

### `make test_standalone`

Runs the test suite using the `ack-standalone` script.

### `prove -b $TEST_FILE`

Can be used to run individual test files.  This relies on the module files being
placed under `blib/lib`, so be sure to run `make` before running `prove`!

## Branching

Development is *not* done on master.  We use a dev branch named
`dev`, and from there topic branches named for a specific topic.

    master -> dev -> docs
                 \-> speedups
                 \-> issue473

The only time we merge `dev` down to `master` is when doing a
release.  There are no branches off of `master` other than `dev`.

## Coding Standards

Our policy on commits is that they're cheap; we tend to throw files
into the repository that could prove useful to others, even if we
will remove them later.

### perlcritic/perltidy

We have a perlcriticrc and a perltidyrc file for checking the Perl source
files.

## How to cut a release

### For all releases

These can be done by anyone, except for the upload to CPAN.

* Prep all source files for release.
    * If this is a final release, replace all `2.XX_01` version numbers with `2.YY`, where XX is odd and YY is even.
    * Update the `Changes` file with the new version numbers and put a date in the header.
* `make clean` and `make test` repeatedly.
* `make disttest`
    * Should pass.
* `make tardist`
    * Creates a tarball
* Upload the tarball to pause.cpan.org
* Tag the release
    * `git tag 2.XX`
    * `git push --tags`

### For an official release (like `2.06`)

Do all of the above for a development release, plus:

* Put a version of standalone into the garage.
* Update beyondgrep.com
    * https://github.com/beyondgrep/website
    * Front page version number
    * man page archive
* Announce it
    * Mail to ack-users and ack-announce.
    * Post to ack's Google+ page.
    * Tweet on @beyondgrep.

## Guidelines

### Adding new files to ack2

TODO

## Issues

Our issues are hosted on GitHub.

https://github.com/beyondgrep/ack2/issues

### Tags

TODO

## But I Can't Contribute to ack, because...

### ...I don't have any spare time.

I know how you feel!  But any contribution is welcome; you don't need to be a full-time contributor.
Every test file, every issue solved, every bug fixed matters!

### ...I don't know Perl.

That's ok; it's easy to learn!  Perl may have a reputation for being unreadable, but ack is written
in a very easy-to-read style.

TODO Mention http://perl-begin.org/

### ...I don't know where to start.

TODO

## How do I...?

### ...add a new command line option?

TODO

### MORE
