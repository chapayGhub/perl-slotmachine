# vim: set cin sw=2:
use  strict;
use  warnings;

package  Jackpot;
use Fcntl qw(:flock);


# Create new file
# Parameter:
#     Filename
sub  _create($){
  my $filename = shift;
  die "File $filename already exists" if -e $filename;
  open( my $fh, ">", $filename ) or die( $! );
  print( $fh, pack( "II", 0, 0 ) );
  close( $fh );
}


# Connect to jackpot
sub  connect_to($){
  my ( $class, $filename ) = @_;
  die "Must be called for class" if ref $class;
  _create $filename unless -e $filename;
  open( my $fh, "+<", $filename ) or die( "Error reading " . $filename . " - $!" );
  return bless{ f => $filename, h => $fh };
}

sub  DESTROY{
  my  $self = shift;
  close( $self->{h} ) if $self->{h};
}

sub  _fh(){ return shift->{h}; }
sub  _fn(){ return shift->{f}; }

sub  _lock($){
  my $self = shift;
  flock( $self->_fh, LOCK_EX ) or die "Error locking " . $self->_fn . ": $!";
  seek( $self->_fh, 0, 0 );
}

sub  _unlock($){
  my $self = shift;
  flock( $self->_fh, LOCK_UN ) or die "Error unlocking " . $self->_fn . ": $!";
}

sub  _getdata($){
  my  $self = shift;
  my  $data;
  $self->_lock( );
  read( $self->_fh, $data, 8 ) or die "Error reading - $!";
  $self->_unlock( );
  return unpack "II", $data;
}

sub  _setdata($$$){
  my  $self = shift;
  my  $balance = shift;
  my  $counter = shift;
  my  $data;
  _lock( $self->_fh );
  $data = pack "II", $balance, $counter;
  print( $self->_fh, $data, 8 ) or die "Error writing - $!";
  _unlock( $self->_fh );
}

# Returns Jackpot balance
sub  get(){
  my( $balance, $counter ) = _getdata(shift->{h});
  return $balance / 1000;
}

# Add funds to Jackpot
sub  add($){
  my  $self  = shift;
  my  $funds = shift;
  my( $balance, $counter ) = $self->_getdata();
  $self->_setdata( $balance + $funds * 1000, $counter + 1 );
}

# Retire funds!
sub  retire(){
  my  $self  = shift;
  my( $balance, $counter ) = $self->_getdata();
  my $retire = int( $balance / 1000 );
  $self->_setdata( "II", $balance - $retire * 1000, 0 );
  return  $retire;
}



1;
