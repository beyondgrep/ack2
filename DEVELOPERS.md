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

### Getting debug output from a test

ack's test suite captures standard output and standard error, so writing debug messages
to standard error will show up in the captured output, and cause the test suite to fail.
We have an `App::Ack::Debug` module for emitting test-safe debugging output, but it doesn't
get placed under `blib` by default.

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
    * https://github.com/petdance/beyondgrep
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

### Tags

TODO

### Milestones

#### 2.0x

Issues with this milestone should be resolved on the `dev` branch.  These
are usually bug fixes.

#### 2.1

XXX I want to not call this "2.1" because it conflates with "2.10"
which is coming soon.  Let's give it some easy-to-type textual name,
like "goober" or "lemon" or who knows what.

Issues with this milestone should be resolved on the `2.1-work` branch.  These
are usually new features.

#### Indefinite future

Issues with this milestone are either questionable features, or features that are too far
out to schedule on another milestone.

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

## Source file overview

### ack

This is the main entry point for ack.  It contains a great deal of the code,
as well as the POD documentation that is used to generate man pages.

### Ack.pm

This contains the App::Ack package, which stores more of the general "helper" code
for ack.  Chances are that if you want to change something, it'll be in `Ack.pm`
or `ack`.

### Resource.pm

An abstract superclass that represents a searchable "resource" (usually a file on a filesystem).

### Resources.pm

A factory object for creating a stream of `Resource` objects.

### Filter.pm

An abstract superclass that represents objects that can filter `Resource` objects.

### Basic.pm

Implements a basic (on-filesystem) `Resource` object.

### ConfigDefault.pm

A module that contains the default configuration for ack.

### ConfigFinder.pm

A module that contains the logic for locating the various configuration
files.

### ConfigLoader.pm

A module that contains the logic for loading configuration files.

### Debug.pm

Contains a single routine for printing to the console while being run
in the test suite.

### Default.pm

The class that implements the filter that ack uses by
default if you don't specify any filters on the command line.

### Extension.pm

The class that implements filtering resources by file extension.

### FirstLineMatch.pm

The class that implements filtering resources by their first line.

### Inverse.pm

The class that inverts another filter.

### Is.pm

The class that implements filtering resources by their filename (exact match).

### Match.pm

The class that implements filtering resources by their filename (regular expression).

## How do I...?

### ...add a new command line option?

TODO

### MORE
