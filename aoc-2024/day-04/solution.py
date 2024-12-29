#!/usr/bin/env python3

import fileinput
from util import G, L

lines = L(fileinput.input())
g = G.new_from_lines(lines, ".")

pt1, pt2 = 0, 0
find = "XMAS"
find2 = ["MS", "SM"]
for x, y in g:
    # pt2
    if g[x, y] == "A":
        if g[x - 1, y - 1] + g[x + 1, y + 1] not in find2:
            continue
        if g[x - 1, y + 1] + g[x + 1, y - 1] not in find2:
            continue
        pt2 += 1

    if g[x, y] != "X":
        continue

    # pt1
    for dx, dy in g.diags():
        ok = True
        for d in range(4):
            ax, ay = x + (dx * d), y + (dy * d)
            if g[ax, ay] != find[d]:
                # print("bad", ax, ay, g[ax, ay], "!=", find[d])
                ok = False
        if ok:
            pt1 += 1

print(pt1, pt2)
