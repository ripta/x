#!/usr/bin/env python3

import fileinput
from util import L, G, Pwhen, C

lines = L(fileinput.input())
lgrid, lmoves = Pwhen(lines, lambda x: len(x) == 0)
moves = ''.join(lmoves)

# pt.2 wide grid
wgrid = []
for line in lgrid:
    s = ""
    for c in line:
        if c == "@":
            s += "@."
        elif c == "O":
            s += "[]"
        elif c == "#":
            s += "##"
        elif c == ".":
            s += ".."
    wgrid.append(s)


g = G.new_from_lines(lgrid)
robot = g.find("@")
g[robot] = '.'
# print(g.copy().mark([robot], '@'))
# print()

g2 = G.new_from_lines(wgrid)
robot2 = g2.find("@")
g2[robot2] = '.'
# print(g2.copy().mark([robot2], '@'))

move_map = {
    "^": (0, -1),
    "v": (0, 1),
    "<": (-1, 0),
    ">": (1, 0),
}

def is_horiz(mc): # pt.2 is twice as wide, but not twice as tall
    return mc[0] != 0 and mc[1] == 0

def solve(g, moves, robot, wide=False):
    g = g.copy()
    for mg in moves:
        # print(f"Move {mg}")
        dc = move_map[mg]

        path = []
        free = 0

        if wide and not is_horiz(dc):
            nc = robot
            q = [robot]
            while True:
                if all([g[C.add(cc, dc)] == '.' for cc in q]):
                    free += 1
                    break
                if any([g[C.add(cc, dc)] == '#' for cc in q]):
                    break

                dead = set()
                for cc in q:
                    tc = C.add(cc, dc)
                    if g[tc] == '[':
                        dead.add(cc)
                        dead.add(C.add(cc, (1, 0)))
                    elif g[tc] == ']':
                        dead.add(cc)
                        dead.add(C.add(cc, (-1, 0)))

                q = []
                for cc in dead:
                    q.append(cc)
                    path.append((cc, g[cc]))

                nc = C.add(nc, dc)

        else:
            nc = C.add(robot, dc)
            while True:
                # print(nc)
                if g[nc] == '.':
                    free += 1
                    break
                elif g[nc] in ['O', '[', ']']:
                    path.append((nc, g[nc]))
                else:
                    break

                nc = C.add(nc, dc)

        if free > 0:
            g.mark([cc for cc, _ in path], '.') # clear path
            g.mark_each([(C.add(cc, dc), v) for cc, v in path]) # process moves
            robot = C.add(robot, dc)

            # print(g.copy().mark([robot], '@'))
            # print()

    return g

def score(g):
    ans = 0
    for cc in g:
        if g[cc] in ['O', '[']:
            ans += cc[1] * 100 + cc[0]
    return ans

pt1 = solve(g, moves, robot)
print(score(pt1))

# NOTE(ripta): 2025-01-02 I broke pt2 trying to clean it up and uh; it never terminates oops.
# pt2 = solve(g2, moves, robot2, True)
# print(score(pt2))
