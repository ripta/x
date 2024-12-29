#!/usr/bin/env python3

import sys
import fileinput
from util import G

# g = G.new_from_lines(fileinput.input(), )
g = G.new_from_lines(fileinput.input(), 'X')

def next_dir(dirs):
    dd = dirs.pop(0)
    dirs.append(dd)
    return dd

def pt1(g):
    cx, cy = g.find('^')
    dx, dy = 0, -1 # start upwards
    dirs = g.dirs()

    seen = set()
    while True:
        nx, ny = cx + dx, cy + dy
        if g[nx, ny] == '#':
            dx, dy = next_dir(dirs)
            # print(f'rotating to {dx}, {dy}')
        elif g[nx, ny] in ['.', '^']:
            # print(f'moving to {nx, ny}')
            seen.add((nx, ny))
            cx, cy = nx, ny
        elif g[nx, ny] == 'X':
            # seen.add((nx, ny))
            break
    return seen

def pt2(g, seen):
    qx, qy = g.find('^')

    ans = 0
    for sx, sy in seen:
        cx, cy = qx, qy
        dx, dy = 0, -1  # start upwards
        dirs = g.dirs()

        # print(f'checking {sx}, {sy}')
        g[sx, sy] = '#'
        subseen = set()
        while True:
            nx, ny = cx + dx, cy + dy
            # print(f'cx, cy = {cx}, {cy}')
            if g[nx, ny] == '#':
                dx, dy = next_dir(dirs)
                # print(f'rotating to {dx}, {dy}')
            elif g[nx, ny] in ['.', '^']:
                key = (nx, ny, dx, dy)
                if key in subseen:
                    ans += 1
                    # print(f'loop #{ans} detected at {key}')
                    break
                subseen.add(key)
                cx, cy = nx, ny
            elif g[nx, ny] == 'X':
                break
        # if len(subseen) > 0:
        #     print(subseen)
        g[sx, sy] = '.'
    return ans


seen = pt1(g)
print(len(seen))
# print(seen)
print(pt2(g, seen))
