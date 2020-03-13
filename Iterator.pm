package JoeDog::Config::Iterator;

use FileHandle;
use strict;
use vars qw($VERSION $LOCK_EX $LOCK_UN);
 
$VERSION = '1.0';
$LOCK_EX = 2;
$LOCK_UN = 8;  

=head1 SYNOPSIS
 
  JoeDog::Config::Iterator - Perl extension for iterating configuration files.
 
  use JoeDog::Config::Iterator;
  my $C = new JoeDog::Config::Iterator(filename);

  for(my $C=new JoeDog::Config::Iterator($filename); $C->more(); $C->next()){
    $line = $C->line();
  }

  for(my $C=new JoeDog::Config::Iterator($filename); $C->more(); $C->next()){
    @cols = $C->cols('|');
  }
 
  for(my $C=new JoeDog::Config::Iterator($filename); $C->more(); $C->next()){
    $thing = ($C->cols('|'))[2];
  }

=head1 METHODS
 
=head2 new 

=cut

sub new() {
  my $this  = shift; 
  my $file  = shift;
  my $class = ref($this) || $this;
  my $size  = (stat($file))[7];
  my $FILE  = _open_file($file);
  my $self  = {};

  bless($self, $class);
  $self->{'file'}  = $file;
  $self->{'line'}  = "";
  $self->{'FILE'}  = $FILE;
  $self->{'index'} = 0;
  $self->{'size'}  = $size;
  $self->{'more'}  = 0;
  $self->next();
  return $self;
} 

sub more() {
  my $this = shift;
  return 0 if $this->{'more'};

  my $more = ($this->{'index'} < $this->{'size'}) ? 1 : 0; 
  if(! $more){
    $this->_close_file();
    $this->{'more'} = 1;
  }

  return ($more + $this->{'more'});
}

sub next() {
  my $this = shift;
  my $line = "";
  my $fh   = $this->{'FILE'};

  seek FILE, $this->{'index'}, 0;
  while(<$fh>){
    next if /^$/;
    next if /^\s*#/;
    $line = $_;
    goto BREAK if defined($line) && length($line) > 1;
  } 
  BREAK: $this->{'index'} = tell $fh;  

  $line = trim($line); 
  $this->{'line'} = $line;
  return;
}

sub line() {
  my $this = shift;
  return $this->{'line'};
}

=item b<cols>

  $conf->cols($sep);

  returns an array of items split from the file by $sep
  The separator may be a character or a regular expression.

  $conf->cols("|");
  or  
  $conf->cols(qr/[ ]{4,}/);

  You must use a regex quote-like operator:
  qr/STRING/
  qx/STRING/
  qw/STRING/

=cut
 
sub cols() {
  my $this = shift;
  my $sep  = shift;

  if((length($this->{'line'}) < 1)||($this->{'line'} eq "")){
    return;
  } 
  my @cols;
  if(ref($sep) =~ m/Regexp/i){
    push @cols, (split /$sep/, $this->{'line'});
  } elsif($sep =~ m!\||\/|\\|\<|\>!){
    my $esep = "\\".$sep;
    push @cols, (split /$esep/, $this->{'line'});
  } else {
    push @cols, (split /$sep/, $this->{'line'});
  }

  foreach my $thing (@cols){
    $thing = trim($thing);
  }
  return @cols;
} 

sub _open_file() {
  my $file = shift;
  my $FILE = new FileHandle();

  if($FILE->open("<".$file)){
    flock($FILE, $LOCK_EX);
  } else {
    die "ERROR: cannot open ".$file;
  }
  return $FILE;
}
 
sub _close_file() {
  my $this = shift;

  flock($this->{'FILE'}, $LOCK_UN);
  close($this->{'FILE'});
  return;
} 

sub trim() {
  my $thing = shift;
  $thing =~ s/#.*$//; # trim trailing comments
  $thing =~ s/^\s+//; # trim leading whitespace
  $thing =~ s/\s+$//; # trim trailing whitespace
  return $thing;
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
