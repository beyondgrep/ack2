* Rob Hoelz: got a minute to chat about Ack?
* Andy Lester: Not really, but go ahead. :-)
* Andy Lester: It's never stopped me before!
* Rob Hoelz: I was just thinking about testing the configuration loader
* Andy Lester: ok
* Andy Lester: oh,
* Andy Lester: oh
* Rob Hoelz: I was thinking of two ways of doing it:
* Andy Lester: ok
* Andy Lester: go on
* Rob Hoelz: 1) make local overrides for open
* Rob Hoelz: 2) inject an Ack::FileReader object to Ack::ConfigLoader, and use that to actually read files in
* Rob Hoelz: and provide a mock reader in the tests
* Rob Hoelz: what do you think?
* Andy Lester: I think that file finding is one concern.
* Andy Lester: I think that option building is another.
* Andy Lester: and the two don't have to coincide.
* Rob Hoelz: I'd normally agree
* Rob Hoelz: but
* Andy Lester: (This is just off the top of my head, not an edict)
* Rob Hoelz: with the talk of a --dont-load-project-ackrc/--load-project-ackrc option in /etc/ackrc or ~/.ackrc, they would have to, right?
* Andy Lester: I'm not sure we have to have mingle the finding of ackrc files with the reading of ackrc files with the interpretation of those contents.
* Andy Lester: I see three different parts
* Andy Lester: Oh, yeah, there's that.
* Rob Hoelz: if that feature weren't on the menu, I'd just have Ack::ConfigLocator
* Andy Lester: I think we may have to limit where a --dont-load-project-ackrc file can be found
* Andy Lester: Well, here's the thing.
* Andy Lester: It's not really a "don't read the project file"
* Andy Lester: it's a "ignore project file"
* Andy Lester: We can go ahead and read the options out of that file.
* Andy Lester: and then if we run across --ignore-project-ackrc
* Andy Lester: toss those options.
* Rob Hoelz: interesting
* Andy Lester: Remember: Every option has to know its source
* Rob Hoelz: right
* Andy Lester: because the --ackrc-debug is going to say "This option came from ~/.ackrc, and this one came from ACK\_OPTIONS"
* Andy Lester: so ignoring is trivial
* Andy Lester: and we're not worried about the time of finding/reading the project ackrc
* Rob Hoelz: is that for *all* options, or just ack rules?
* Andy Lester: ALL options
* Rob Hoelz: ok
* Rob Hoelz: ok, that clears things up a bit
* Andy Lester: that lets us display the hierarchy of options
* Andy Lester: Becuase with such a trail of potential sources of options, people will want to know why such-and-such is happening.
* Rob Hoelz: ok
* Rob Hoelz: so, let's call this module Ack::ConfigFinder
* Andy Lester: ok
* Andy Lester: Hey, wanna try to hack on Sunday?
* Rob Hoelz: can't =(
* Andy Lester: ok
* Rob Hoelz: away for Labor Day stuff
* Andy Lester: dat's fine
* Andy Lester: I think it would be helpful long-term to dump the key parts of this chat, in English, to a file somewhere
* Rob Hoelz: sure
* Andy Lester: We basically just created the top block of documentation of Ack::ConfigFinder
* Rob Hoelz: I'm not saying anything incriminating =P
* Andy Lester: discussing how it does the finding.
* Andy Lester: :-)
* Andy Lester: Just pull out the good stuff
* Andy Lester: and capture it to a file.
* Rob Hoelz: I'm guessing that Ack::ConfigFind::find\_configs should return a list of hashes/objects, instead of just paths
* Rob Hoelz: namely, so we can say { path => '...', project\_file => 1 }
* Rob Hoelz: thoughts?
* Andy Lester: you mean get that back
* Andy Lester: "Ok, this was the project-level file"
* Andy Lester: ?
* Rob Hoelz: yes
* Rob Hoelz: so we can forgo reading project files if $dont\_read\_project\_file is set
* Andy Lester: We'll always read them.
* Rob Hoelz: and that was my next question =)
* Andy Lester: Because me might not know until we've loaded a given file "Oh wait, we're ignoring the project file"
* Andy Lester: which is why we want to say --ignore-project-ackrc
* Andy Lester: not --dont-read
* Rob Hoelz: I see
* Rob Hoelz: hmm
* Rob Hoelz: random debug mode question
* Andy Lester: k
* Rob Hoelz: let's say for time being that --add-rule overrides previous entries (I don't know if it does)
* Andy Lester: I think it does
* Andy Lester: which is another reason that we need to know the source of everything.
* Rob Hoelz: ok, good
* Andy Lester: I'm thinking each source gets some sort of numerical ranking 
* Rob Hoelz: sounds sensible
* Andy Lester: (for internal use only)
* Andy Lester: /etc/ackrc = 10
* Andy Lester: ~/.ackrc = 20
* Andy Lester: project ackrc = 30
* Rob Hoelz: so, let's say I have --add-rule=perl,ext,pl|pod|t in my /etc/ackrc
* Andy Lester: ACK\_OPTIONS=40
* Andy Lester: command line = 50
* Andy Lester: or something like that
* Rob Hoelz: and I have --add-rule=perl,ext,pl in my ~/.ackrc
* Andy Lester: ok
* Rob Hoelz: when we dump debugging info for options
* Rob Hoelz: would it show the first rule for /etc/ackrc, but specify, "overriden by ~/.ackrc"?
* Andy Lester: I think it should.
* Andy Lester: We have to figure that out ourselves
* Andy Lester: might as well tell the user.
* Rob Hoelz: ok, I was hoping you'd say that
* Rob Hoelz: glad to see we're on the same page
* Rob Hoelz: as far as the ranking of option sources goes
* Andy Lester: Yeah, because it's going to be the source of confusino.
* Andy Lester: We're mkaing it VERY flexible
* Rob Hoelz: I was thinking of assigning rank based on the source's position in the array returned by ConfigFinder
* Rob Hoelz: which isn't *much* different
* Rob Hoelz: but it would allow us to easily insert new types of options files in the future if we come up with any
* Andy Lester: right
* Andy Lester: and the numbers are just arbitrary
* Rob Hoelz: oh, ok
* Andy Lester: they're internal only
* Andy Lester: Although
* Andy Lester: we might assign a sequence number
* Rob Hoelz: I was thinking you wanted constants in the code =)
* Andy Lester: where we say in debug mode that rule #27 overrode #13
* Andy Lester: Well, sure, they can be constants in the code
* Andy Lester: but they can change.
* Andy Lester: I just assigned #10, #20, #30 because I still do that from working in BASIC in the late 70s :-)
* Rob Hoelz: heh
* Andy Lester: ok, all done here?
* Rob Hoelz: ypu
* Andy Lester: kthx
* Rob Hoelz: I've got enough =)
