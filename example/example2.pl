use  strict;
use  warnings;

use  SlotMachine;
my $s = SlotMachine->new( symbols => 17, reels => 5 );
$s->add_payment_simple('one pair', 1, 2, 1, 1, 1 )
  ->add_payment_simple('two pair', 2, 2, 2, 1 )
  ->add_payment_simple('Three',    3, 3, 1, 1 )
  ->add_payment_simple('Full ',   75, 3, 2 )
  ->add_payment_simple('Four ',  150, 4, 1 )
  ->add_payment_simple('Five ', 2500, 5 )
  ->add_payment_jackpot( 'Jackpot', 1 );

$s->print_all_rolls();
