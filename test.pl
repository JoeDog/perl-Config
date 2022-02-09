use strict;
 
my @test = (
  0, #  1, load module 
  0, #  2, get_column 
  0, #  3, get_columns 
  0, #  4, get_hash - sounds illegal;
  0, #  5, get_hashes 
  0, #  6, get_table  
  0, #  7, get_distribution
  0, #  8, iterator test
  0, #  9, get_ini (somewhat redundant)
  0, # 10, get_columns(qr/REGEX/);
  0, # 11, get_hoh
);
my $test  = @test;
print "1..".$test."\n";

our $loaded;
our $debug = 0;
 
BEGIN { $| = 1; }
END   { print "not ok $test\n" unless $loaded; }  

{
  $test   = 1;
  $loaded = 0;
  use JoeDog::Config;

  $loaded = 1;
  print "ok $test\n";
}


{
  $test   = 2;
  $loaded = 0;
  use JoeDog::Config;

  my $conf = new JoeDog::Config("examples/array.conf");
  $conf->set_debug() if $debug;

  my @array  = $conf->get_column();
  print "data: " if $test[1]; 
  for (my $x = 0; $x <= $#array; $x++){
    print $array[$x] . " " if $test[1];
  } 
  print "\n" if $test[1];

  $loaded = 1;
  print "ok $test\n";
}

{
  $test   = 3;
  $loaded = 0;
  use JoeDog::Config;

  my $conf = new JoeDog::Config('examples/arrays.conf');
  $conf->set_debug() if $debug;

  my @arrays = $conf->get_columns("=");
  print "data: " if $test[2];
  for (my $x = 0; $x <= $#arrays; $x++) {
    print $arrays[$x][1] . " " if $test[2];
  } 
  print "\n" if $test[2];
  $loaded = 1;
  print "ok $test\n";
}

{
  $test   = 4;
  $loaded = 0;
  my $conf = new JoeDog::Config("examples/hash.conf");
  $conf->set_debug() if $debug;

  my %conf = $conf->get_hash("|");
  print "data: " if $test[3];
  foreach my $key (sort(keys %conf)){
    print $conf{$key} . " " if $test[3];
  }
  print "\n" if $test[3];
  $loaded = 1;
  print "ok $test\n";
}

{
  $test   = 5;
  $loaded = 0;
  use JoeDog::Config;

  my $config = new JoeDog::Config('examples/hashes.conf');
  my %hashes = $config->get_ini('=');
 
  # access and print the data. In this example, we sort the
  # prefixes alphabetically and the keys by string length.
  foreach my $prefix (sort keys %hashes){
    print "$prefix:\n" if $test[4];
    for my $key (sort{ length($a) <=> length($b) } keys %{ $hashes{$prefix} } ) {
      print "$key=$hashes{$prefix}{$key};\n" if $test[4];
    }
  }
  $loaded = 1;
  print "ok $test\n";
}

{
  $test   = 6;
  $loaded = 0;
  use JoeDog::Config;

  my $cnf = new JoeDog::Config('examples/aoa.conf');
  $cnf->set_debug() if $debug;

  my @aoa = $cnf->get_table('|', 1, 4);
  foreach my $e (@aoa) {
    for (my $x = 0; $x < 5; $x++) {
      print "{ ". $e->[$x] . " }" if $test[5];
    }
    print "\n" if $test[5];
  }

  $loaded = 1;
  print "ok $test\n";
}

{
  $test   = 7;
  $loaded = 0;
  use JoeDog::Config;

  my $cnf  = new JoeDog::Config('examples/array.conf');
  $cnf->set_debug() if $debug;

  my %hash = $cnf->get_distribution();

  foreach my $key (sort keys(%hash)){
    print $key."|".$hash{$key}."\n" if $test[$test-1];
  } 
 
  $loaded = 1;
  print "ok $test\n";
}

{
  $test    = 8;
  $loaded  = 0;
  my $line = "";
  use JoeDog::Config::Iterator;

  for(my $conf = new JoeDog::Config::Iterator('examples/aoa.conf'); $conf->more(); $conf->next()){
    $line .= ($conf->cols('|'))[2];
  }
  print $line . "\n" if $test[$test-1];
  $loaded = 1;
  print "ok $test\n";
}

{
  $test    = 9;
  $loaded  = 0;
  my $conf = new JoeDog::Config("examples/users.conf");
  $conf->set_debug() if $debug;

  my %hash = $conf->get_ini("=");
  foreach my $name (keys(%hash)){
    print "[$name]\n"                             if $test[8]; 
    print "  group:  ".$hash{$name}{group}."\n"   if $test[8];
    print "  type:   ".$hash{$name}{type}."\n"    if $test[8];
    print "  home:   ".$hash{$name}{home}."\n"    if $test[8];
    print "  backup: ".$hash{$name}{backup}."\n"  if $test[8]; 
  } 
  $loaded = 1;
  print "ok $test\n";
}

{
  $test    = 10;
  $loaded  = 0;
  my $conf = new JoeDog::Config("examples/spaces.conf");
  $conf->set_debug() if $debug;

  my @cols = $conf->get_columns(qr/\s{2,}/);
  foreach my $row (@cols){
    print $row->[0] . " | " . $row->[1] . "\n" if $test[$test-1];
  } 
  $loaded = 1;
  print "ok $test\n";
}

{
  $test   = 11;
  $loaded = 0;
  my $cnf = new JoeDog::Config("examples/hoh.conf");
  $cnf->set_debug() if $debug;
  $cnf->set_key(1, "Aces");
  $cnf->set_key(2, "Faults");
  $cnf->set_key(3, "Winners");
  $cnf->set_key(4, "Errors");
  my %hoh = $cnf->get_hashes("|");
  print "DATE      |  ACES | FAULTS | WINNERS | ERRORS \n" if $test[$test-1];
  print "----------+-------+--------+---------+--------\n" if $test[$test-1];
  foreach my $key (sort keys(%hoh)){
    printf "%s |  %4d | %6d | %7d | %6d \n",
           $key, $hoh{$key}->{"Aces"}, $hoh{$key}->{"Faults"},   
           $hoh{$key}->{"Winners"}, $hoh{$key}->{"Errors"} if $test[$test-1];
  }

  $loaded = 1;
  print "ok $test\n";  
}


