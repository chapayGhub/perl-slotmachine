use  strict;
use  warnings;
use Time::HiRes qw(time);

use  SlotMachine;
my $s = SlotMachine->new( symbols => 17, reels => 5 );
my $start;
my $count = 0;
my $pass = "Passphrase";
my $p2   = "0";
my %w = ();

$start = time();
$SIG{INT} = sub(){
    my $end = time();
    print "\n";
    print "Seconds: " .  ( $end - $start ) . "\n";
    print "Count: $count (" . ( $count / ( $end - $start ) ) . " per sec)\n" ;

    foreach( sort keys %w ){
      printf "%2d: %d (%6.2f)\n", $_, $w{$_}, $w{$_} * 100.0 / $count;
    }

    exit( 1 );
};


while( 1 ){
  my @result = $s->roll( $pass, $p2 );
  $p2 = shift @result;
  print join '-', @result ;
  print "\n" ;
  foreach(@result){
    $w{$_} = 0 unless exists $w{$_};
    $w{$_} ++;
  }
  $count ++;
}
