#!/usr/bin/env python3

import fileinput
import sys
import heapq
# from collections import deque
from itertools import cycle

from util import L, G, C

g = G.new_from_lines(fileinput.input())
# print(g)

dirs = g.dirs()

sc = g.find('S')
ec = g.find('E')

# q = deque([(0, sc, 0)]) # cost, current, direction
q = []
heapq.heappush(q, (0, sc, 0)) # cost, current, direction

dists = {}
seen = set()

best = None
while q:
    sz, cc, di = heapq.heappop(q)
    # sz, cc, di = q.popleft()

    dc = dirs[di]
    if (cc, dc) not in dists:
        dists[cc, dc] = sz
    if cc == ec and best is None:
        best = sz

    if (cc, dc) in seen:
        continue
    seen.add((cc, dc))

    nc = C.add(cc, dc)
    if g[nc] != '#':
        # q.append([sz+1, nc, di])
        heapq.heappush(q, (sz+1, nc, di))
    # q.append([sz+1000, cc, (di+1)%len(dirs)])
    # q.append([sz+1000, cc, (di-1)%len(dirs)])
    heapq.heappush(q, (sz+1000, cc, (di+1)%4))
    heapq.heappush(q, (sz+1000, cc, (di-1)%4))

print(best)

q = []
for di in range(4):
    heapq.heappush(q, (0, ec, di))

dists2 = {}
seen = set()

while q:
    sz, cc, di = heapq.heappop(q)

    dc = dirs[di]
    if (cc, dc) not in dists2:
        dists2[cc, dc] = sz
    if (cc, dc) in seen:
        continue

    seen.add((cc, dc))

    dc = dirs[(di+2)%4]
    nc = C.add(cc, dc)

    if g[nc] != '#':
        heapq.heappush(q, (sz+1, nc, di))
    heapq.heappush(q, (sz+1000, cc, (di+1)%4))
    heapq.heappush(q, (sz+1000, cc, (di-1)%4))

valid = set()
for cc in g:
    for di in range(4):
        dc = dirs[di]
        if (cc, dc) in dists and (cc, dc) in dists2 and dists[cc, dc] + dists2[cc, dc] == best:
            valid.add(cc)
print(len(valid))
