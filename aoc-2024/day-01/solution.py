#!/usr/bin/env python3

import fileinput

lines = [line.strip().split() for line in fileinput.input()]

l = [int(i[0]) for i in lines]
r = [int(i[1]) for i in lines]

def pt1(lines, l, r):
    l, r = l.copy(), r.copy()
    s = 0
    for i in range(len(lines)):
        ml = max(l)
        mr = max(r)
        s += abs(ml - mr)
        l.remove(ml)
        r.remove(mr)
    return s

def pt2(l, r):
    l, r = l.copy(), r.copy()
    s = 0
    for i in l:
        s += i * r.count(i)
    return s

print(pt1(lines, l, r))
print(pt2(l, r))
