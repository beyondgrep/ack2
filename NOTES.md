Most of what people ack for is literal strings.

    ack Descriptive --ignore-dir=t
    ack -w MONKEY_TYPING
    ack -i carbon

Regexes, sure, but not nearly as common.

So say you're acking for "carbon".  ack sees a file that might be
interesting, and if ack knows that the string "ca" is not in the
file, ack doesn't need to even open the file.  If "ar" is not in
the file, ack doesn't need to look.  If "rb" is not in the file,
or "bo", or "on", then ack doesn't need to look.

Also, if ack knows that "ca" first appears at line 17 and last at
153, then that's the only range of lines ack needs to search.  When
ack gets to line 153, ack can stop.

Rob Hoelz:
	so are you talking about building an index before search?
Andy Lester:
	Yes
Rob Hoelz:
	or something else?
Andy Lester:
	of 676 letter combinations
Rob Hoelz:
	on every invocation of ack?
Andy Lester:
	No
	Building .ackindex
Rob Hoelz:
	ok
Andy Lester:
	per directory
Rob Hoelz:
	hmm
	I think it's a bold idea
Andy Lester:
	The index file will have one row
	per file in the directory
Rob Hoelz:
	so how do you handle new files? changed files? etc
Andy Lester:
	file-permissions.t,48342134,aa,156-234,ab,7-19,....
	that first big number is the time it was last touched
	And so if the file has been touched since then, just do a standard search.
Rob Hoelz:
	ok, that makes sense.
Andy Lester:
	Maybe later on down the road, we can have it reindex on the fly.
	but at first I'm happy with "ack --index"
	And of course you can do "ack --index --perl --nohtml"
Rob Hoelz:
	I think it might be a good idea to store it outside of the project directory, though
	I can imagine people getting annoyed that ack is leaving these files behind
Andy Lester:
	It could live parallel to .ackrc.
	You could have to have a .ackrc in order to get a .ackindex
Rob Hoelz:
	that's a pattern I have to stick in my .gitignore
Andy Lester:
	right
Rob Hoelz:
	do you *need* --index to use it, though?
	if so, I think that's fine
	also
Andy Lester:
	no, if ack sees the .ackindex, it will use it
	and it will use whatever it finds inside
Rob Hoelz:
	I think that some people might think "If I wanted to use an index, I would use Google Codesearch"
Andy Lester:
	If you want foo.pl and it's not in the .ackindex, then search normally
	I'm also imaginging that there might be saying "Only index files > 10K"
	because under that it's not worth it
Rob Hoelz:
	hmm
	well
Andy Lester:
	dunno, all that is premature imaginary optimization
Rob Hoelz:
	well, this isn't the first time I've heard something like this
	one thing that we could *definitely* make use of
	is storing filetypes between invocations (or something like that)
Andy Lester:
	Oh, I hadn't thought of that.
Rob Hoelz:
	that's a small first step
	that would be a *huge* help, imo
	avoiding syscalls is a plus
Andy Lester:
	Looking in .ackindex instead of opening the file for the shebang?
Rob Hoelz:
	yeah
	we slurp in the index
	and we use that to determine filetypes
	of course, keeping in line with timestamps
Andy Lester:
	I think the HUGE win will be "I don't have to open half of the files because they don't contain CA, AR, RB, BO or ON
Rob Hoelz:
	that's even better
Andy Lester:
	I thought about doing all this in DB_File
	but I think that simple one-line-per-file will be fine.
Rob Hoelz:
	probably
	we can benchmark
	be back in a few
Andy Lester:
	Right now all I'm doing is gonna spike up an indexer.

