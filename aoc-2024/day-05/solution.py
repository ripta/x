#!/usr/bin/env python3

import fileinput
from collections import defaultdict
from util import L, Pwhen

lines = L(fileinput.input())
rr, ur = Pwhen(lines, lambda line: line == "")

rs = defaultdict(list)
for r in rr:
    k, v = map(int, r.split("|"))
    rs[k].append(v)

uss = []
for u in ur:
    uss.append(list(map(int, u.split(","))))

def valid(us, rs):
    for i, x in enumerate(us):
        if x not in rs:
            continue

        for y in rs[x]:
            if y not in us:
                continue

            if y not in us[i + 1:]:
                return False
    return True

def pt1(uss, rs):
    ans = 0
    for us in uss:
        if valid(us, rs):
            m = len(us) // 2
            ans += us[m]
    return ans

def pt2(uss, rs):
    ans = 0
    for us in uss:
        if not valid(us, rs):
            ts, js = [], set()
            while len(ts) < len(us):
                for u in us:
                    if u in js:
                        continue
                    # UGH WHYYYYYY
                    ok = True
                    for k, vs in rs.items():
                        if k not in us: ##
                            continue
                        if k in js: ##
                            continue
                        if u in vs: ##
                            ok = False
                            break

                    if ok:
                        ts.append(u)
                        js.add(u)
                        break

            ans += ts[len(ts) // 2]
    return ans

print(pt1(uss, rs))
print(pt2(uss, rs))
