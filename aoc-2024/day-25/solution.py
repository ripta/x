#!/usr/bin/env python3

import fileinput
from util import L, Pwhen

segs = Pwhen(L(fileinput.input()))

coll = [set((x, y) for y, line in enumerate(seg) for x, c in enumerate(line) if c == "#") for seg in segs]
print(sum(1 for i, x in enumerate(coll[:-1]) for y in coll[i + 1:] if not x.intersection(y)))
