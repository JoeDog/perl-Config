#
# Makefile.PL for JoeDog::Config distribution
#
# Filename:	Makefile.PL
# Author:	Tim Funk
# Created:	20 March 2002
#

use ExtUtils::MakeMaker;

&WriteMakefile(
  ABSTRACT       => 'JoeDog::Config module',
  VERSION_FROM   => 'Config.pm',
  PM             => {
     'Config.pm' => '$(INST_LIBDIR)/Config.pm',
   'Iterator.pm' => '$(INST_LIBDIR)/Config/Iterator.pm',
  },
  dist           => {
    'COMPRESS'   => 'gzip -9f', 'SUFFIX'      => 'gz',
    'ZIP'        => '/usr/bin/zip','ZIPFLAGS' => '-rl'
  },
  AUTHOR         => 'Jeff Fulmer <jeff@joedog.org> and  Tim Funk <funkman@joedog.org>',
  NAME           => 'JoeDog::Config'
);
 
