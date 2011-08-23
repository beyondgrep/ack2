All times GMT.

* **alester**
    * 14:00:24: Morning!
* **hoelzro**
    * 14:02:07: morning `=)`
* **alester**
    * 14:02:38: That was close.
    * 14:02:42: I hate starting meetings late.
    * 14:03:10: I figured we'd have more!
* **hoelzro**
    * 14:03:29: yeah, me too
    * 14:03:31: `=(`
* **cjm**
    * 14:03:49: morning
* **hoelzro**
    * 14:03:52: so, what's first on the agenda?
    * 14:03:53: cjm: hi!
* **alester**
    * 14:04:20: cjm: Have we met?  The nick isn't familiar.
    * 14:04:27: and does everyone have a chekcout of ack2?
* **cjm**
    * 14:04:45: I don't think we've met in person.  I've made some contributions before
* **hoelzro**
    * 14:04:50: yup, and 2 #2 pencils!
* **alester**
    * 14:05:00: Wha'ts your name, cjm?
* **cjm**
    * 14:05:09: is ack2 a different repo, or just ack?
* **alester**
    * 14:05:16: no, new repo
    * 14:05:19: parallel to ack
* **cjm**
    * 14:05:20: Christopher J. Madsen
* **alester**
    * 14:05:33: Oh, ok, that's ringing a bell.
    * 14:05:53: [https://github.com/petdance/ack2](https://github.com/petdance/ack2)
* **cjm**
    * 14:06:16: I'm the one who rewrote the tests so test writers didn't need to mess with shell quoting rules
* **alester**
    * 14:06:34: That's goodness.
    * 14:08:05: OK, so here are my thoughts.
    * 14:08:27: First, I want to make everything clear (to the world) what the design changes about ack are.
    * 14:08:32: About ack 2.0.
    * 14:08:42: I am assuming anyone reading them will know what ack 1.x is.
    * 14:09:32: These design declarations will help anyone wanting to help, and they will also form the basis for the ack 2.0 docs that say "Here's how ack 2.0 is better than 1.x"
    * 14:10:08: These design declarations need to have copious examples
    * 14:10:25: because a picture is worth a thousand words, and an example with syntax is worth at least that.
    * 14:10:50: Second, I want to start chopping up the elephent.
    * 14:11:03: There's an old joke that says "How do you eat an elephant?  One forkful at a time."
    * 14:11:18: Right now the elephant is "Create &amp; publish ack 2.0"
    * 14:12:08: The ideal chunk will be something where someone looking at the forkfuls and say "Oh, I could do that."
    * 14:12:41: Some of these chunks will be code.  Some will be docs.  Some might be tests.
    * 14:12:53: (cjm++ for cross-platform testing thinking)
    * 14:13:26: And the "someone" of "someone can say I can do that" includes me. `:-)`
    * 14:13:34: Because I am stymied by looking at this elephant.
    * 14:13:46: I have started writing actual code.  It's in ack2 repo
    * 14:14:15: but I'm wary of going to far without having design and future plans because I don't want to run afoul of blinders.
    * 14:14:37: So the more people that can see these design docs, the more people can say "Yeah, but what about&#x2026;" before we go down a bad path.
    * 14:15:23: Oooh, another benefit of forkfuls: I'd like to be able to say "Hey, we're having an ackathon, come and hack some ack next Tuesday at 8" or whatever
* **hoelzro**
    * 14:15:36: ackathons++
* **alester**
    * 14:15:37: because clearly this "plan an online meeting" DOES get people interested.
    * 14:16:01: And if nothing else, hoelzro and I can have in-person ackathons without too much trouble.
    * 14:16:16: There's a strange amount of love that people have for ack, and they want to help.
    * 14:16:25: We just have to get it to where they CAN.
    * 14:16:39: OK, so, thoughts?
* **cjm**
    * 14:17:32: that all sounds reasonble
* **hoelzro**
    * 14:17:37: we should probably mention that most of our "design documents" are at [https://github.com/](https://github.com/petdance/ack2/tree/master/dev)[petdance](https://github.com/petdance/ack2/tree/master/dev)[/ack2/tree/master/dev](https://github.com/petdance/ack2/tree/master/dev)
* **alester**
    * 14:17:54: Well, I have others, hoelzro.
    * 14:17:59: But clearly they are not where they shoudl be.
* **hoelzro**
    * 14:18:02: although at this point, they're pretty informal, and some contain my own ramblings.
* **alester**
    * 14:18:17: ramblings++
    * 14:18:27: Ramblings can get cleaned up.
    * 14:18:55: A lot of README.md is design doc
* **alester**
    * 14:19:57: welcome, wolverian 
* **wolverian**
    * 14:20:44: thanks, great to be here. `:)`
* **alester**
    * 14:20:54: Everyone pull from ack2, I renamed the file
    * 14:21:02: We are glad to have you
    * 14:21:25: Actualy, I think going through the principles line-by-line would be a good way to start
    * 14:21:29: and will help bring up questions.
    * 14:21:38: Especially because the first line is wrong.
    * 14:21:43: \* only search files of types it recognizes
    * 14:21:46: is not correct
    * 14:22:41: \* search all text files by default, although specifications of filetypes will override this.
* **zitterbewegung**
    * 14:23:48: Good day.
* **hoelzro**
    * 14:23:56: zitterbewegung: morning
* **alester**
    * 14:23:57: glad to have you zitterbewegung 
* **hoelzro**
    * 14:24:00: or afternoon
* **alester**
    * 14:24:10: OK, updated: repull [https://github.com/petdance/ack2](https://github.com/petdance/ack2)
* **zitterbewegung**
    * 14:24:10: Morning for me.
* **zitterbewegung**
    * 14:25:30: Maybe a good idea would be to search through compressed items?
    * 14:25:35: I see that you have a plugin system.
* **cjm**
    * 14:25:43: [https://github.com/](https://github.com/petdance/ack2/blob/master/dev/high-level-principles.md)[petdance](https://github.com/petdance/ack2/blob/master/dev/high-level-principles.md)[/ack2/blob/master/dev/high-level-principles.md](https://github.com/petdance/ack2/blob/master/dev/high-level-principles.md)
* **alester**
    * 14:25:49: zitterbewegung: not yet
    * 14:25:53: plugins will be 2.1
    * 14:26:05: It is too much to try to wedge into 2.0
* **zitterbewegung**
    * 14:26:55: Oh ok.
* **alester**
    * 14:27:13: OK, repull.  I am done with my last minute changes, I hope. `:-)`
    * 14:27:31: Let's look at # Usage principles of ack 2.0 that stay the same
    * 14:27:42: Anything else needs to be said here?  Any problems with this?
* **zitterbewegung**
    * 14:28:43: Could you recognise languages by pattern matching if shebang matching fails or would that be too slow or inefficient?
    * 14:28:51: Like possibly a simple heuristic.
* **alester**
    * 14:28:56: Such as?
    * 14:29:10: Finding /&lt;?php/  somewhere in the file?
* **zitterbewegung**
    * 14:29:19: Yea. 
    * 14:29:35: Or for dr scheme
    * 14:29:42: [#lang](irc://irc.perl.org/#lang) scheme
    * 14:29:47: Match for the module declaration
    * 14:30:29: I would expect this to be implementable as a regex or a lookup table that would be extremely efficent.
* **alester**
    * 14:30:59: I'm going to put that in the 2.1+ potential features section.
* **zitterbewegung**
    * 14:31:01: Like O(1) or O(n) time with only matching the first kilobyte of the file.
    * 14:31:04: Ok sure
* **alester**
    * 14:31:13: because that could be a whole yak-shave right there.
    * 14:31:33: Also, the concerns about speed will be hard to sort out without having a solid 2.0 to start with.
* **zitterbewegung**
    * 14:31:43: Alright sure.
* **wolverian**
    * 14:33:18: file(1) might be useful for that kind of a thing; I think there's a CPAN module that embeds the magic db in itself, too, for working on windows.
* **alester**
    * 14:33:19: OK, changes pushed.
* **hoelzro**
    * 14:33:50: alester: what does ack does about file encodings, btw?
* **wolverian**
    * 14:33:55: in general, for me, shebang line support is enough.
* **alester**
    * 14:33:56: hoelzro: Ouch.
* **hoelzro**
    * 14:34:33: so, nothing really?
    * 14:34:36: `=/`
* **cjm**
    * 14:34:38: you don't need to say "(although this will probably be ack 2.1)" anymore
* **hoelzro**
    * 14:34:53: I mean, I don't know if that's really the job of ack...yet
* **cjm**
    * 14:34:54: since the heading now says 2.1+
* **hoelzro**
    * 14:35:10: but since you're trying to attract Windows users, that might be important
    * 14:35:23: since Windows uses UTF-16 (or is it UCS-2?) by default, I think
* **alester**
    * 14:35:36: Here's the thing: I don't know shit about encodings. `:-)`
* **hoelzro**
    * 14:35:49: alester: 2.1?
    * 14:35:56: alester: I know...a decent amount.
    * 14:36:02: not a master by any means
* **wolverian**
    * 14:36:06: hoelzro: or windows-1251.
* **alester**
    * 14:36:09: What would be in 2.1?
* **hoelzro**
    * 14:36:15: wolverian: thanks, good call
* **alester**
    * 14:36:28: Reload
    * 14:36:36: (I'm just going to say "Reload" whenever I push a change)
* **zitterbewegung**
    * 14:36:58: From my understanding the most common encodings are UTF-8 and Ascii
* **hoelzro**
    * 14:37:06: zitterbewegung: on Unix, they are
    * 14:37:13: and on the Internet
* **zitterbewegung**
    * 14:37:15: Oh yea and windows you have UTF-16
* **alester**
    * 14:37:25: I think that unless we know what we're doing, we just use the default behavior of Perl.
* **zitterbewegung**
    * 14:37:25: So I would support those as a bare minimum.
* **hoelzro**
    * 14:37:34: yes, and that brings many frown faces.
* **zitterbewegung**
    * 14:37:35: Yea default behavior of perl would be the best.
* **hoelzro**
    * 14:37:36: `=(` `=(` `=(`
* **alester**
    * 14:37:48: What should we do instead, hoelzro ?
* **hoelzro**
    * 14:37:54: isn't sure of the default behavior of Perl on Windows
    * 14:38:09: alester: the UTF-16 part brings frown faces, not Perl's default behavior
* **cjm**
    * 14:38:10: same as unix, except for :crlf
* **alester**
    * 14:38:14: oh, ok
* **hoelzro**
    * 14:38:17: hmm
    * 14:38:29: what if it's reading in a UTF-16 encoded file?
* **cjm**
    * 14:38:37: then you'd better tell it that
* **hoelzro**
    * 14:38:40: do I get 0x00 0x65 0x00 0x66, et
    * 14:38:43: that's what I thought
    * 14:39:10: well, Windows marks its UTF-16 files with a BOM, right?
* **zitterbewegung**
    * 14:39:14: Should we try to translate UTF-16 to UTF-8? I believe thats possible right?
* **alester**
    * 14:39:23: Reload: Added a note about encodings.
* **hoelzro**
    * 14:39:28: zitterbewegung: yeah, the Encode module can handle that
* **cjm**
    * 14:39:42: Windows usually uses a BOM
* **wolverian**
    * 14:39:49: why would ack need to translate \*to\* an encoding? isn't decoding them into character strings enough?
* **hoelzro**
    * 14:40:01: wolverian: that's exactly what we would d
    * 14:40:02: \*do
* **alester**
    * 14:40:04: wolverian: I don't know. Forgive me terminology. `:-)`
* **hoelzro**
    * 14:40:14: but we also need to encode when printing the results
    * 14:40:15: maybe.
* **alester**
    * 14:40:20: 2.0 can't handle encoding hoohah.
    * 14:40:32: There is far too much other goodness to deal with.
* **wolverian**
    * 14:40:36: that was mostly a reply to zitterbewegung. ah, printing results. yes, that probably needs to look at the locale. though I have no idea what windows does here.
* **alester**
    * 14:40:59: So encodings is off the table for this. &lt;/gavel&gt;
* **hoelzro**
    * 14:41:02: alester: is encoding something I should look at for 2.0?
    * 14:41:05: oh, nvm
* **wolverian**
    * 14:41:14: alester: good call, it's a swamp
* **zitterbewegung**
    * 14:41:15: wolverian: I thought it would make things easier.
* **alester**
    * 14:41:16: see how I worded it.
* **zitterbewegung**
    * 14:41:28: wolverian: Reducing the problem to something we know. Maybe not. Anyways.
* **alester**
    * 14:41:30: \* use Perl's default file-handling as far as dealing with files of different encodings
    * 14:41:45: It's worked for 1.x. `:-)`
    * 14:42:27: OK, any other comments in the first two sections?  # Usage principles of ack 2.0 that stay the same
    * 14:42:27:  and # Continuing design principles of ack 2.0
* **cjm**
    * 14:45:12: "ignore version control directories, core dumps and other large files"
    * 14:45:12: will that be only if you install .ackrc, or will there be a built-in list?
* **alester**
    * 14:45:35: \* no hardcoded filetypes or directories
    * 14:45:35:     \* Everyone has different needs.  ack will ship with a default
    * 14:45:35:     ackrc, but without that, there will be no exclusions.
    * 14:45:42: Does that say it enough?  
    * 14:46:03: Eh, it's pretty awkward.
* **cjm**
    * 14:46:31: those two seem to conflict
* **alester**
    * 14:46:35: ok
    * 14:46:38: Here's what I want to say
    * 14:46:45: EVERYTHING is based on the ackrc(s). 
    * 14:46:53: There will be nothing hardcoded in ack itself.
    * 14:47:18: You should never have to patch your ack, which is what many people do now to get filetypes in.
* **cjm**
    * 14:47:25: then you should probably just delete \* ignore version control directories, core dumps and other large files
* **alester**
    * 14:47:37: Right, except that that will be the default behavior.
* **zitterbewegung**
    * 14:47:46: Maybe ignore large binary files?
* **alester**
    * 14:47:52: I guess maybe default behavior based onthe default ackrc should be in there.
* **zitterbewegung**
    * 14:48:05: Would that be good default behavior?
* **alester**
    * 14:48:07: "large" is a vague.
* **zitterbewegung**
    * 14:48:13: Oh ok.
    * 14:48:22: Large I mean larger than 1megabyte
* **alester**
    * 14:48:24: Anything that is not -T is ignored.
* **cjm**
    * 14:48:54: so "non-text" instead of "large"?
* **alester**
    * 14:48:58: yes
    * 14:49:03: but there will be other things, too.
    * 14:49:07: like \*.min.js
* **hoelzro**
    * 14:49:21: hooray!
* **alester**
    * 14:49:26: heh
* **cjm**
    * 14:50:03: except \*.min.js will be ackrc, and non-text will be ack core?
* **zitterbewegung**
    * 14:50:15: Heh I have a silly idea for 2.1. Classify files by their entropy.
* **alester**
    * 14:50:20: yes, non-text will be core
* **zitterbewegung**
    * 14:50:28: That would be a hilarious plugin.
    * 14:51:15: Like /dev/random would be 100% random
    * 14:51:21: anyways
* **alester**
    * 14:52:58: oooh
    * 14:53:04: how do we handle ackrc isntallation
* **cjm**
    * 14:54:06: It'd be nice if there's an ack --install
* **alester**
    * 14:54:14: that's a heck of an idea.
* **hoelzro**
    * 14:54:29: alester: you mean installing ackrc to /etc/ackrc or something?
* **alester**
    * 14:54:34: hoelzro: yes
* **hoelzro**
    * 14:54:36: ok
* **alester**
    * 14:54:53: cjm: That would let people do the single-file download, and then run ack --install
    * 14:55:02: I REALLY want to keep the single-file download, and that would do it.
* **zitterbewegung**
    * 14:55:39: Could we create a script that detects the user environment
* **hoelzro**
    * 14:55:44: alester: we should probably detect the case where no ackrc was found
* **zitterbewegung**
    * 14:55:47: like a boostrap function
* **alester**
    * 14:55:50: Sure
* **zitterbewegung**
    * 14:56:13: and then create the ackrc in a default directory? Or do we want to prompt for that directory?
* **alester**
    * 14:56:42: zitterbewegung: Not sure.  
* **cjm**
    * 14:57:03: I don't see the point in a prompt, except for global vs. per-user
* **alester**
    * 14:57:20: I'm leaving that for later
* **cjm**
    * 14:57:20: ack needs to know where to look for it, so a custom value isn't useful
* **hoelzro**
    * 14:57:33: we could do that as a switch I'd bet
    * 14:57:43: what if there's a ~/.ackrc, but no /etc/ackrc?
* **alester**
    * 14:57:45: Remember that we will have MANY pleaces to look for ackrcs
    * 14:58:00: There will be a well-defined hierarchy.
* **zitterbewegung**
    * 14:59:11: is going to lunch
* **alester**
    * 14:59:13: Reload
* **Gimpson**
    * 14:59:21: Any possibility of multiple ackrcs in a particular location?
    * 14:59:32: So I have my js ackrs, my perl ackrc and my mason ackrc
* **alester**
    * 14:59:35: Gimpson: Didn't see you come in, welcome.
* **Gimpson**
    * 14:59:54: And don't have to cat them together, they can remain separate and upgradable.
    * 14:59:59: (and thanks)
* **alester**
    * 15:00:02: Gimpson: I'm not seeing the usecase for that.
    * 15:00:08: Oh, I see what you're saying.
    * 15:00:18:  /etc/ackrc.d/
* **Gimpson**
    * 15:00:24: Yeah, something like that.
* **alester**
    * 15:00:30: An interesting idea, but I think that'll be 2.1 if ever
* **hoelzro**
    * 15:00:32: /etc/ackrc.d++
* **alester**
    * 15:00:42: because we don't know how people will use the ackrc anywy
    * 15:00:59: I want to see the ackrc cowpaths.
    * 15:01:40: but I'm adding that to the 2.1 section.
    * 15:01:55: Gimpson: when did you come in?
    * 15:02:06: oh look, there you are, I missed it.
    * 15:02:23: Reload
* **cjm**
    * 15:02:58: for those who missed it: [https://github.com/](https://github.com/petdance/ack2/blob/master/dev/high-level-principles.md)[petdance](https://github.com/petdance/ack2/blob/master/dev/high-level-principles.md)[/ack2/blob/master/dev/high-level-principles.md](https://github.com/petdance/ack2/blob/master/dev/high-level-principles.md)
* **alester**
    * 15:03:18: So let's leave that for now, and I want to start thinking for forkfuls.
    * 15:03:31: [https://github.com/petdance/ack2/blob/master/dev/forkfuls.md](https://github.com/petdance/ack2/blob/master/dev/forkfuls.md)
* **Gimpson**
    * 15:03:54: I was a bit late, came in around 7:30
    * 15:04:01: er start:30
* **alester**
    * 15:04:33: Sorry for the earliness.  hoelzro and I are Central, so we're already awake. `:-)`
    * 15:04:44: OH
    * 15:04:51: EVERYTHING has to be specified via command-line
    * 15:05:12: Nothing can be in the ackrc files except for command-line switches
    * 15:05:53: You have to be able to do everything you want via the command-line.
    * 15:08:10: Scale of 1-10: How familiar are you all with the ack 1.x source code &amp; tree?
    * 15:08:18: Me: 9
* **Gimpson**
    * 15:08:33: Me: 5
* **cjm**
    * 15:08:43: Me: ~4
* **wolverian**
    * 15:08:48: 1 
* **hoelzro**
    * 15:09:06: 2
* **alester**
    * 15:09:25: ok
    * 15:10:31: OK, look at forkfuls, please
    * 15:10:39: What sorts of high-level stuff do we need to do?
    * 15:11:16: The ackrc handling is going to have to be VERY well defined.
    * 15:11:30: because we have to get it right the first time.
    * 15:11:53: I really don't want to say in 2.1 "Oh, btw, we decided that the global ackrc now is secondary to ..."
    * 15:12:03: or whatever.  Because tat will screw up a lot of people.
* **hoelzro**
    * 15:12:23: alester: I wouldn't mind taking a look at the ackrc location stuff
    * 15:12:43: but I'd need some external help to make sure I don't succumb to my own personal bias.
* **alester**
    * 15:12:50: ok
    * 15:13:07: You're talking about defining the rules, right?
    * 15:13:12: of where we find them?
* **Gimpson**
    * 15:13:12: alester: Are you looking for more TODOs for forkfuls, or wanting to start defining those rules now?
* **alester**
    * 15:13:22: No, don't want to define rules now.
* **hoelzro**
    * 15:13:39: alester: well, that and writing the code
* **alester**
    * 15:13:57: hoelzro: That's fine too
    * 15:14:28: The glossary is gonna be big.
    * 15:15:14: reload
* **hoelzro**
    * 15:16:46: alester: are we considering ACK\_OPTIONS to be part of the ackrc logic?
* **alester**
    * 15:17:11: yes
* **hoelzro**
    * 15:17:16: mkay
    * 15:17:26: could you throw that in the notes?
* **alester**
    * 15:17:43: reload
    * 15:18:10: OH! We need a debug mode.
    * 15:18:42: ack --debug 
    * 15:18:52: or ack --rule-dump
    * 15:19:47: reload
    * 15:19:58: just added a forkful "Look at glark and see if there's anything we want to steal"
* **hoelzro**
    * 15:20:17: debug++
* **alester**
    * 15:20:59: ack -f started as debug
    * 15:21:04: and now it's a feature
    * 15:23:24: Gimpson: If you and hoelzro want to put your heads together on rules for ackrc finding, that'd be swell.
* **hoelzro**
    * 15:23:34: I'll start a thread
* **alester**
    * 15:25:02: I'm wondering if we should have a separate ack2 list.
    * 15:25:21: Nah, just start it on ack-users
    * 15:25:28: if it gets too noisy, we can split it off.
* **cjm**
    * 15:25:34: agree
* **alester**
    * 15:25:52: hoelzro: A request: Don't start the thread by saying "What do you think it should be?"
    * 15:26:07: Start with "Here's my draft of rules for finding ackrc files in ack 2.0"
    * 15:26:16: because 90% of whatever you come up with in that first draft will be fine.
* **hoelzro**
    * 15:27:18: mkay
* **alester**
    * 15:27:30: And usually when things get opened up to the floor like that, what you come up with is about what you would have had on your own. `:-)`
    * 15:27:35: Attention is a scarce resource.
* **hoelzro**
    * 15:28:03: heh
* **alester**
    * 15:28:23: Anything else in forkfuls anyone's interested in?
    * 15:28:34: or where you see it can be broken up?
* **Gimpson**
    * 15:29:20: Filetype detection, do we know all the new ways we'll support?
* **alester**
    * 15:29:26: yes
* **Gimpson**
    * 15:29:33: extension and regex are the two I know of
    * 15:29:43: shebang
* **alester**
    * 15:29:44: [https://github.com/petdance/ack2/blob/master/ackrc](https://github.com/petdance/ack2/blob/master/ackrc)
* **Gimpson**
    * 15:30:12: Ah, cool.
* **alester**
    * 15:31:54: and then adding some other heuristic like "entirefilematch" for &lt;?php fits nicely
    * 15:32:15: That ackrc is pretty much translated directly from ack 1.x
* **alester**
    * 15:34:36: Hi ad.
    * 15:34:40: Welcome to the party.
* **zitterbewgung-starb**
    * 15:35:34: Hi again.
* **alester**
    * 15:35:36: zitterbewegung: MUST HAVE COFFE
    * 15:35:46: ad: Tell us a bit about your backgroudn.
* **zitterbewgung-starb**
    * 15:35:49: will order you some
* **alester**
    * 15:35:58: zitterbewegung: I prefer my coffee cold.
* **ad**
    * 15:36:01: alester: Just lurking around, thanks
* **alester**
    * 15:36:05: I mean caffeine
* **zitterbewgung-starb**
    * 15:36:14: orders you a cold grande latte
    * 15:36:17: oh wait
* **alester**
    * 15:36:24: lives on diet Coke
* **zitterbewgung-starb**
    * 15:36:27: orders you a cold caffeine IV
    * 15:36:42: oh yea diet coke is great.
* **alester**
    * 15:36:57: OK, so far we have hoelzro going to write up some rules for ackrc/ACK\_OPTIONS 
    * 15:37:07: Which I assume will be roughly
    * 15:37:21: in order of priority
    * 15:37:47: ACK\_OPTIONS -&gt; /etc/ackrc -&gt; ~/.ackrc -&gt; project ackrc -&gt; command line switches
    * 15:38:02: from least to most priority
    * 15:38:09: (Gimpson: I guess we ARE talking about rules now :-))
* **hoelzro**
    * 15:38:26: ah, I didn't include command line in my doc
* **alester**
    * 15:38:47: we MUST have the directoriy hierarchy
* **hoelzro**
    * 15:38:58: mkay
* **alester**
    * 15:39:09: because per-project is going to be huge
    * 15:39:28: Because search-all-text-by-default is going to screw up a lot of stuff
* **hoelzro**
    * 15:39:37: hmm
    * 15:39:38: idea
* **alester**
    * 15:39:41: for isntance, here at work, we have plenty of .xml in the source trees
* **hoelzro**
    * 15:39:53: actually, scratch that
* **alester**
    * 15:40:25: and I have to be able to have a .ackrc in my project that says --ignore-file=filetype,xml
    * 15:41:02: oops, I mean --ignore-file=ext,xml
    * 15:41:32: ad: Are you using ack now?
* **ad**
    * 15:41:56: alester: No, but I know what it is
* **Gimpson**
    * 15:43:23: project ackrc is just a .ackrc in a particular directory?
* **alester**
    * 15:43:59: yes
* **hoelzro**
    * 15:44:17: alester: what about --include-file/--include-dir directives?
* **alester**
    * 15:44:26: hoelzro: What about them?
    * 15:44:50: I see ackrc finding &amp; reading to be aggregation of directives.
    * 15:44:56: Nothing more.
* **hoelzro**
    * 15:48:09: just an idea
* **alester**
    * 15:48:37: I don't get what the idea is.
    * 15:49:31: Oh, they don't exist.  You're suggesting explicitly adding --include-file/--include-dir to negate --exclude-file/--exclude-dir?
* **hoelzro**
    * 15:50:02: well, I meant it in the context if including an ackrc file or a directory of them
* **alester**
    * 15:50:44: like --ackrc=/path/to/file ?
    * 15:51:16: Oh, also you have to deal with the $ACKRC variable, too
    * 15:51:34: Or maybe we kill it.
* **cjm**
    * 15:52:23: if we have ./.ackrc, ../.ackrc, etc., we probably don't need $ACKRC
* **alester**
    * 15:52:44: That's what I'm thinking.
* **Gimpson**
    * 15:53:29: Rules are defined completely at runtime before recursing into subdirs?
    * 15:54:03: For example, if I have a .ackrc in ., but there's another in bin/.ackrc, does the .ackrc in bin get used?
    * 15:54:09: When recursing into that directory?
* **cjm**
    * 15:54:32: I don't think so.  Juggling multiple sets of rules will get too complicated
* **alester**
    * 15:54:45: No
    * 15:54:50: we go up looking for .ackrc
    * 15:54:59: not down
    * 15:56:32: One that definitely need to be in the docs is examples.
* **alester**
    * 15:56:42: hi und3f
    * 15:56:46: It's a damn party!
* **und3f**
    * 15:56:57: alester, hello
* **zitterbewgung-starb**
    * 16:00:16: Parttayyy
* **alester**
    * 16:02:57: is running around naked in a circle
    * 16:04:37: OK, are we about done for today?
    * 16:04:47: I'm going to archive this chat for posterity.
* **cjm**
    * 16:04:59: bye, ackolytes
* **hoelzro**
    * 16:05:08: sounds good
* **ad**
    * 16:05:09: Just a quick question
* **alester**
    * 16:05:19: Thanks to all of you for showing up.  We definitely need to do this again.  People are clearly interested.
    * 16:05:20: Yes, ad?
* **ad**
    * 16:05:34: Any non core modules required now or in the future?
* **alester**
    * 16:05:41: [File::Next](File::Next) is it.
    * 16:06:03: What makes you ask?
* **ad**
    * 16:06:10: Ok, need to look for an easy way to deploy on FreeBSD 
* **alester**
    * 16:06:37: How do you mean?
* **ad**
    * 16:07:10: I mean, I don't want to install ad hoc in every machine
* **alester**
    * 16:07:18: Sure.
    * 16:07:36: I don't see anything on betterthangrep.com where someone has packaged ack
    * 16:07:47: Does FreeBSD have some package system?
* **ad**
    * 16:07:57: Yes, FreeBSD ports
* **alester**
    * 16:07:57: It's in Macports
    * 16:08:04: OK, so someone needs to package ack.
* **ad**
    * 16:08:09: And there is something called bedpan
    * 16:08:17: Damn autocorrect!
    * 16:08:21: Bsdpan
* **alester**
    * 16:08:53: I don't know anything about BSD's packaaging (or anyone's really)
    * 16:09:01: So we'll have to rely on someone else.
    * 16:09:10: Or you can install with "sudo cpan App::Ack"
* **ad**
    * 16:09:25: I was trying to avoid that
* **alester**
    * 16:09:34: Which "that"?
    * 16:09:37: cpan shell?
* **ad**
    * 16:09:41: Yes
* **alester**
    * 16:09:47: Understood.
* **ad**
    * 16:10:24: I'll play around and let you know if there is a way 
* **alester**
    * 16:10:35: It would be useful for ack 1.x, too.
* **ad**
    * 16:11:03: You're Andy Lester of perlbuzz, right? 
    * 16:11:18: I 'll know how to contact you, then
    * 16:11:38: Yes, for 1.x too
* **alester**
    * 16:12:27: That's me.
    * 16:12:35: There's an ack-users mailing list, too.
* **ad**
    * 16:12:43: Noted
* **zitterbewgung-starb**
    * 16:13:18: Do you need someone to package ack for macports?
* **alester**
    * 16:13:27: It's already there, zitterbewgung-starb 
* **zitterbewgung-starb**
    * 16:13:31: oh ok
* **alester**
    * 16:13:35: see betterthangrep.co
    * 16:13:37: .com
* **zitterbewgung-starb**
    * 16:13:48: ok nvm
    * 16:13:58: this chat was fun `:-)`
* **alester**
    * 16:15:32: It was, wasn't it?
    * 16:15:36: And isn't that why we do this?
    * 16:15:45: I will definitely schedule more.
* **hoelzro**
    * 16:16:18: sounds good to me!
* **alester**
    * 16:16:49: Yes, and thanks espeically to hoelzro for kicking me in the ass to get ack 2.0 going again. `:-)`
* **zitterbewgung-starb**
    * 16:16:55: `:-)`
    * 16:17:09: Looks like we even have parts of 2.1 planed out too
* **alester**
    * 16:17:14: but to all of you for showing up and helping and commenting and (presumably) spreading the word about ack.
* **zitterbewgung-starb**
    * 16:17:38: heard about this from your twitter.
* **alester**
    * 16:17:50: zitterbewgung-starb: Which one?  @petdance or @perlbuzz?
* **zitterbewgung-starb**
    * 16:18:32: petdance
* **alester**
    * 16:18:49: I have a todo for Mondy morning to point @petdance people to @perlbuzz and vice versa.
* **zitterbewgung-starb**
    * 16:19:10: oh ok i can follow the other one then
* **alester**
    * 16:19:52: zitterbewgung: Holy cats, you're local, too.
    * 16:20:03: Would you be up for in-person ackathonning, too?
* **zitterbewgung-starb**
    * 16:20:11: Uh possibly
* **alester**
    * 16:20:14: I'm in McHenry, hoelzro is in Madison
* **zitterbewgung-starb**
    * 16:20:18: I don't know much perl
    * 16:20:22: but i'm a quick learner
* **alester**
    * 16:20:22: ok
* **zitterbewgung-starb**
    * 16:20:36: I taught myself python pretty fast
* **alester**
    * 16:20:42: As we've seen this morning,the power of having people together is pretty strong.
* **ad**
    * 16:21:08: Afternoon here `:)`
* **zitterbewgung-starb**
    * 16:23:25: alester: I met you at barcamp . I am located in Darien.
    * 16:23:39: alester: I gave a presentation at barcamp on quantum computation and I bought your book
* **alester**
    * 16:23:58: oh, cool
    * 16:24:05: Did the book do you any good?
* **zitterbewgung-starb**
    * 16:24:28: alester: Well I am probably going to use it in about 6months
* **alester**
    * 16:24:36: Use it NOW
* **zitterbewgung-starb**
    * 16:24:36: Once i finish my degree. 
    * 16:24:43: Yea I should
* **alester**
    * 16:24:46: start your resume now
* **zitterbewgung-starb**
    * 16:25:01: Yea you sent me back my resume and I am going to revise it now
* **hoelzro**
    * 16:28:33: well, I'm outta here people
    * 16:28:41: gotta help my girlfriend with the food-makings.
    * 16:29:03: later!
* **zitterbewgung-starb**
    * 16:29:05: hoelzro: Have fun `:-)`
