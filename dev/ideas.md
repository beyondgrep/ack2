# Match Types (inclusion)

- firstline
  - shebang
  - Vim modeline (first couple of lines?)
  - Emacs modeline (first couple of lines?)
- extension
  - .pl
  - .tar.gz (complex extensions)
- direct match
  - case sensitive/insensitive
- pattern?
- combined rules:
  - Ex. Prolog files also have a .pl extension, so we should check extension and contents, maybe
- unknown type?
  - Does this match extensionless files (see questions.md)
  - Or just files that don't match any other patterns?

# Match Types (exclusion)

- Exclude a set of directory trees (CVS, .svn, .git, .hg, \_darcs)
- Exclude a set of files (.\*~)

# Configuration Files

- /etc/ackrc, ~/.ackrc, look up directory hierarchy for .ackrcs? (the last one is probably for 2.1)
- Option to suppress loading of various ack rc files (--no-system-rc, --no-home-rc, or something)
  - If we did, this, could you put --no-system-rc in ~/.ackrc?

# Bikeshedding

- A debugging switch to indicate which option/pattern came from where
  - Multiple ack configuration files
  - ACK\_OPTS
  - command line
- Command line option to remove a rule from a file type:
  - Ex. I don't want to treat .t files as Perl in a given project: --type-remove=perl,ext,t
