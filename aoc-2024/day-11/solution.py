#!/usr/bin/env python3
import fileinput
import functools
from util import L

@functools.cache
def sim(i, it):
    if it == 0: # base case
        return 1

    # rule 1: 0 -> 1
    if i == 0:
        return sim(1, it - 1)

    # rule 2: split evens by str repr
    s = str(i)
    n = len(s)
    if n % 2 == 0:
        mid = n // 2
        return sim(int(s[:mid]), it - 1) + sim(int(s[mid:]), it - 1)

    # rule 3: else, mult 2024
    return sim(i * 2024, it - 1)

def run(ss, it):
    return [sim(s, it) for s in ss]

# stones = [6563348, 67, 395, 0, 6, 4425, 89567, 739318]
stones = list(map(int, L(fileinput.input())[0].split()))
print(sum(run(stones, 25)))
print(sum(run(stones, 75)))
