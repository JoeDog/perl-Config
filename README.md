JoeDog::Config - A PERL5 configuration file parser.

ABSTRACT:  
This is a autoloadable module which allows the programmer  
to read data from an configuration file into various perl  
data types, arrays, multi-dimentional arrays and hashes.  
http://www.joedog.org/  

COPYRIGHT  
Config.pm is copyright 2005 by Jeffrey Fulmer & Tim Funk  
and it is covered by the GNU Public License. See COPYING  
for more details.  

INSTALLATION  
JoeDog::Config.pm was built using perl Make::Maker utility  
If you are familiar with  that  utility you should have no  
problem with this installation as it will be familiar:  

  $ perl Makefile.PL  
  $ make  
  $ make test  
  $ su  
  $ make install  

USAGE  
use JoeDog::Config;  
my $cnf = new JoeDog::Config(filename);  
my @array  = $cnf->get_column();  
my @arrays = $cnf->get_columns(sep);  
my @aoa    = $cnf->get_table(sep,num);  
my @aoa    = $cnf->get_table(sep,[num1, num2, etc...]);  
my %hash   = $cnf->get_hash(sep);  
my %hashes = $cnf->get_hashes(sep);  

For greater detail, see: perldoc JoeDog::Config.pm  

