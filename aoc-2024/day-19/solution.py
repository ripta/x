#!/usr/bin/env python3

import fileinput
import functools


@functools.cache
def chk(d, ps):
    if not d:
        return 1
    return sum(chk(d[len(p):], ps) for p in ps if d.startswith(p))


from util import L, Pwhen

lines = L(fileinput.input())
ps, ds = Pwhen(lines)

ps = tuple(ps[0].split(', '))

print(sum(1 for d in ds if chk(d, tuple(ps))))
print(sum(chk(d, tuple(ps)) for d in ds))
