#!/usr/bin/env perl

# preimplement day-04 in perl before doing it in idris2

my ($total) = 0;
my (@cards) = ();
my (@copies) = ();
my (@points) = ();
foreach my $line (<STDIN>) {
  chomp($line);

  my ($id, $chosen, $mine) = $line =~ /^Card\s+(\d+):\s+([0-9[:space:]]+)\s+\|\s+([0-9[:space:]]+)\s*$/;

  $id = 0 + $id;
  $copies[$id] = 0 unless defined $copies[$id];
  $copies[$id]++;

  my (%chosen) = (map { ((0 + $_) => 1) } split /\s+/, $chosen);
  my (@mine)   = (map { 0 + $_ } split /\s+/, $mine);

  my (@match) = grep { defined $chosen{$_} } @mine;

  my ($points) = 0;
  $points = 2 ** (scalar(@match) - 1) if scalar(@match);

  $total += $points;
  $points[$id] = $points;
  print "  $id: $points\n";

  for my $j (1 .. $copies[$id]) {
    # print "  line=$line\n";
    if (scalar(@match)) {
      for my $i (1 .. scalar(@match)) {
        $copies[$i + $id]++;
      }
    }
  }
}

print "Copies:\n";
my ($card_count) = 0;
for my $i (1 .. $#copies) {
  $card_count += $copies[$i];
  print "  $i: ", $copies[$i], " copies\n";
}
print "\n";

print "Total:\n";
print "  $total points\n";
print "  $card_count cards\n";
