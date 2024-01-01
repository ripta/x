#!/usr/bin/env python3

import math
import networkx
import sys
from itertools import combinations

edgesets = []
nodes = []
for line in sys.stdin.read().strip().split("\n"):
    name, conns = line.split(": ")
    edgesets.append((name, conns.split(" ")))
    nodes.append(name)

g = networkx.Graph()
for source, targets in edgesets:
    for target in targets:
        g.add_edge(source, target)

cuts = networkx.minimum_edge_cut(g)
g.remove_edges_from(cuts)
print("Cuts made:", cuts)

rg = list(networkx.connected_components(g))
print("Subgraph sizes:", [len(i) for i in rg])
print("Pt1 answer:", math.prod(len(i) for i in rg))
print("(Free Pt2)")
