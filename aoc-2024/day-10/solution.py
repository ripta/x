#!/usr/bin/env python3
import fileinput
import sys
from util import G
from collections import deque


def valid(g, cc, nc):
    if nc not in g:
        return False
    return g[nc] == g[cc] + 1


def trails(g, sc):
    rcs = set() # pt1. reachable coords
    ups = set() # pt2. unique paths

    #       coords, path, seen
    q = deque([(sc, [sc], {sc})])
    while q:
        # coords, path, seen
        cc, cp, cs = q.popleft()

        if g[cc] == 9:
            rcs.add(cc)
            ups.add(tuple(cp)) # cp is list -> unhashable

        # print(f"current: {cc} {cp} {cs} ({g[cc]})")
        for nc in g.dirs(xy=cc):
            # print(f"next: {nc} ({g[nc]})")
            if nc in cs:
                continue
            if not valid(g, cc, nc):
                continue

            np = cp.copy()
            np.append(nc)

            ns = cs.copy()
            ns.add(nc)

            q.append([nc, np, ns])

    return rcs, ups


def scores(g):
    ss = []
    rs = []
    for head in g.find_all(0):
        rcs, ups = trails(g, head)
        ss.append(len(rcs))
        rs.append(len(ups))
    return ss, rs


g = G.new_from_lines(fileinput.input(), transform=int)
# # print(g)
# ths = g.find_all(0)
# # print(ths)
# print(g.mark(ths, '*'))

ss, rs = scores(g)
# pt1
print(sum(ss))
# pt2
print(sum(rs))
