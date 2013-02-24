# vim: set cin sw=2:
use  strict;
use  warnings;

use  SlotMachine;
unlink './jackpot/myjp.dat' if -e './jackpot/myjp.dat';

my $s = SlotMachine->new( jp_name => 'myjp', jp_increment => 0.10, symbols => 10 );

$s->add_payment_simple( '3 on line', 32, 3 );
$s->add_payment_simple( 'pair', 2, 2, 1 );
$s->add_payment_jackpot( 'Jackpot', 6 );

$s->print_all_rolls();

my $start;
my $count = 0;
my $pass = $ARGV[0] || "";
my $p2   = $ARGV[1] || "";
my %w = ();

my $balance = 0;
my $goods   = 0;
my $bmax    = 0;
my $bmin    = 0;
my $chain   = 0;
my $cmax    = 0;
my $cmax2   = 0;

my $jwin    = 0;
my $jcount  = 0;

sub  stats(){
    my $end = time();
    print "\n";
    print "    Balance: " . $balance . "\n";
    print "    Payout : " . ( $goods * 100 / $count ). "\n";
    print "    Max    : " . $bmax . "  ";
    print "    Min    : " . $bmin . "\n";
    print "    Retires: " . $jwin . "   - Average: " . ( $jwin / $jcount ) . "\n";
    print "    Seconds: " .  ( $end - $start ) . "\n";
    print "    Count  : $count (" . ( $count / ( $end - $start ) ) . " per sec)\n"  if $end > $start;
    print "    Chain  : " . $chain . "  ";
    print "    C.Max  : " . $cmax . "  ";
    print "    C.Max2 : " . $cmax2 . "\n";

    foreach( sort keys %w ){
      printf "%-28s: %d (%6.2f)\n", $_, $w{$_}, $w{$_} * 100.0 / $count;
    }
    print "\n";
}

$SIG{INT} = sub(){
    stats();
    exit( 1 );
};


$start = time();
while( 1 ){
  my @roll = $s->roll( $pass, $p2 );
  $p2 = shift @roll;
  $balance --;
  my ( $result, $description, $revenue ) = $s->get_goods( @roll ); 
  $w{$description} = 0 unless exists  $w{$description};
  $w{$description} ++;
  $balance += $revenue if $revenue;
  if( $result == SlotMachine::WIN_JACKPOT ){
    my $retire = $s->jp_retire();
    $balance += $retire;
    $jwin  += $retire;
    $jcount ++;
    $chain = 0 if $chain < 0 ;
    $chain += $retire - 1;
    $goods += $retire;
    print  "Jackpot! $retire\n";
  } else {
    $s->jp_add();
    if( $revenue > 0 ){
      $chain = 0 if $chain < 0 ;
      $chain += $revenue - 1;
      $goods += $revenue;
    } else {
      $chain --;
      if( $chain == 0 ){
        print "Good chain: $cmax2 \n" if $cmax2 > 20; 
        $cmax2 = 0;
      }
    }
  }


  $bmax = $balance if( $balance > $bmax );
  $bmin = $balance if( $balance < $bmin );
  $cmax = $chain   if( $chain > $cmax );
  $cmax2 = $chain   if( $chain > $cmax2 );
  $count ++;

  # stats() if $result == SlotMachine::WIN_JACKPOT ;
  stats() if $count % 10000 == 0;
}
  
