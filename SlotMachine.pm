# vim: set cin sw=2:
use  strict;
use  warnings;

package  SlotMachine;
use  constant{
  JOKER => 999,
  WIN_SIMPLE     => 1,
  WIN_WITH_JOKER => 2,
  WIN_ALL_JOKERS => 3,
};

use  constant WIN_DESCRIPTION => {
  0 => 'Lose',
  1 => 'Win',
  2 => 'Win with joker',
  3 => 'All jokers'
};

# Create new SlotMachine
# Options:
#    payout:       Payout coeficient of the machine. Default 0.92
#    overpay:      Maximun payment over balance. Default 10 coins
#    jp_chance:    Chance of Jackpot. Default 0.001
#    jp_increment: Increment of Jackpot fund on every run. Default 0.07 coins
#    jp_initial:   Initial value of Jackpot. Default 10 coins
#    jp_minimun:   Minimum price of Jackpot. Default 50 coins
#    jp_name:      Name for jackpot. Default jp
#    symbols:      Symbols by reel. Default 6
#    reels:        Reels of machine. Default 3
#    jokers:       Quantity of Jokers. Default 0.
#    win_from:     Quantity of equals result to win. Default: reels
sub  new(;$){
  if( scalar( @_ ) > 2 ){
    my $class = shift;
    my %opts = ();
    while( my $o = shift ){
      $opts{$o} = shift;
    }
    return $class->new( \%opts );
  }
  my ( $class, $opts ) = @_;
  $opts = { } unless $opts;
  $opts->{payout} = 0.92        unless exists $opts->{payout};
  $opts->{overpay} = 10         unless exists $opts->{overpay};
  $opts->{jp_chance} = 0.001    unless exists $opts->{jp_chance};
  $opts->{jp_increment} = 0.07  unless exists $opts->{jp_increment};
  $opts->{jp_initial} = 10      unless exists $opts->{jp_initial};
  $opts->{jp_minimun} = 50      unless exists $opts->{jp_minimun};
  $opts->{jp_name} = 'jp'       unless exists $opts->{jp_name};
  $opts->{symbols} = 6          unless exists $opts->{symbols};
  $opts->{reels} = 3            unless exists $opts->{reels};
  $opts->{jokers} = 0           unless exists $opts->{jokers};
  $opts->{win_from} = $opts->{reels}
                                unless exists $opts->{win_from};
  die "Jokers must be less than or equal than reels" if $opts->{jokers} > $opts->{reels};

  my  $self =  bless $opts,  $class;
  return  $self;
}

# Get/Sets payout of machine
sub  payout(;$){
  my $self = shift;
  $self->{payout} = shift if( scalar(@_) == 1 );
  return $self->{payout};
}

# Get/Sets overpay of machine
sub  overpay(;$){
  my $self = shift;
  $self->{overpay} = shift if( scalar(@_) == 1 );
  return $self->{overpay};
}

# Get/Sets quantity of reels of machine
sub  reels(;$){
  my $self = shift;
  if( scalar(@_) == 1 ){
    $self->_reset();
    $self->{reels} = shift;
  }
  return $self->{reels};
}

# Get/Sets quantity of Jokers
sub  jokers(;$){
  my $self = shift;
  if( scalar(@_) == 1 ){
    my $j = shift;
    die "Jokers must be less than or equal than reels" if $j > $self->reels();
    $self->{jokers} = $j;
    $self->_reset;
  }
  return $self->{jokers};
}

# Get/Sets quantity of symbols of every reel
sub  symbols(;$){
  my $self = shift;
  if( scalar(@_) == 1 ){
    $self->_reset();
    $self->{symbols} = shift;
  }
  return $self->{symbols};
}

# Get/Sets quantity of needed equals result
sub  win_from(;$){
  my $self = shift;
  if( scalar(@_) == 1 ){
    $self->_reset();
    $self->{win_from} = shift;
  }
  return $self->{win_from};
}

# Get/Sets Jackpot increment
sub  jp_increment(;$){
  my $self = shift;
  if( scalar(@_) == 1 ){
    $self->{jp_increment} = shift;
  }
  return $self->{jp_increment};
}

# Get/Sets Jackpot chance
sub  jp_chance(;$){
  my $self = shift;
  if( scalar(@_) == 1 ){
    $self->{jp_chance} = shift;
  }
  return $self->{jp_chance};
}

# Get/Sets Jackpot initial
sub  jp_initial(;$){
  my $self = shift;
  if( scalar(@_) == 1 ){
    $self->{jp_initial} = shift;
  }
  return $self->{jp_initial};
}

# Get array of symbols for reel
sub  symbols_by_reel(;$){
  my $self = shift;
  if( !defined $self->{_array_max} ){
    my @a = $self->_generate_max();
    $self->{_array_max} = \@a;
  }
  if( scalar(@_ ) > 0 ){
    return  $self->{_array_max}->[shift];
  } elsif( wantarray ){
    return  @{$self->{_array_max}};
  } else {
    return $self->{_array_max};
  }
}

# Was the reel a joker?
sub   reel_has_joker($){
  my $self = shift;
  return $self->jokers >= $self->reels - shift;
}

# Iterator for all results
sub  all_results(\&){
  my  @array = ( );
  my  $self = shift;
  my  $ret  = shift;
  my  $antiloop = $self->symbols() ** $self->reels();
  my  $count = 0;
  while( $self->_next( \@array ) ){
    &$ret( @array );
  }
}

# Say all results
sub  print_all_results(;$){
  my  $self = shift;
  my  $verbose = shift;
  my  %w = ();
  my  $count = 0;
  my  $goods = 0;
  $self->all_results( sub{ 
      my  @result = $self->get_result( @_ );
      my  $win = shift( @result );
      $count ++;
      my $d;
      my $numbers = join '.', @result;
      if( $numbers ){
        $d = WIN_DESCRIPTION->{$win} . " ($numbers)";
        $win = $win . ".$numbers";
      } else {
        $d = WIN_DESCRIPTION->{$win};
      }
      $w{$win} = 0 unless defined $w{$win};
      $w{$win} ++;
      print join( ', ', @_ ) . " => $win - " . $d . "\n" if $verbose ; 
    } );

  my  $wres    = scalar(keys(%w)) - 1;
  my  $coins   = int( 0.5 + $count * $self->payout / $wres );

  foreach( sort( keys( %w ) ) ){
    my  $revenue = ( $_ eq 0 ? 0 : int( $coins / $w{$_} ) );
    my  @w = split(/\./, $_);
    my  $d = WIN_DESCRIPTION->{shift(@w)} . " " . join('.', @w );
    printf( "%-28s: %8d (%6.2f): %7d\n", $d , $w{$_}, 
        100.0 * $w{$_} / $count,
        $revenue );
    $goods += $revenue * $w{$_};
  }
  printf "%-28s: %8d\n", "Total", $count ;
  printf "%-28s: %8d\n", "Revenue", $goods ;
  printf "%-28s: %6.2f vs. %6.2f\n", "Real payout %", $goods / $count * 100.0, $self->payout * 100;
  printf "%-28s: %6.2f + %6.2f\n", "Jackpot payout %", $self->jp_increment * 100.0, 
        $self->jp_chance * $self->jp_initial * 100.0;
  printf "%-28s: %6.2f\n", "Total payout %", 
    $goods / $count * 100.0 +
    $self->jp_chance * $self->jp_initial * 100.0 +
    $self->jp_increment * 100.0;
}


# Return result of given symbols
# Result is a array
#   $result[0] is a win type:
#           LOSE (0)
#           WIN_SIMPLE (1):     Win something
#           WIN_WITH_JOKER (2): Win with al least one Joker
#           WIN_ALL_JOKER(3)  : All of symbols are Jokers
#   $result[1..n]
#           numbers of equal symbos (ordered)
#   if WIN_WITH_JOKER is found, the last position of result ($result[-1]) is Joker quantity
#
sub  get_result(@){
  my  $self = shift;
  my  $reels = $self->reels();
  my  $current_reel = 0;
  my  $symbols = $self->symbols();
  my  $jokers    = 0;
  my  $has_symbol = 0;
  my  $has_selected = 0;

  die "Number of results must be equal to reels ($reels)" if $reels != scalar(@_);
  my  $counter = {};

  while( $current_reel < $reels ){
    my  $result = shift;
    if( $result == JOKER ){
      $jokers ++;
    } else {
      $has_symbol = 1;
      if( $counter->{$result} ){
        $counter->{$result} ++;
      } else {
        $counter->{$result} = 1;
      }
    }
    $current_reel ++;
  }

  # Delete unuseful results ...
  my  $tempj = $jokers;
  foreach( sort{ $counter->{$b} <=> $counter->{$a} } keys %{$counter} ){
    if( $counter->{$_} + $tempj < $self->win_from ){
      delete $counter->{$_};
    } elsif( $counter->{$_} >= $self->win_from ){
      $has_selected = 1;
      next;
    } else {
      $tempj -= $self->win_from - $counter->{$_};
      $has_selected = 1;
    }
  }

  return 0 unless $has_selected;

  if( $jokers && !$has_symbol ){
    return  WIN_ALL_JOKERS, $jokers;
  } elsif( $jokers ){
    return  WIN_WITH_JOKER, sort( { $b <=> $a } values %{$counter} ), $jokers;
  } elsif( $has_symbol ){
    return  WIN_SIMPLE, sort { $b <=> $a } values %{$counter};
  } else {
    die "Error of result";
  }
}


sub  run(){
}


sub  _reset(){
  my $self   = shift;
  delete  $self->{_array_max};
  return  1;
}


sub  _next(\@){
  my $self   = shift;
  my $array  = shift;

  if( scalar(@{$array}) == 0 ){
    for( 1..$self->reels ){
      push @{$array}, 1;
    }
    return  1;
  }

  my $reel   = $self->reels() - 1; 
  while( 1 ){
    my $max = $self->symbols_by_reel($reel);
    if( $max <= $array->[$reel] ){
      $array->[$reel] = 1;
      return 0 if( $reel == 0 );
      $reel --;
    } else {
      $array->[$reel] ++;
      $array->[$reel] = JOKER if( $self->reel_has_joker( $reel ) && $max == $array->[$reel] );
      last;
    }
  }
  return 1;
}

sub  _generate_max(){
  my  $self = shift();
  my  @array = ();

  my  $reels = $self->reels();
  my  $symbols = $self->symbols();
  my  $jokers = $self->jokers();
  for( 1..$reels - $jokers ){
    push  @array, $symbols;
  }
  for( 1..$jokers ){
    push  @array, $symbols + 1;
  }
  return  @array;
}

1;
