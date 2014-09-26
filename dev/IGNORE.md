# --ignore-dir and --ignore-file revamp

Users have been disatisfied with `--ignore-dir` and `--ignore-file`.  Here are some common "bug reports"

  - `--ignore-dir=foo/bar` doesn't ignore `foo/bar` at all (GH #291)
  - `--ignore-dir=foo` ignores all directories named `foo`, not just the one at the root of the search (GH #216)
  - `--ignore-dir=foo foo -f` doesn't search `foo/` (GH #492)
  - No way to ignore a file in a folder (GH #479)
  - `--ignore-dir` doesn't implement all filters (GH #42)

Also consider GH #330, and consider that you could be anywhere in a project but still source the `--ignore-dir=./foo` rule
from an ackrc a few directories above.  Are we preparing to teach ack about the notion of a project root?  Also, consider
`--noignore-dir`

## How does --ignore-dir work at the moment?

## Scenario 1

--ignore-dir can ignore paths as well as directories

## Scenario 2

--ignore-dir only ignores directories, but warns if you try to ignore a path
