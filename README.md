# Usage principles of ack 2.0 that stay the same

ack will still:

* only search files of types it recognizes

* ignore version control directories, core dumps and other large files

* allow user-specified filetype detection

* never be a file editor

* support a local ~/.ackrc

* sniff shebang lines to detect language

* try to be as switch-compatible with GNU grep as possible


# Continuing design principles of ack 2.0

ack will still:

* be distributed through CPAN

* be distributed as a standalone
    * No modules other than File::Next can be required except for what comes with core Perl.
    * Plugins can require whatever they want, like Archive::Tar

* be purely Perl 5, and use Perl 5 regular expressions

* be taint-safe

* run on Windows as well as Linux/Unix/etc


# Definite new features in ack 2.0

ack 2.0 will have:

* improved flexibility in defining filetypes
    * glob-style matching (`*.pl` identifies a Perl file)
    * regex-style matching (`/\.pl$/i` identifies a Perl file)
    * shebang-line matching (shebang line matching `/usr/bin/perl/` identifies a Perl file)

* support for a global ackrc
    * https://github.com/petdance/ack/issues/#issue/79

* no hardcoded filetypes or directories
    * Everyone has different needs.  ack will ship with a default
    ackrc, but without that, there will be no exclusions.


# Possible new features in ack 2.0, but probably ack 2.1

ack may:

* search up the directory paths to see if there are parent ackrc
files, so a given tree or project could have a tree-specific ackrc
file.

* allow filetype-based plugins for searching arbitrary filetypes,
such as PDFs or Excel files (although this will probably be ack
2.1)

* add an --also-in-file for matching two matches in the same file
    * https://github.com/petdance/ack/issues#issue/153

* have profiles that are collections of arguments, so you can say
--profile=web, --profile=programming, --profile=sysadmin or whatever.


# Incompatibilities with ack 1.x

* Drop the --binary and --skipped flags, and some default filetypes.

* May require Perl 5.10
