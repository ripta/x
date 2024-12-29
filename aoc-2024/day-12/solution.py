#!/usr/bin/env python3

import fileinput
from collections import deque
from util import G, C

g = G.new_from_lines(fileinput.input())

areas = []
seen = set()
for cc in g:
    if cc in seen:
        continue
    areas.append((g[cc], {cc}))
    q = deque([cc])
    while q:
        nc = q.popleft()
        for dc in g.dirs(xy=nc):
            if dc in seen:
                continue
            if g[dc] == g[cc]:
                seen.add(dc)
                areas[-1][1].add(dc)
                q.append(dc)

# Check areas cover everything:
g2 = g.copy()
for name, area in areas:
    g2.mark(area, '.')
assert all([g2[pt] == '.' for pt in g2])
# for cc in g2:
#     if g2[cc] != '.':
#         print(cc)
# print(f"Areas: {len(areas)}")

pt1, pt2 = 0, 0
for name, area in areas:
    bn = 0 # border
    for cc in area:
        for nc in g.dirs(xy=cc):
            if nc not in area:
                bn += 1
    pt1 += len(area) * bn

    # print(name, area)
    # print(f"  {len(area)} x {bn} = {len(area) * bn}")

    sn = 0 # side
    for dc in g.dirs():
        adds = set()
        for cc in area:
            nc = C.add(cc, dc)
            if nc not in area:
                adds.add(nc)
        sn += len(adds)

        rems = set()
        for cc in adds:
            assert C.dim(cc) == 2

            rdc = C.rev(dc)
            nc = C.add(cc, rdc)
            while nc in adds:
                rems.add(nc)
                nc = C.add(nc, rdc)
        sn -= len(rems)
    pt2 += len(area) * sn

    # print(name, area)
    # print(f"  {len(area)} x {sn} = {len(area) * sn}")

print(pt1, pt2)
