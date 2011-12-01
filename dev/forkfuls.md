# Forkfuls

An old joke: How do you eat an elephant?  One forkful at a time.

* Filetype detection
    * Define and document the types of detection
        * is
        * ext
        * match
        * firstlinematch
    * Code it
* ackrc finding
    * Define the rules in exact English.
        * This includes ACK\_OPTIONS
    * Code it.
* ackrc parsing
    * Define the syntax in exact English.
    * Track the source of every rule.
    * Code it.
* Default /etc/ackrc
    * Create, annotate and document it
    * Will need strong revision control
* Debug mode
    * ack --dump-rules
* File iteration
* File searching
* Results displaying
* Installation
    * Define the rules for placement of /etc/ackrc on all platforms
    * CPAN installer has to install /etc/ackrc
    * ack --install-ackrc
