# Before You Report an Issue...

Before you report an issue, please consult the [FAQ](https://beyondgrep.com/documentation/ack-2.16-man.html#faq).

# Asking to add a new filetype, or any enhancement

From the man page:

> All enhancement requests MUST first be posted to the ack-users mailing list at <http://groups.google.com/group/ack-users>.  I will not consider a request without it first getting seen by other ack users.  This includes
> requests for new filetypes.
>
> There is a list of enhancements I want to make to ack in the ack issues list at Github: <https://github.com/beyondgrep/ack2/issues>
>
> Patches are always welcome, but patches with tests get the most attention.

# Reporting an Issue

If you have an issue with ack, please add the following to your ticket:

  - What OS you're on
  - What version of ack you're using

Please try to reproduce your issue against the latest ack from git.  If you are not able to
reproduce the issue with ack built from git, you should probably file the issue anyway, as
that probably means someone needs to make a release. =)

Also appreciated with an issue are the following:

  - Example invocations along with expected vs received output (see [#439](https://github.com/beyondgrep/ack2/issues/439), great job!)
  - A `.t` test file that tests and verifies the behavior you expect
  - A patch that fixes your issue

# Ack 1.x

Keep in mind that if you're using ack 1.x, you should probably upgrade, as ack 1.x is no longer supported.

# Getting Help

Also, feel free to discuss your issues on the [ack mailing list](http://groups.google.com/group/ack-users)!
