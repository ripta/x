#!/usr/bin/env python3

import fileinput
from util import L, G
import networkx

def think(g, save, max_cheats):
    g = g.copy()

    sc = g.find('S')
    g[sc] = '.'

    ec = g.find('E')
    g[ec] = '.'

    nw = mknet(g)
    dw = networkx.shortest_path_length(nw, sc, ec)

    csds = networkx.single_source_dijkstra_path_length(nw, sc)
    ceds = networkx.single_source_dijkstra_path_length(nw, ec)

    dmax = dw - save

    np = mknet(g, passthru=True)

    saves = []
    cnt = 0
    for cc in g:
        if g[cc] != '.':
            continue
        if cc not in csds:
            continue

        ends = networkx.single_source_dijkstra_path_length(np, cc, cutoff=max_cheats)
        for ec, ed in ends.items():
            if g[ec] != '.':
                continue

            if ec not in ceds:
                continue
            if ceds[ec] > dmax:
                continue

            ds = dw - csds[cc] - ceds[ec] - ed
            if ds >= save:
                saves.append(ds)

    return saves


def mknet(g, passthru=False):
    n = networkx.Graph()
    for cc in g:
        if not passthru and g[cc] == '#':
            continue
        for nc in g.dirs(xy=cc, prune=True):
            if passthru or g[nc] == '.':
                n.add_edge(cc, nc) # assume all weights=1 ?
                # yes, bc every wall is taken into acct
    return n


g = G.new_from_lines(fileinput.input())

save = 100
if g.y_max() < 100:
    save = 2

print(f"save={save}")
print(len(think(g, save, 2)))
print(len(think(g, save, 20)))
