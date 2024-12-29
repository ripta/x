#!/usr/bin/env python3

import fileinput
from functools import reduce
from operator import mul
from util import G, L


def sim(dims, rs, t):
    w, h = dims

    q = [0, 0, 0, 0]
    for (px, py), (vx, vy) in rs:
        nx, ny = px + t*vx, py + t*vy
        nx = nx % w
        ny = ny % h

        if nx == w//2 or ny == h//2:
            continue

        if nx < w//2 and ny < h//2:
            q[0] += 1
        elif nx > w//2 and ny < h//2:
            q[1] += 1
        elif nx < w//2 and ny > h//2:
            q[2] += 1
        else:
            q[3] += 1

    return q


def score(q):
    return reduce(mul, q, 1)



lines = L(fileinput.input())

dims = (11, 7)
if len(lines) > 20: # example has a dozen lines
    dims = (101, 103)
print("Dims:", dims)

rs = []
for line in lines:
    p, v = line.split()
    pc = list(map(int, p[2:].split(",")))
    vc = list(map(int, v[2:].split(",")))
    rs.append((pc, vc))

q = sim(dims, rs, 100)
print(q)
print("Pt1 score=", score(q))

qs = []
for i in range(2 * dims[0] * dims[1]): # 2*w*h enough?
    q = sim(dims, rs, i)
    qs.append(score(q))

# ranked = [e[0] for e in sorted(enumerate(qs), key=lambda e: e[1])]
# print("Time 't' with least score:", ranked[:10])

minq = min(qs)
print("Pt2 t=", qs.index(minq)) #, "score=", minq)
