#!/usr/bin/env python3

import fileinput
import functools
import itertools

from util import Lint

@functools.cache
def sim(num):
    def single(n, _):
        n ^= n << 6   # mult 2^6 then mix
        n &= 0xFFFFFF # 'prune'
        n ^= n >> 5   # divide w/ trunc 2^5 then mix
        n &= 0xFFFFFF # 'prune'
        n ^= n << 11  # mult 2^11 then mix
        n &= 0xFFFFFF # 'prune'
        return n
    return list(itertools.accumulate(range(2000), single, initial=num))


def build_lookup(ps):
    ps = [p % 10 for p in ps]
    deltas = [p2-p1 for p1, p2 in itertools.pairwise(ps)]

    rs = {}
    for i in range(len(deltas)-3):
        s = tuple(deltas[i:i+4])
        if s in rs:
            continue
        rs[s] = ps[i+4]

    return rs


def pt2(nums):
    rss = []
    for num in nums:
        ps = sim(num)
        rs = build_lookup(ps)
        rss.append(rs)

    ks = set()
    for rs in rss:
        ks = ks.union(rs.keys())

    return max(sum(rs.get(k, 0) for rs in rss) for k in ks)


lines = Lint(fileinput.input())
print(sum(sim(line)[-1] for line in lines))
print(pt2(lines))
