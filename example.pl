use  strict;
use  warnings;

use  SlotMachine;
my $s = SlotMachine->new( symbols => 20, jp_initial => 1, jokers => 3 );
$s->add_payment_simple('3 on line', 100, 3)
  ->add_payment_jackpot('Jackpot', 999 )
  ->add_payment_with_jokers( '3 on line w/1 joker', 30, 2, 1 )
  ->add_payment_with_jokers( '3 on line w/2 jokers', 30, 1, 2 )
  ->add_payment_simple( 'odd', 2, 2, 1 )
  ->print_all_rolls(1);
