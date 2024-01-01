#!/usr/bin/env raku

sub check_adj(%cov, $z0, @b (($x1, $y1, $z1), ($x2, $y2, $z2))) {
  my $ts = SetHash.new();
  #if $z1 - $z0 <= 0 or $z2 - $z0 < 0 {
  if $z1 - $z0 <= 0 or $z2 - $z0 < 0 {
    $ts.set(NaN); # above
  }

  for $x1 .. $x2 -> $x {
    for $y1 .. $y2 -> $y {
      for ($z1 - $z0) .. ($z2 - $z0) -> $z {
        $ts.set(%cov{$x; $y; $z}) if %cov{$x; $y; $z}:exists;
      }
    }
  }

  return $ts;
}

# "1,1,8~1,1,9\n1,0,1~1,2,1\n0,0,2~2,0,2\n0,2,3~2,2,3\n0,0,4~0,2,4\n2,0,5~2,2,5\n0,1,6~2,1,6"
# [ ( (x1 y1 z1) (x2 y2 z2) )
#   ( (x1 y1 z1) (x2 y2 z2) ) ... ]
# dims = [ block ; (begin / end) ; (x, y, z) ]
# my @blocks = $*IN.lines.map(*.split("~").map(*.split(",").map(*.Numeric)))>>.list;
my @blocks = +«$*IN.lines».split("~")».split(",")».list;
#say @blocks;

# max along each axis x, y, z
# z is height (!!)
my @fall_order = @blocks.sort(-> $b { min($b[^2; 2]) });

my %cov;
my @sup;
for @fall_order.kv -> $i, @b (($x1, $y1, $z1), ($x2, $y2, $z2)) {
  my $z0 = 0;
  my $t;
  # say "block=$i ", @b;
  loop {
    $t = check_adj(%cov, $z0 + 1, @b);
    # say "zofs = ", $z0, "  touch = ", $t, " // ", $t.elems;
    last if $t.elems > 0;
    $z0++;
  }

  @sup[$i] = $t;
  for $x1 .. $x2 -> $x {
    for $y1 .. $y2 -> $y {
      for ($z1 - $z0) .. ($z2 - $z0) -> $z {
        %cov{$x; $y; $z} = $i;
      }
    }
  }
}

# my @maxes = [0..2].map(-> $i { @blocks[*;*;$i].max });
# say "Heights = ", @maxes;

my $nah = [∪] @sup.grep(-> $x { $x.elems == 1 });
$nah.unset(NaN);

my $pt1 = @blocks.elems - $nah.elems;
say "Pt1: ", $pt1;

# my $domino = [NaN] xx @blocks.elems;
my $domino = [NaN xx @blocks.elems];
for ^@blocks.elems -> $i {
  my $cascade = SetHash.new($i);
  for ($i+1) .. (@blocks.elems-1) -> $j {
    #$cascade.set(@sup[$j]) if @sup[$j] ⊆ $cascade;
    $cascade.set($j) if @sup[$j] ⊆ $cascade;
    #$cascade.unset(NaN);
  }
  $domino[$i] = $cascade.elems - 1;
}

say "Pt2: ", sum($domino);
