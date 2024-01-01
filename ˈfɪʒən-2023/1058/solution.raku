#!/usr/bin/env raku

sub can_from(%g, Int $from) {
  %g<tubes>{$from}.elems > 0;
}

sub can_to(%g, Int $to) {
  %g<tubes>{$to}.elems < %g<cap>;
}

sub can_move(%g, Int $from, Int $to) {
  can_from(%g, $from) and can_to(%g, $to);
}

sub move(%g, Int $from, Int $to) {
  %g<tubes>{$to}.push(%g<tubes>{$from}.pop());
}

sub solved(%g) {
  so %g<tubes>.values.map(-> $t { $t.reduce: &infix:<eq> }).all
}

sub render(%g) {
  say "---";
  for %g<tubes>.keys.sort -> $n {
    my $t = %g<tubes>{$n};
    say $n, ": ", (^%g<cap>).reverse.map(-> $i { $t[$i] || "_" });
  }
}

sub traverse(%g) {
}

my %tubes = $*IN.lines».split("~").map(-> ($sn, $sps) { (+$sn, $($sps.split('', :skip-empty).reverse)) }).flat».Array;
my %grid = cap => 4, tubes => %tubes;
render(%grid);
# move(%grid, 6, 7);
# render(%grid);

