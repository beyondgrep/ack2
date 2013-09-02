# Ack Developer's Guide

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

TODO

### Helpful Makefile rules

## Running Tests

### make test

Runs the `make test_classic` and `make test_standalone` rules.

### make test_classic

Runs the test suite using the module files in the repository.

### make test_standalone

Runs the test suite using the `ack-standalone` script.

### prove -b $TEST_FILE

Can be used to run individual test files.  This relies on the module files being
placed under `blib/lib`, so be sure to run `make` before running `prove`!

### Getting debug output from a test

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

TODO

## Guidelines

### Adding new files to ack2

TODO

## Issues

Our issues are hosted on GitHub.

### Tags

TODO

### Milestones

TODO
