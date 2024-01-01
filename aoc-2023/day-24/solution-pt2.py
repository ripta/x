#!/usr/bin/env python3
#
# I should learn how to use z3py lol, but I know enough smt2 to be dangerous.
# *runs with knife* See solution-pt2.sh to see how to invoke.

import sys

lines = sys.stdin.read().strip().split("\n")
stones = [[[int(i) for i in seg.split(", ")] for seg in line.split(" @ ")] for line in lines]

# s* variables for solution -- six unknowns here
preamble = """
(declare-fun sx () Int)
(declare-fun sy () Int)
(declare-fun sz () Int)
(declare-fun svx () Int)
(declare-fun svy () Int)
(declare-fun svz () Int)
"""

# six unknowns in preamble plus extra unknown 'time' component per stone.
# each stone provides 3 equations (x, y, z)
#       6 + x <= 3x
#           6 <= 2x
#           3 <= x
# so 3 stones should be sufficient? give 4 to be sure.
n = 4

print(preamble)
for i in range(n):
    ((x, y, z), (vx, vy, vz)) = stones[i]
    print(f"(declare-fun t_{i} () Int)")
    print(f"(assert (= (+ {x} (* {vx} t_{i})) (+ sx (* svx t_{i}))))")
    print(f"(assert (= (+ {y} (* {vy} t_{i})) (+ sy (* svy t_{i}))))")
    print(f"(assert (= (+ {z} (* {vz} t_{i})) (+ sz (* svz t_{i}))))")

print('(check-sat)')

print('(get-value (sx))')
print('(get-value (sy))')
print('(get-value (sz))')
