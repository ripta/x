#!/usr/bin/env perl

use List::Util qw/none reduce/;
use Data::Dumper qw/Dumper/;

my $hash = sub {
  return reduce { ($a + $b) * 17 % 256 } 0, map { ord } split //, shift;
};

my $hm   = { map { $_ => [] } 0..255 };
my $vals = {};

my $sum1 = 0;
foreach my $line (<STDIN>) {
  chomp $line;

  foreach my $word (split /,/, $line) {
    $sum1 += $hash->($word);

    my ($label, $op, $val) = split /([=-])/, $word;
    #print "$label, $op, $val\n";

    my $key = $hash->($label);
    if ($op eq '-') {
      $hm->{$key} = [grep { $_ ne $label } $hm->{$key}->@*];
    } elsif ($op eq '=') {
      if (none { $_ eq $label } $hm->{$key}->@*) {
        push $hm->{$key}->@*, $label;
      }
      $vals->{$label} = 0+$val;
    }
  }
}

#print Dumper($hm), "\n";
#print Dumper($vals), "\n";

my $sum2 = 0;
foreach my $box (sort keys $hm->%*) {
  foreach my $i (0..($hm->{$box}->$#*)) {
    my $val = $vals->{$hm->{$box}->[$i]};
    $sum2 += ($box + 1) * ($i + 1) * $val;
  }
}

print "Pt1: ", $sum1, "\n";
print "Pt2: ", $sum2, "\n";
