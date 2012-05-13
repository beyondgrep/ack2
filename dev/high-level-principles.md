# Usage principles of ack 2.0 that stay the same

ack will still:

* have a system for recognizing types of files, to allow including and excluding certain types of files.

* ignore version control directories, core dumps and other large files

* never be a file editor

* support a local ~/.ackrc

* sniff shebang lines to detect language

* try to be as switch-compatible with GNU grep as possible


# Definite new features in ack 2.0

ack 2.0 will:

* by default search all text files, as identified by Perl's -T operator
    * We will no longer have a `-a` switch.

* improved flexibility in defining filetypes
    * glob-style matching (`*.pl` identifies a Perl file)
    * regex-style matching (`/\.pl$/i` identifies a Perl file)
    * shebang-line matching (shebang line matching `/usr/bin/perl/` identifies a Perl file)

* support for multiple ackrc files
    * global ackrc (/etc/ackrc)
        * https://github.com/petdance/ack/issues/#issue/79
    * user-specific ackrc (~/.ackrc)
    * per-project ackrc files (~/myproject/ackrc)

* all inclusion/exclusion rules will be in the ackrc files
    * ack 2.0 will have no hardcoded filetype specifications,
    directories to include or exclude, and so on.  It will ship
    with a default global ackrc, but does not need it.


# Continuing design principles of ack 2.0

ack will still:

* run on Perl 5.8.8

* be distributed through CPAN

* be distributed as a standalone
    * No modules other than File::Next can be required except for what comes with core Perl.
    * Plugins can require whatever they want, like Archive::Tar

* be purely Perl 5, and use Perl 5 regular expressions

* be taint-safe

* run on Windows as well as Linux/Unix/etc

* use Perl's default file-handling as far as dealing with files of
different encodings

* be configured entirely from the command-line.  ackrc files will
still be merely collections of command-line switches.


# Incompatibilities with ack 1.x

* Drop the --binary and --skipped flags, and some default filetypes.

* No more -a or -u flags.

* No more -G and --invert-file-match flags

* -g now obeys all regex flags: -i, -w, -Q, -v


# Features that may get added in ack 2.1+, but definitely not in 2.0

* allow filetype-based plugins for searching arbitrary filetypes,
such as PDFs or Excel files

* add an --also-in-file for matching two matches in the same file
    * https://github.com/petdance/ack/issues#issue/153

* have profiles that are collections of arguments, so you can say
--profile=web, --profile=programming, --profile=sysadmin or whatever.

* Allow file-wide type detection, instead of just looking at just
the shebang.

* Multiple ackrc files in a location, like `/etc/ackrc.d/`
