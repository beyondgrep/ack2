# Questions

* Should resources be "sources"?

# Tasks

* Filtering for directories

* Filtering for files

* Disallow types that begin with underscore, because it will blow up my hash

* Error reporting on arguments has to specify where the argument
is.  If there's an error in the /etc/ackrc, we need to say that,
vs. on the command line.

* Clarify the -f/-g relationship

# Gotchas

* ack -A --type-set=perl,ext,pl,pm,t 15 foo gets treated as ack -A 15 --type-set=perl,ext,pl,pm,t foo; this is confusing.
