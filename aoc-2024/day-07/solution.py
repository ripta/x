#!/usr/bin/env python3
import fileinput
import sys
from functools import reduce
from itertools import product
from util import L

def solve(eqns, ops):
    total = 0
    for t, ss in eqns:
        sols = []
        for opset in product(ops, repeat=len(ss)-1):
            # print(list(enumerate(ss)))
            r = reduce(lambda a, b: (b[0], opset[a[0]](a[1], b[1])), enumerate(ss))
            if r[1] == t:
                sols.append(opset)
                # print(f"{t} == {ss} -> {[opnames[op] for op in opset]}")

        if len(sols) > 0:
            total += t

    return total


eqns = []
for line in L(fileinput.input()):
    tgt, *ss = line.split()
    tgt = int(tgt.rstrip(':'))
    ss = list(map(int, ss))
    eqns.append((tgt, ss))

opadd = lambda a, b: a + b
opmul = lambda a, b: a * b
opcat = lambda a, b: int(str(a) + str(b))

print(solve(eqns, [opadd, opmul]))
print(solve(eqns, [opadd, opmul, opcat]))
