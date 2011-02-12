package main;

require 5.008000;

use strict;
use warnings;
use ExtUtils::MakeMaker;

my %parms = (
    NAME                => 'ack',
    AUTHOR              => 'Andy Lester <andy@petdance.com>',
    ABSTRACT            => 'A grep-like program for searching source code',
    VERSION_FROM        => 'Ack.pm',
    PM                  => {
        'Ack.pm'        => '$(INST_LIBDIR)/App/Ack.pm',
        'Resource.pm'   => '$(INST_LIBDIR)/App/Ack/Resource.pm',
        'Resources.pm'  => '$(INST_LIBDIR)/App/Ack/Resources.pm',
        'Basic.pm'      => '$(INST_LIBDIR)/App/Ack/Resource/Basic.pm',
    },
    EXE_FILES           => [ 'ack' ],
    PREREQ_PM => {
        'Test::Harness'     => 2.50, # Something reasonably newish
        'Term::ANSIColor'   => 0,
        'Getopt::Long'      => 0,
        'Test::More'        => 0,
        'File::Next'        => 0.40,
        'File::Basename'    => 0,
        'Pod::Usage'        => 0,
    },
    MAN3PODS            => {}, # no need for man pages for any of the .pm files
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ack-1* nytprof*' },
);

if ( $ExtUtils::MakeMaker::VERSION =~ /^\d\.\d\d$/ and $ExtUtils::MakeMaker::VERSION > 6.30 ) {
    $parms{LICENSE} = 'artistic_2';
}

if ( $ExtUtils::MakeMaker::VERSION ge '6.46' ) {
    $parms{META_MERGE} = {
        resources => {
            homepage    => 'http://betterthangrep.com/',
            bugtracker  => 'http://github.com/petdance/ack',
            license     => 'http://www.opensource.org/licenses/artistic-license-2.0.php',
            repository  => 'git://github.com/petdance/ack.git',
            MailingList => 'http://groups.google.com/group/ack-users',
        }
    };
}

WriteMakefile( %parms );

package MY;

sub MY::top_targets {
    my $str = shift->SUPER::top_targets(@_);

    $str =~ s/^pure_all.+/$& ack ack-help.txt ack-help-types.txt ack-help-dirs.txt/m;

    return $str;
}

sub MY::postamble {
    my $file_next_filename = qx(perldoc -l File::Next);
    my $postamble = <<'MAKE_FRAG';
ACK            = ack
BASE           = ack-base
ACK_PM         = Ack.pm
RESOURCE_PM    = Resource.pm
RESOURCES_PM   = Resources.pm
BASIC_PM       = Basic.pm
ALL_PM         = $(ACK_PM) $(RESOURCE_PM) $(RESOURCES_PM) $(BASIC_PM)
ACK_HELP       = ack-help.txt
ACK_HELP_TYPES = ack-help-types.txt
ACK_HELP_DIRS  = ack-help-dirs.txt
PERL_T         = $(PERL) -T

.PHONY: tags critic

tags:
	ctags -f tags --recurse --totals \
		--exclude=blib \
		--exclude=.git \
		--exclude='*~' \
		--exclude=$(ACK) \
		--languages=Perl --langmap=Perl:+.t \

$(ACK) : $(BASE) $(ALL_PM) squash Makefile
	$(PERL) squash ack-base File::Next $(ALL_PM) > $(ACK)
	$(CHMOD) 0755 $(ACK)
	$(PERL_T) -c $(ACK)

$(ACK_HELP) : $(ACK)
	$(PERL_T) $(ACK) --noenv --help > $(ACK_HELP) || perl -e0

$(ACK_HELP_TYPES) : $(ACK)
	$(PERL_T) $(ACK) --noenv --help=types > $(ACK_HELP_TYPES) || perl -e0

$(ACK_HELP_DIRS) : $(ACK)
	$(PERL_T) $(ACK) --noenv --help=dirs > $(ACK_HELP_DIRS) || perl -e0

MAKE_FRAG

    return $postamble;
}

1;
