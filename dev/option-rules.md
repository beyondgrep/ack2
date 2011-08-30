First, ack looks for a global ackrc.

* On Windows, this is in either COMMON\_APPDATA or APPDATA.
* On a non-Windows OS, this is `/etc/ackrc`.

Then, ack looks for a user-specific ackrc.
* On Windows, this is `$HOME/_ackrc`, if the HOME environment variable is set.
* On non-Windows systems, this is `$HOME/.ackrc`.

Then, ack looks for a project-specific ackrc file.  ack searches
up the directory hierarchy for the first .ackrc file this is not
one of the ackrc files found in the previous steps.

After ack loads the options from the found ackrc files, ack looks
at the ACKRC\_OPTIONS environment variable.

Finally, ack takes settings from the command line.
