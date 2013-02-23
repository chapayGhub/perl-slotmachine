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
  return bless{ f => $filename };
}

sub  _getdata($){
  my  $filename = shift;
  my  $data;
  open( my $fh, "<", $filename ) or die( "Error locking " . $filename . " - $!" );
  flock( $fh, LOCK_EX ) or die "Error locking " . $filename . " - $!";
  read( $fh, $data, 8 ) or die "Error reading " . $filename . " - $!";
  close( $fh );
  return unpack "II", $data;
}

# Returns Jackpot balance
sub  get(){
  my( $balance, $counter ) = _getdata(shift->{f});
  return $balance / 1000;
}

# Add funds to Jackpot
sub  add($){
  my  $filename = shift->{f};
  my  $funds    = shift;
  my  $data;
  open( my $fh, "<", $filename ) or die( "Error locking " . $filename . " - $!" );
  flock( $fh, LOCK_EX ) or die "Error locking " . $filename . " - $!";
  read( $fh, $data, 8 ) or die "Error reading " . $filename . " - $!";
  my( $balance, $counter ) = unpack "II", $data;
  print( $fh, pack( "II", $balance + $funds * 1000, $counter + 1 ) );
  close( $fh );
}

# Retire funds!
sub  retire(){
  my  $filename = shift->{f};
  my  $data;
  open( my $fh, "<", $filename ) or die( "Error locking " . $filename . " - $!" );
  flock( $fh, LOCK_EX ) or die "Error locking " . $filename . " - $!";
  read( $fh, $data, 8 ) or die "Error reading " . $filename . " - $!";
  my( $balance, $counter ) = unpack "II", $data;
  my $retire = int( $balance / 1000 );
  print( $fh, pack( "II", $balance - $retire * 1000, 0 ) );
  close( $fh );
  return  $retire;
}



1;
