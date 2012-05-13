# Definite new features in ack 2.0

ack 2.0 will:

* by default search all text files, as identified by Perl's `-T` operator
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

# Incompatibilities with ack 1.x

* Drop the --binary and --skipped flags, and some default filetypes.

* No more -a or -u flags.

* No more -G and --invert-file-match flags

* -g now obeys all regex flags: -i, -w, -Q, -v
