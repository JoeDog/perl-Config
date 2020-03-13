package JoeDog::Config;

use strict;
use vars qw($VERSION $LOCK_EX $LOCK_UN);

$VERSION = '2.05';
$LOCK_EX = 2;
$LOCK_UN = 8;

=head1 SYNOPSIS

  JoeDog::Config - Perl extension for parsing configuration files.

  use JoeDog::Config;
  my $conf   = new JoeDog::Config(filename);
  my @array  = $conf->get_column();
  my @arrays = $conf->get_columns(sep);
  my @AoA    = $conf->get_table(sep,num);
  my @AoA    = $conf->get_table(sep,[num1, num2, etc...]);
  my %hash   = $conf->get_hash(sep);
  my %HoH    = $conf->get_hashes(sep);
  my %ini    = $conf->get_ini($sep);
  my %hash   = $conf->get_distribution();

=head1 METHODS

=item B<new>

  $conf = new JoeDog::Config(filename);

  JoeDog::Config constructor; returns a reference to a JoeDog::Config object.
  If the configuration file is not found or if it is not readable, JoeDog::Config 
  will merrily continue as if nothing happened. Afterall, configuration files are 
  not necessarily mandatory. If you want your program to exit with an error if the
  configuration file is not found or unreadable, call this method before you get 
  data from the file:

  $conf->set_fatal();
  
  Then request the data:

  $conf->get_hashes("="); 

=cut

sub new($) {
  my ($this, $file)   =  @_;
  my $class           =  ref( $this ) || $this;
  my $self            =  {};
  $self->{"file"}     =  $file;
  $self->{"fatal"}    = 0;
  $self->{"debug"}    = 0;
  $self->{"keys"}     = {};
  bless($self, $class);
  return $self;
}

=item B<get_column>

  my @array = $config->get_column();

  Reads a simple configuration file characterized by a single 
  column of data. The method returns a one dimensional array 
  with the contents of the file. Empty lines and lines commented 
  with a # are ignnored:

  Sample file:
  #
  # sample simple config file
  #
  1001
  2112
  5000
  5600
  ... 

  Example method call:
  my $config = JoeDog::Config('/home/jeff/haha.txt');
  my @array  = $config->get_column();
  for ( my $x = 0; $x <= $#array; $x++ ){
    print $array[$x] . "\n";
  }

=cut 

sub get_column
{
  my $this  = shift;
  my @lines;
  if(open(FILE, "<" . $this->{"file"})){
    flock(FILE, $LOCK_EX);
    @lines = grep(!/^\s*#/, grep(!/^$/, <FILE>));
    for(my $x = 0; $x < scalar(@lines); $x++){
      $lines[$x] = trim($lines[$x]);
      $this->debug($lines[$x]);
    }
    flock(FILE, $LOCK_UN);
    close(FILE);
  } else {
    $this->xdie("Unable to read ".$this->{"file"});
  }
  return @lines;
}

=item B<get_columns> 

  my @arrays = $config->get_columns(sep);

  Reads the configuration file referenced by the constructor 
  and returns a multi-dimensional array of columns which were 
  separated by 'sep' in the configuration file. The separator
  may also take form of a regex:

  my @arrays = $config->get_columns(qr/[ ]{2,}/);

  You must use a regex quote-like operator:
  qr/STRING/
  qx/STRING/
  qw/STRING/ 

  Empty lines and lines commented with a # are ignored.

  Sample file:
  #
  # key = value example
  #
  homer  = whoo hoo
  bart   = eat my shorts
  nelson = Hah ha!
  # [etc.]
  
  Example method call:
  my $config = new JoeDog::Config('/home/jeff/haha.txt');
  my @arrays = $config->get_columns("=");
  for(my $x = 0; $x <= $#arrays; $x++){
    for(my $y = 0; $y <= $#{$arrays[$x]}; $y++){
      print $arrays[$x][$y]." ";
    }
    print "\n";
  } 

  Another sample file:
  #
  # flat file database 
  #
  homer  | whoo hoo!      | drinker | minion
  bart   | Eat my shorts  | snarker | poor student
  nelson | Hah ha!        | bully   | poor student
  # [etc.]

  Example method call:
  my $config = new JoeDog::Config('/home/jeff/haha.txt');
  my @arrays = $config->get_columns("|");
  for(my $x = 0; $x <= $#arrays; $x++){
    for(my $y = 0; $y <= $#{$arrays[$x]}; $y++){
      print " {" . $arrays[$x][$y] . "} ";
    }
    print "\n";
  } 

=cut

sub get_columns {
  my $this  = shift;
  my ($sep) = @_;
  my @lines;
  my(@list, @cols);
  if(open(FILE, "<" . $this->{"file"})){
    flock(FILE, $LOCK_EX);
    @lines = grep(!/^\s*#/, grep(!/^$/, <FILE>));
    flock(FILE, $LOCK_UN);
    close(FILE);
  } else {
    $this->xdie("Unable to read ".$this->{"file"});
  }
  my $x = 0;

  foreach my $thing (@lines){
    $thing = trim($thing);
    $this->debug($thing);

    if(ref($sep) =~ m/Regexp/i){
      push @{$cols[$x]}, (split /$sep/, $thing); 
    } elsif($sep =~ m!\||\/|\\|\<|\>!) {
      my $esep = "\\".$sep;
      push @{$cols[$x]}, (split /$esep/, $thing); 
    } else {
      push @{$cols[$x]}, (split /$sep/, $thing); 
    }
    $x ++;
  }

  for(my $x = 0; $x <= $#cols; $x++){
    for(my $y = 0; $y <= $#{$cols[$x]}; $y++){
      $cols[$x][$y] =~ s/^\s+//;
      $cols[$x][$y] =~ s/\s+$//; 
    }
  } 
  return @cols;
}

=item B<get_table($sep,$num)>

  This method can be invoked in one of two ways, you 
  can select the number of columns from left to right
  that you want to include in the table:
    my @aoa = $cnf->get_table(sep, num);

  Or you can select specific columns:
    my @aoa = $cnf->get_table(sep,[num1, num2, etc...]);

  In the first example, we create an array of arrays with
  $num columns, each of which populates a row in the table. 
  In the second example, we can select exactly which columns 
  we want to include, i.e., get_table('|', 1, 3, 5);

  Sample File:

  #      | Volume Entering |              | Inflation Adj.
  #      | Trade  Channels | Retail Sales | Retail Sales
  # Year | (mil. gallons)  | (billions)   | (billions)
  #------+-----------------+--------------+---------------
  2000   | 558             | 19.0         | 20.83
  2001   | 561             | 19.8         | 21.11
  2002   | 595             | 21.1         | 22.16
  2003   | 627             | 21.6         | 22.18
  2004   | 668             | 23.2         | 23.20 

  get_table('|', 2) returns the following structure:
  $VAR1 = [
          '2000',
          '2001',
          '2002',
          '2003'
          '2004'
        ];
  $VAR2 = [
          '558',
          '561',
          '595',
          '627',
          '668',
        ]; 

  get_table('|', 1, 3) returns this structure:
  $VAR1 = [
          '2000',
          '2001',
          '2002',
          '2003'
          '2004'
        ];
  $VAR2 = [
          '19.0',
          '19.8',
          '21.1',
          '21.6',
          '23.2',
        ]; 

  The separator may take the form of a character or a
  regular expression. For example:
    my @aoa = $cnf->get_table('|', 4);
  Or
    my @aoa = $cnf->get_table(qr/\s{2,}/);
 
  You must use a regex quote-like operator:
  qr/STRING/
  qx/STRING/
  qw/STRING/ 

  Example chart using JoeDog::Config and GD::Graph:

  #!/usr/bin/perl
  use JoeDog::Config;
  use GD::Graph::lines;
 
  my $cnf = new JoeDog::Config("wine.txt");
  my @aoa = $cnf->get_table("|", 2);
 
  my $gph = GD::Graph::lines->new(480, 200);

  $gph->set(
    x_label          => 'Year',
    y_label          => 'Total (gallons)',
    long_ticks       => 1,
    dclrs            => [qw(blue)],
    title            => 'Annual Domestic Wine Sales by Volume',
    line_width       => 2,
    x_min_value      => 0,
    x_label_skip     => 2,
    x_label_position => 1/2,
    y_label_position => 1/2,
  );
 
  my $img = $gph->plot(\@aoa) or die $gph->error;
  open    IMG, ">./wine.jpg" or die $!;
  binmode IMG;
  print   IMG  $img->jpeg;
  close   IMG;
 
  exit; 

=cut

sub get_table {
  my $this = shift;
  my $sep  = shift; 
  my $num  = shift unless $#_  > 0;
  my @cols = @_    unless $#_ == 0;
  
  my @data = $this->get_columns($sep);

  my @aoa;
  if($#cols+1 >= 1){
    foreach my $e (@data){
      for(my $x = 0; $x <= $#cols; $x++){
        push @{$aoa[$x]}, $e->[$cols[$x]-1];
      }
    }
  } else {
    foreach my $e (@data){
      for(my $x = 0; $x < $num; $x++){
        push @{$aoa[$x]}, $e->[$x];
      }
    } 
  }

  return @aoa;
}

=item B<get_hash($separator)> 

  my %hash = $config->get_hash($sep); 

  You may also use a regex separator:

  my %hash = $config->get_hash(qr/[ ]{2,}/);

  You must use a regex quote-like operator:
  qr/STRING/
  qx/STRING/
  qw/STRING/  

  This function parses data into a key-value pairs, returns a 
  dynamic hash table where the key is the string before the 
  separator and the value is the string after it.

  Example:
  $config = new JoeDog::Config("$ENV{HOME}/.popcheckrc")
    || warn( "couldn't open $ENV{HOME}/.popcheckrc $!" );
  %config = $config->get_hash("="); 
  my $username = $config{'username'};  
  my $password = $config{'password'};

  Sample file:
  #
  # popcheckrc file
  username = jeff
  password = top_secret

=cut

sub get_hash {
  my $this  = shift;
  my ($sep,$bad_programmer) = @_;
  my (%hash, $hash);
  my $lines = "";
  my (@list, @cols);
  my ($left,$right);

  if(open(FILE, "<" . $this->{"file"})){
    flock(FILE, $LOCK_EX);
    while(<FILE>){
      next if /^$/;
      next if /^\s*#/;
      $lines .= $_;
      $this->debug($_);
    }
    flock(FILE, $LOCK_UN);
    close(FILE);
  } else {
    $this->xdie("Unable to read ".$this->{"file"});
  }

  foreach my $thing (split(/\n/, $lines)){
    if(ref($sep) =~ m/Regexp/i){ 
      ($left,$right) = split(/$sep/, $thing);
    } elsif($sep =~ m!\||\/|\\|\<|\>!) {
      my $esep = "\\".$sep;
      ($left,$right) = split(/$esep/, $thing);
    } elsif($sep =~ m!=!){
      ($left, $right) = split(/$sep/, $thing, 2);
    } else {
      ($left,$right) = split(/$sep/, $thing);
    }

    # Trim begnining and trailing whitespace
    $left  = trim($left);
    $right = trim($right);

    $hash{$left}=$right;
  }
  return %hash;
} 

=item B<get_ini($separator)>

  my %ini = $conf->get_ini($sep);
  my %ini = $conf->get_ini(qr/REGEX/);

  This method reads INI-style files into memory. It parses data 
  into a multi-level data structure and returns a dynamic hash of 
  hashes. 

  This method expects an INI-style configuration file. Each section
  of the file is prefaced with a bracketed prefix. ex: [simpsons] 
  Below each prefix are key value pairs. 
  
  Sample file:
  #
  # comments...
  [jets]
    quarterback = pennington
    runningback = martin
    center      = mawae

  [yankees]
    pitcher   = mussina
    shortstop = jeter
    outfield  = williams

  Example method call:
  my $cnf = new JoeDog::Config('$ENV{HOME}/etc/haha.ini');
  my %ini = $config->get_ini('=');

  # access and print the data. In this example, we sort the
  # prefixes alphabetically and the keys by string length.
  foreach $prefix (sort keys %ini){
    print "[$prefix]\n";
    for $key (sort{ length($a) <=> length($b) } keys %{$ini{$prefix} } ) {
      print "$key=$ini{$prefix}{$key};\n";
    }
    print "\n";
  }
  
  This is a visual interpretation of the data which was 
  parsed from the file above:
  $VAR1 = 'yankees';
  $VAR2 = {
            'outfield' => 'williams',
            'shortstop' => 'jeter',
            'pitcher' => 'mussina'
          };
  $VAR3 = 'jets';
  $VAR4 = {
            'center' => 'mawae',
            'runningback' => 'martin',
            'quarterback' => 'pennington'
          };

  You may add key - value pairs that are not associated with a 
  prefix label.  All such pairs must appear in the configuration 
  file BEFORE the first prefix. All pairs not associated with a 
  prefix will appear under a 'default' key in the structure above.

  Consider this file: 
  Sample file:
  #
  # comments...
  whoohoo = homer simpson
  dar     = sea captain
  zoiks   = shaggy

  [jets]
    quarterback = pennington
    runningback = martin
    center      = mawae

  [yankees]
    pitcher   = mussina
    shortstop = jeter
    outfield  = williams

  Now our structure looks like this:
  $VAR1 = 'yankees';
  $VAR2 = {
            'outfield' => 'williams',
            'shortstop' => 'jeter',
            'pitcher' => 'mussina'
          };
  $VAR3 = 'default';
  $VAR4 = {
            'zoiks' => 'shaggy',
            'whoohoo' => 'homer simpson',
            'dar' => 'sea captain'
          };
  $VAR5 = 'jets';
  $VAR6 = {
            'center' => 'mawae',
            'runningback' => 'martin',
            'quarterback' => 'pennington'
          };

=cut

sub get_ini {
  my $this  = shift;
  my ($sep,$bad_programmer) = @_;
  my (%hash, $rec);
  my $lines = "";
  my ($prefix);
  my ($key, $val);
 
  if(open(FILE, "<" . $this->{"file"})){
    flock(FILE, $LOCK_EX);
    while(<FILE>){
      next if /^$/;
      next if /^\s*#/;
      $lines .= $_;
    }
    flock(FILE, $LOCK_UN);
    close(FILE);
  } else {
    $this->xdie("Unable to read ".$this->{"file"});
  } 

  $prefix = 'default';
  $rec    = {};
  $hash{$prefix} = $rec;
  foreach my $thing (split(/\n/, $lines)){
    $thing =~ s/#.*$//; # trim trailing comments
    $thing =~ s/^\s+//; # trim leading white space
    $thing =~ s/\s+$//; # trim trailing white space
    if($thing =~ m/^\[([^\]]+)\]$/){
      $prefix = $1;
      $rec = {};
      $hash{$prefix} = $rec;
      next;
    } else {
      if(ref($sep) =~ m/Regexp/i){ 
        ($key,$val) = split /$sep/,   $thing, 2;
      } elsif($sep =~ m!\||\/|\\|\<|\>!){
        my $esep = "\\".$sep;
        ($key,$val) = split /$esep/,  $thing, 2;
      } else {
        ($key,$val) = split /$sep/,   $thing, 2;
      }
      $key = trim($key);
      $val = trim($val);
      if((length($key)>0)&&(length($val)>0)){
        $rec->{$key} = $val;
      }
    }
  }
  my @keys = keys(%{$hash{default}});
  if($#keys < 0){
    delete($hash{default});
  }
  return %hash; 
}

=item B<get_hashes>

  $conf->set_key(1, "haha");
  #conf->set_key(2, "papa");
  my %hoh  = $conf->get_hashes();

  This method reads a character separated text file and builds a hash of 
  hashes. In that structure, the first column in the file provides the key 
  of the hash. The keys of the subsequent hashes must be set manually using 
  the set_key method. 

  Example file: 

  #          |       | Double |         | Unfrcd |
  # Date     |  Aces | Faults | Winners | Errors |
  #----------+-------+--------+---------+--------+
  10-1-2008  |   12  |      8 |       4 |      8
  10-2-2008  |   10  |     10 |       8 |      8

  Example code: 

  my $cnf = new JoeDog::Config("etc/hoh.conf");
  $cnf->set_key(1, "Aces");
  $cnf->set_key(2, "Faults");
  $cnf->set_key(3, "Winners");
  $cnf->set_key(4, "Errors");
  my %hoh = $cnf->get_hoh("|");
  print "DATE      |  ACES | FAULTS | WINNERS | ERRORS \n";
  print "----------+-------+--------+---------+--------\n";
  foreach my $key (sort keys(%hoh)){
    printf "%s |  %4d | %6d | %7d | %6d \n",
           $key, $hoh{$key}->{"Aces"}, $hoh{$key}->{"Faults"},
           $hoh{$key}->{"Winners"}, $hoh{$key}->{"Errors"};
  }

  This is the structure of %hoh:

  $VAR1 = '10-1-2008';
  $VAR2 = {
            'Aces' => 12,
            'Errors' => 8,
            'Winners' => 4,
            'Faults' => 8
          };
  $VAR3 = '10-3-2008';
  $VAR4 = {
            'Aces' => 16,
            'Errors' => 18,
            'Winners' => 4,
            'Faults' => 7
          };

=cut 

sub get_hashes() {
  my $this  = shift;
  my ($sep,$bad_programmer) = @_;
  my %hash;

  my @lines;
  if(open(FILE, "<" . $this->{"file"})){
    flock(FILE, $LOCK_EX);
    @lines = grep(!/^\s*#/, grep(!/^$/, <FILE>));
    for(my $x = 0; $x < scalar(@lines); $x++){
      $lines[$x] = trim($lines[$x]);
      $this->debug($lines[$x]);
    }
    flock(FILE, $LOCK_UN);
    close(FILE);
  } else {
    $this->xdie("Unable to read ".$this->{"file"});
  }

  foreach my $line (@lines){
    my @fields;
    if(ref($sep) =~ m/Regexp/i){
      (@fields) = trimlist(split /$sep/,  $line);
    } elsif($sep =~ m!\||\/|\\|\<|\>!){
      my $esep = "\\".$sep;
      (@fields) = trimlist(split /$esep/, $line);
    } else {
      (@fields) = trimlist(split /$sep/,  $line);
    }
    for(my $x = 1; $x < @fields; $x++){
      $hash{$fields[0]}->{$this->{"keys"}->{$x}} = $fields[$x];
    }
  }
  return %hash;
}

sub set_key(){
  my $this = shift;
  my $num  = shift;
  my $key  = shift;
 
  $this->{"keys"}->{$num} = $key;
  return;
}

=item B<get_distribution>

  my $conf = new JoeDog::Config('my.txt');
  my %hash = $conf->get_distribution();

  # print the distribution from highest to lowest
  foreach my $key (sort{$hash{$b} <=> $hash{$a}} keys %hash){
    print $key."|".$hash{$key}."\n";
  } 
 
  Returns a hash in which each unique entry in the config
  file (in this case, my.txt) is a hash key whose value is
  the count of entries in the file. 
  
=cut

sub get_distribution() {
  my $this = shift;
  my %hash;
  open(FILE, "<" . $this->{"file"}) or $this->xdie("unable to read " . $this->{"file"});
  while(my $line = <FILE>){
    next if $line =~ m/^$/;
    next if $line =~ m/^\s*#/;
    chomp $line;
    $line = trim($line);
    $hash{$line} += 1;
  }
  close(FILE);
  return %hash; 
}

=item B<set_fatal()>

  $conf->set_fatal();

  This option tells JoeDog::Config to kill the program if a config
  file is not found or cannot be opened. The program will die with
  an error message;

=cut

sub set_fatal(){
  my $this = shift;
  $this->{"fatal"} = 1;
  return;
}

=item B<set_debug()>
  $conf->set_debug();

  This options turns on debugging. It tells JoeDog::Config to print what it reads to STDOUT;

=cut

sub set_debug(){
  my $this = shift;
  $this->{"debug"} = 1;
  return;
}


=item B<get_filename()>

  $my str = $conf->get_filename();

  Returns the name of the file with with JoeDog::Config
  was instantiated.

=cut 

sub get_filename {
  my $this = shift;
  return $this->{"file"};
}
 
sub trim() {
  my $thing = shift;
  $thing =~ s/#.*$//; # trim trailing comments
  $thing =~ s/^\s+//; # trim leading whitespace
  $thing =~ s/\s+$//; # trim trailing whitespace
  return $thing;
}  

sub trimlist($) {
  my @thing = @_;
  foreach my $thing (@thing){
    $thing =~ s/#.*$//; # trim trailing comments
    $thing =~ s/^\s+//; # trim leading whitespace
    $thing =~ s/\s+$//; # trim trailing whitespace
  }
  return @thing;
}

sub xdie() {
  my $this = shift;
  my $msg  = shift;
  if($this->{"fatal"} == 1){
    print $msg . "\n";
    exit(1);
  }
}

sub debug(){
  my $this = shift;
  my $msg  = shift;

  if(! $this->{"debug"}){
    return;
  } else {
    if($msg =~ /.*\z/){
      print $msg . "\n";
    } else {
      print $msg;
    }
  }
}

##++
## backward compatibility
##--
sub getColumn {
  my $this  = shift;
  my ($sep,$bad_programmer) = @_;
  return $this->get_column($sep); 
}

sub getColumns {
  my $this  = shift;
  my ($sep,$bad_programmer) = @_;
  return $this->get_columns($sep); 
}

sub getHash {
  my $this  = shift;
  my ($sep,$bad_programmer) = @_;
  return $this->get_hash($sep); 
}

sub getHashes {
  my $this  = shift;
  my ($sep,$bad_programmer) = @_; 
  return $this->get_hashes($sep);
}

1;
__END__

# Below is the stub of documentation for your module. You better edit it!

=head1 DESCRIPTION

JoeDog::Config is a module which reads a configuration file and
various data types, arrays, multi-dimensional arrays and hashes.

=head1 AUTHOR

Jeffrey Fulmer, jeff@joedog.org

=head1 SEE ALSO

JoeDog::Config::Iterator 

=cut

