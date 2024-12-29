#!/usr/bin/env python3

import fileinput

lines = [list(map(int, line.strip().split())) for line in fileinput.input()]

pt1, pt2 = 0, 0
for ns in lines:
    def ok(ns):
        mono = ns == sorted(ns) or ns == sorted(ns, reverse=True)
        if not mono:
            return False
        for i in range(len(ns) - 1):
            d = abs(ns[i] - ns[i + 1])
            if d < 1 or d > 3:
                return False
        return True

    if ok(ns):
        pt1 += 1
    rt = False
    for i in range(len(ns)):
        ss = ns[:i] + ns[i + 1:]
        if ok(ss):
            rt = True
            break
    if rt:
        pt2 += 1

print(pt1, pt2)