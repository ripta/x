#!/usr/bin/env python3

import fileinput
import functools
import itertools
from itertools import permutations
from util import L, G, C


# key-to-coords on numeric and directional keypads
# ktc = {}
# ktc.update({k: v[0] for k, v in G.new_from_lines(["789", "456", "123", "*0A"], ).content_map().items()})
# ktc.update({k: v[0] for k, v in G.new_from_lines(["*^B", "<v>"]).content_map().items()})
kn = {k: v[0] for k, v in G.new_from_lines(["789", "456", "123", "*0A"]).content_map().items()}
kd = {k: v[0] for k, v in G.new_from_lines(["*^A", "<v>"]).content_map().items()}

# print(kn)
# print(ktc)

# directions
dm = {
    "^": (0, -1),
    "v": (0, 1),
    "<": (-1, 0),
    ">": (1, 0),
}


def movefor(pad, sc, ec, av):
    def le_add(acc, el):
        # print(acc, el)
        return C.add(acc, el)

    dx, dy = C.sub(ec, sc)
    # print(f"movefor: {sc}, {ec}")

    s = ""
    if dx < 0:
        s += '<' * -dx
    else:
        s += '>' * dx
    if dy < 0:
        s += '^' * -dy
    else:
        s += 'v' * dy

    ms = set()
    for ks in permutations(s):
        moves = list(map(dm.get, ks))
        # print(moves, ks, pad)
        if any(coo == av for coo in itertools.accumulate(moves, C.add, initial=sc)):
            continue
        ms.add(''.join(ks) + 'A')

    if ms:
        return list(ms)
    return ['A']


def movelen(code, lim):
    @functools.cache
    def sim(cs, l, d):
        # print()
        # print(f"memo: {cs}, {l}, {d}")
        pad = kd if d else kn
        cc = pad['A'] # start
        # cc = ktc['B' if d else 'A'] # start

        sz = 0
        for c in cs:
            nc = pad[c]
            moves = movefor(pad, cc, nc, pad['*'])
            # print("moves:", moves)

            if l == d:
                sz += len(moves[0]) if moves else 1
            else:
                sz += min(sim(m, l, d+1) for m in moves)

            cc = nc

        return sz

    return sim(code, lim, 0)


def score(codes, lim):
    s = 0
    for c in codes:
        m = movelen(c, lim)
        v = int(c[:-1])
        print(f"  > {c}: {m} * {v} = {m * v}")
        s += m * v
    # return sum(movelen(c, lim) * int(c[:-1]) for c in codes)
    return s

codes = L(fileinput.input())
print(score(codes, 2))
print(score(codes, 25))