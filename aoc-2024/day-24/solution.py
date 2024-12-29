#!/usr/bin/env python3
import fileinput
from util import L, Pwhen


def single(g, ws):
    ivs = []
    for iw in g[1]:
        if iw not in ws:
            return False
        ivs.append(ws[iw])

    if g[0] == 'AND':
        ov = 1 if ivs[0] and ivs[1] else 0
    elif g[0] == 'OR':
        ov = 1 if ivs[0] or ivs[1] else 0
    elif g[0] == 'XOR':
        ov = 1 if ivs[0] != ivs[1] else 0

    ws[g[2]] = ov
    return True


def sim(gs, ws):
    ws = ws.copy()

    done = set()
    while len(done) < len(gs):
        for i, g in enumerate(gs):
            if i in done:
                continue
            if single(g, ws):
                done.add(i)

    return ws


def output(ws):
    zs = sorted([w for w in ws if w.startswith('z')])
    return sum(ws[z] * pow(2, i) for i, z in enumerate(zs))


wl, gl = Pwhen(L(fileinput.input()))

ws = {}
for l in wl:
    w, v = l.split(': ')
    ws[w] = int(v)

gs = []
for l in gl:
    gi, go = l.split(' -> ')
    g1, gt, g2 = gi.split()
    gs.append((gt, [g1, g2], go))

# pt.1
ws1 = sim(gs, ws)
print(output(ws1))

# pt.2
#
# full adder logical expreshuns - https://cvbl.iiita.ac.in/sks/coa-files/tutorial/Tutorial-5.pdf
#
#   sum = cin xor (a xor b)
#   cout = (a and b) or (cin and (a xor b))
#
# so search for:
#
#   (a xor b), (a and b) and (cin and (a xor b))
#     gate1      gate2             gate3
#
# aka:
#   (a xor b), (a and b) and (cin and gate1)
cands = set()

## Begin gate1
for g in gs:
    gt, (g1, g2), go = g
    if gt != 'XOR':
        continue
    if not g1.startswith('x') and not g2.startswith('x'):
        continue
    if 'x00' in [g1, g2]:
        if go != 'z00':
            cands.add(go)
        continue
    if go == 'z00':
        cands.add(go)
        continue
    if go.startswith('z'):
        cands.add(go)
        continue
## End Gate1

## Begin Gate2
for g in gs:
    gt, (g1, g2), go = g
    if gt != 'XOR':
        continue
    if g1.startswith('x') or g2.startswith('x'):
        continue
    if go.startswith('z'):
        continue
    cands.add(go)
## End Gate2

## Begin Gate3
last_output = max(g[2] for g in gs if g[2].startswith('z'))
for g in gs:
    gt, (g1, g2), go = g
    if not go.startswith('z'):
        continue
    if go == last_output:
        if gt != 'OR':
            cands.add(go)
        continue
    if gt != 'XOR':
        cands.add(go)
        continue

for g in gs:
    gt, (g1, g2), go = g
    if gt != 'XOR':
        continue
    if not g1.startswith('x') and not g2.startswith('x'):
        continue
    if go in cands:
        continue
    if go == 'z00':
        continue
    # officially have a fever from this...
    if len([igo for igt, (ig1, ig2), igo in gs if igt == 'XOR' and (not ig1.startswith('x') and not ig2.startswith('x')) and (ig1 == go or ig2 == go)]):
        continue
    cands.add(go)

    guess = 'z' + g1[1:]

    mgs = [(igt, (ig1, ig2), igo) for igt, (ig1, ig2), igo in gs if igt == 'XOR' and (not ig1.startswith('x') and not ig2.startswith('x')) and igo == guess]
    mg = mgs[0]
    mgc = [mg[1][0], mg[1][1]]

    mgs2 = [(igt, (ig1, ig2), igo) for igt, (ig1, ig2), igo in gs if igt == 'OR' and igo in mgc]
    mg2 = mgs2[0]

    for m in mgc:
        if m == mg2[2]:
            continue
        cands.add(m)
## End Gate3


# Pt.2
print(','.join(sorted(cands)))
