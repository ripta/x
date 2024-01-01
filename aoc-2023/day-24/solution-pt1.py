#!/usr/bin/env python3

import sys
from itertools import combinations

def det(a, b):
    return a[0] * b[1] - a[1] * b[0]

def intersect(line1, line2):
    xdiff = (line1[0][0] - line1[1][0], line2[0][0] - line2[1][0])
    ydiff = (line1[0][1] - line1[1][1], line2[0][1] - line2[1][1])

    dd = det(xdiff, ydiff)
    if dd == 0:
        return None

    d = (det(line1[0], line1[1]), det(line2[0], line2[1]))
    x = det(d, xdiff) / dd
    y = det(d, ydiff) / dd
    return (x, y)

def stone_to_line(stone):
    (spos, delta) = stone
    p1 = (spos[0], spos[1])
    p2 = (spos[0] + delta[0], spos[1] + delta[1])
    return (p1, p2)

def in_past_c(s, d, p):
    if p < s:
        return d > 0
    if p > s:
        return d < 0
    return False

def in_past(stone, point):
    (spos, delta) = stone
    return in_past_c(spos[0], delta[0], point[0]) or in_past_c(spos[1], delta[1], point[1])

def stonetersect(stone1, stone2):
    line1 = stone_to_line(stone1)
    line2 = stone_to_line(stone2)
    pint = intersect(line1, line2)
    if pint is None:
        return None
    if in_past(stone1, pint) or in_past(stone2, pint):
        return None
    return pint

lines = sys.stdin.read().strip().split("\n")
stones = [[[int(i) for i in seg.split(", ")] for seg in line.split(" @ ")] for line in lines]

#bounds = (7, 27)
#bounds = (200000000000000, 400000000000000)
bounds = (int(sys.argv[1]), int(sys.argv[2]))
counts = 0
for combi in combinations(range(len(stones)), 2):
    (a, b) = combi
    (sa, sb) = (stones[a], stones[b])
    q = stonetersect(sa, sb)
    if q is None:
        continue
    (qa, qb) = q
    if qa < bounds[0] or qb < bounds[0] or qa > bounds[1] or qb > bounds[1]:
        continue
    counts += 1
    print(q)

print(counts)
