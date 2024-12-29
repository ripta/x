#!/usr/bin/env python3

from util import Lmap
import fileinput
import networkx




lines = Lmap(fileinput.input(), lambda l: l.split('-'))
n = networkx.Graph(lines)

cliques = list(networkx.enumerate_all_cliques(n))

# Pt.1: Find all the sets of three inter-connected computers. How many contain
#       at least one computer with a name that starts with 't'?
print(sum(any(name.startswith('t') for name in c) for c in cliques if len(c) == 3))

# Pt.2: What is the password to get into the LAN party? The LAN party posters
#       say that the password to get into the LAN party is the name of every
#       computer at the LAN party, sorted alphabetically, then joined together
#       with commas.
print(max([','.join(sorted(c)) for c in cliques], key=len))
