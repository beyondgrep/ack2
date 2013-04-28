package main;

require 5.008008;

use strict;
use warnings;
use ExtUtils::MakeMaker;

my $debug_mode = (grep { $_ eq '--debug' } @ARGV) ? '--debug' : '';

my %parms = (
    NAME                => 'ack',
    AUTHOR              => 'Andy Lester <andy@petdance.com>',
    ABSTRACT            => 'A grep-like program for searching source code',
    VERSION_FROM        => 'Ack.pm',

    PM                  => {
        'Ack.pm'            => '$(INST_LIBDIR)/App/Ack.pm',
        'Resource.pm'       => '$(INST_LIBDIR)/App/Ack/Resource.pm',
        'Resources.pm'      => '$(INST_LIBDIR)/App/Ack/Resources.pm',
        'Basic.pm'          => '$(INST_LIBDIR)/App/Ack/Resource/Basic.pm',
        'ConfigDefault.pm'  => '$(INST_LIBDIR)/App/Ack/ConfigDefault.pm',
        'ConfigFinder.pm'   => '$(INST_LIBDIR)/App/Ack/ConfigFinder.pm',
        'ConfigLoader.pm'   => '$(INST_LIBDIR)/App/Ack/ConfigLoader.pm',
        'Filter.pm'         => '$(INST_LIBDIR)/App/Ack/Filter.pm',
        'Extension.pm'      => '$(INST_LIBDIR)/App/Ack/Filter/Extension.pm',
        'FirstLineMatch.pm' => '$(INST_LIBDIR)/App/Ack/Filter/FirstLineMatch.pm',
        'Is.pm'             => '$(INST_LIBDIR)/App/Ack/Filter/Is.pm',
        'Match.pm'          => '$(INST_LIBDIR)/App/Ack/Filter/Match.pm',
        'Default.pm'        => '$(INST_LIBDIR)/App/Ack/Filter/Default.pm',
        'Inverse.pm'        => '$(INST_LIBDIR)/App/Ack/Filter/Inverse.pm',
    },
    EXE_FILES               => [ 'ack' ],

    MIN_PERL_VERSION        => 5.008008,
    PREREQ_PM => {
        'Carp'              => '1.04',
        'Cwd'               => '3.00',
        'File::Basename'    => '1.00015',
        'File::Glob'        => '1.00015',
        'File::Next'        => '1.10',
        'File::Spec'        => '3.00',
        'File::Temp'        => '0.19', # For newdir()
        'Getopt::Long'      => '2.35',
        'Pod::Usage'        => '1.26',
        'Term::ANSIColor'   => '1.10',
        'Test::Harness'     => '2.50', # Something reasonably newish
        'Test::More'        => '0.98', # For subtest()
        'Text::ParseWords'  => '3.1',
    },
    MAN3PODS            => {}, # no need for man pages for any of the .pm files
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ack-2* nytprof* stderr.log stdout.log' },
);

if ( $ExtUtils::MakeMaker::VERSION =~ /^\d\.\d\d$/ and $ExtUtils::MakeMaker::VERSION > 6.30 ) {
    $parms{LICENSE} = 'artistic_2';
}

if ( $ExtUtils::MakeMaker::VERSION ge '6.46' ) {
    $parms{META_MERGE} = {
        resources => {
            homepage    => 'http://beyondgrep.com/',
            bugtracker  => 'http://github.com/petdance/ack2',
            license     => 'http://www.perlfoundation.org/artistic_license_2_0',
            repository  => 'git://github.com/petdance/ack2.git',
            MailingList => 'http://groups.google.com/group/ack-users',
        }
    };
}

WriteMakefile( %parms );

package MY;

# supress EU::MM test rule
sub MY::test {
    return '';
}

sub MY::postamble {
    # was this next line used for something???
    # my $file_next_filename = qx(perldoc -l File::Next);

    my $postamble = sprintf(<<'MAKE_FRAG', $debug_mode);
ACK               = ack
ACK_PM            = Ack.pm
RESOURCE_PM       = Resource.pm
RESOURCES_PM      = Resources.pm
BASIC_PM          = Basic.pm
CONFIG_DEFAULT_PM = ConfigDefault.pm
CONFIG_FINDER_PM  = ConfigFinder.pm
CONFIG_LOADER_PM  = ConfigLoader.pm
FILTER_PM         = Filter.pm
EXT_FILTER_PM     = Extension.pm
FIRST_FILTER_PM   = FirstLineMatch.pm
IS_FILTER_PM      = Is.pm
MATCH_FILTER_PM   = Match.pm
DEFAULT_FILTER_PM = Default.pm
INVERSE_FILTER_PM = Inverse.pm
ALL_PM            = $(ACK_PM) $(RESOURCE_PM) $(RESOURCES_PM) $(BASIC_PM) $(FILTER_PM) $(EXT_FILTER_PM) $(FIRST_FILTER_PM) $(IS_FILTER_PM) $(MATCH_FILTER_PM) $(DEFAULT_FILTER_PM) $(INVERSE_FILTER_PM) $(CONFIG_FINDER_PM) $(CONFIG_LOADER_PM) $(CONFIG_DEFAULT_PM)

TEST_VERBOSE=0
TEST_FILES=t/*.t t/lib/*.t
TEST_XT_FILES=xt/*.t

.PHONY: tags critic

tags:
	ctags -f tags --recurse --totals \
		--exclude=blib \
		--exclude=.git \
		--exclude='*~' \
		--exclude=ack-standalone \
		--languages=Perl --langmap=Perl:+.t \

critic:
	perlcritic -1 -q -profile perlcriticrc $(ACK) $(ALL_PM) t/*.t

ack-standalone : $(ACK) $(ALL_PM) squash Makefile
	$(PERL) squash %s $(ACK) File::Next $(ALL_PM) > ack-standalone
	$(FIXIN) ack-standalone
	-$(NOECHO) $(CHMOD) $(PERM_RWX) ack-standalone
	$(PERL) -i -p -e "s/\\\$$GIT_REVISION\s*=\s*''/\\\$$GIT_REVISION = q{$$(git rev-parse --short HEAD)}/" ack-standalone
	$(PERL) -c ack-standalone

bininst : $(ACK)
	$(CP) $(ACK) ~/bin/ack2
	$(CP) ackrc ~/.ack2rc

test: test_classic test_standalone

fulltest: test_classic test_standalone test_xt

test_classic: all
	$(FULLPERLRUN) t/runtests.pl 0 $(TEST_VERBOSE) "$(INST_LIB)" "$(INST_ARCHLIB)" $(TEST_FILES)

test_standalone: all ack-standalone
	$(FULLPERLRUN) t/runtests.pl 1 $(TEST_VERBOSE) "$(INST_LIB)" "$(INST_ARCHLIB)" $(TEST_FILES)

test_xt: all
	$(FULLPERLRUN) t/runtests.pl 0 $(TEST_VERBOSE) "$(INST_LIB)" "$(INST_ARCHLIB)" $(TEST_XT_FILES)

PROF_ARGS = -Mblib blib/script/ack foo ~/parrot

nytprof: all
	$(PERL) -d:NYTProf $(PROF_ARGS) >> /dev/null 2>&1
	nytprofhtml

TIMER_ARGS=foo ~/parrot > /dev/null
time-ack196:
	time $(PERL) ./garage/ack196 --noenv $(TIMER_ARGS)

time-ack202:
	time $(PERL) ./garage/ack202 --noenv $(TIMER_ARGS)

time-ack20301:
	time $(PERL) ./garage/ack20301 --noenv $(TIMER_ARGS)

time-ack20302:
	time $(PERL) ./garage/ack20302 --noenv $(TIMER_ARGS)

time-head: ack-standalone
	time $(PERL) ./ack-standalone --noenv $(TIMER_ARGS)

timings: ack-standalone
	./dev/timings.pl

MAKE_FRAG

    return $postamble;
}

1;
