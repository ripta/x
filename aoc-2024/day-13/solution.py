#!/usr/bin/env python3

import fileinput
import sys
from util import L, Pwhen

def int_solns(btn_a, btn_b, prize):
    # print(btn_a, btn_b, prize)
    n = (btn_a['X'] * btn_b['Y'] - btn_a['Y'] * btn_b['X'])
    a = (prize['X'] * btn_b['Y'] - prize['Y'] * btn_b['X']) / n
    b = (prize['Y'] * btn_a['X'] - prize['X'] * btn_a['Y']) / n
    # print(n, a, b)
    if a == int(a) and b == int(b):
        return int(3 * a + b)
    return None

lines = L(fileinput.input())
sects = Pwhen(lines, lambda l: len(l) == 0)

pt1 = pt2 = 0
for sect in sects:
    btn_a, btn_b, prize = {}, {}, {}
    for item in sect:
        typ, kvs = item.split(': ')
        assn = {}
        for kv in kvs.replace('+', '=').split(', '):
            k, v = kv.split('=')
            assn[k] = int(v)

        if typ == 'Button A':
            btn_a = assn
        elif typ == 'Button B':
            btn_b = assn
        elif typ == 'Prize':
            prize = assn
        else:
            print('Unknown type:', typ)
            exit(1)

    tok = int_solns(btn_a, btn_b, prize)
    if tok is not None:
        pt1 += tok

    # pt2's offset
    offset = 10000000000000
    prize['X'] += offset
    prize['Y'] += offset

    tok = int_solns(btn_a, btn_b, prize)
    if tok is not None:
        pt2 += tok


print(pt1)
print(pt2)
