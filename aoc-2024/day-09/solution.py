#!/usr/bin/env python3

import fileinput
from util import L

def chksum(mem):
    return sum([i * m for i, m in enumerate(mem) if m is not None])


def draw(mem):
    s = []
    for m in mem:
        if m is None:
            s.append('.')
        else:
            s.append(str(m))
    return ''.join(s)


def emulate(mem, used, free, debug=False):
    """
    input = [FILL, SPACE, FILL, SPACE, ;;;]
    """
    if debug:
        print(draw(mem))
        print(used)

    mem = mem.copy()
    used = used.copy()
    free = free.copy()

    for uidx, ufid, ucnt in used:
        for i, (fidx, fcnt) in enumerate(free):
            if fidx < uidx and fcnt >= ucnt:
                for j in range(ucnt):
                    mem[fidx + j] = mem[uidx + j]
                    mem[uidx + j] = None
                free[i] = (fidx + ucnt, fcnt - ucnt)
                break
        if debug:
            print(draw(mem))

    return mem

def fill(input, nofrag=False):
    mem = []
    used = []
    free = []

    mc = 0
    for idx, cnt in enumerate(input):
        if idx % 2 == 0:
            fid = idx // 2
            if nofrag:
                used.insert(0, (mc, fid, cnt))
            for j in range(cnt):
                mem.append(fid)
                if not nofrag:
                    used.insert(0, (mc, fid, 1))
                mc += 1
        else:
            free.append((mc, cnt))
            for j in range(cnt):
                mem.append(None)
                mc += 1
    return mem, used, free



lines = L(fileinput.input())
nums = list(map(int, lines[0]))

# pt.1
mem, used, free = fill(nums)
print(chksum(emulate(mem, used, free)))

# pt.2
mem, used, free = fill(nums, nofrag=True)
print(chksum(emulate(mem, used, free)))
