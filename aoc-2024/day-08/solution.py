#!/usr/bin/env python3

import fileinput
from collections import defaultdict

from util import G


def antinode(a1, a2, g, n1, n2):
    x1, y1 = n1
    x2, y2 = n2
    nx = x2 + (x2 - x1)
    ny = y2 + (y2 - y1)

    # Pt.1
    if (nx, ny) in g:
        a1.add((nx, ny))

    # Pt.2
    a2.add((x2, y2))
    while (nx, ny) in g:
        a2.add((nx, ny))
        nx += (x2 - x1)
        ny += (y2 - y1)


g = G.new_from_lines(fileinput.input())
nss = g.content_map()

antis1 = set()
antis2 = set()
for n in nss:
    ns = nss[n]
    for i in range(len(ns)):
        for j in range(i):
            antinode(antis1, antis2, g, ns[i], ns[j])
            antinode(antis1, antis2, g, ns[j], ns[i])

print(len(antis1))
print(len(antis2))
