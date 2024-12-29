#!/usr/bin/env python3

import fileinput
from collections import deque
from util import G, L, Lmap

data = Lmap(L(fileinput.input()), lambda line: tuple(map(int, line.split(','))))
# print(data)

dims = (7, 7) # test data = 24 lines, (0..6, 0..6)
if len(data) > 100:
    dims = (71, 71)

g = G.new_dimensions(dims=dims, default_value='.')

sc = (0, 0)
ec = g.xy_max()

for i, ic in enumerate(data):
    g[ic] = '#'

    seen = set()
    found = False

    q = deque([(0, sc)])  # cost, start
    while q:
        d, cc = q.popleft()
        if cc == ec:
            if i == 1023:
                print(i, d)
            found = True
            break

        if cc in seen:
            continue
        seen.add(cc)

        for dc in g.dirs(xy=cc, prune=True):
            # print(f"check {dc}")
            if g[dc] == '#':
                continue
            q.append((d + 1, dc))

    # ignore paths that have a soln
    if found:
        continue

    print(ic)
    break
