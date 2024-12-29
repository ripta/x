#!/usr/bin/env python3
import fileinput
import re

lines = fileinput.input()
pat = r"(do\(\)|don't\(\)|mul\(([0-9]{1,3}),([0-9]{1,3})\))"

p1, p2 = 0, 0
flip = True, True
for line in lines:
    for m in re.finditer(pat, line):
        if m.group(1).startswith("mul("):
            p1 += int(m.group(2)) * int(m.group(3))
            if flip:
                p2 += int(m.group(2)) * int(m.group(3))
        elif m.group(1).startswith("don't("):
            flip = False
        elif m.group(1).startswith("do("):
            flip = True

print(p1, p2)