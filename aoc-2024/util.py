import operator
from collections import defaultdict


# C is for n-dimensional Coords; no checking for "n"
class C:
    @staticmethod
    def add(*cs):
        return tuple(sum(es) for es in zip(*cs))

    @staticmethod
    def mul(c, m):
        return tuple(e * m for e in c)

    @staticmethod
    def rev(c):
        return tuple(reversed(c))

    @staticmethod
    def rot(c):
        l = list(c)
        return tuple(l[1:] + [l[0]])

    @staticmethod
    def dim(c):
        return len(c)

    @staticmethod
    def sub(a, b):
        return tuple(x - y for x, y in zip(a, b))


# G is for Grid
class G:
    @staticmethod
    def new_dimensions(w=0, h=0, dims=None, default_value=None):
        if dims:
            w, h = dims

        g = G(default_value)

        # HACK: sparse grid -- write to min, max point
        g[0, 0] = default_value
        g[w-1, h-1] = default_value

        return g

    @staticmethod
    def new_from_lines(lines, default_value=None, transform=None):
        g = G(default_value)
        for y, line in enumerate(lines):
            for x, c in enumerate(line.strip()):
                if transform:
                    c = transform(c)
                g[x, y] = c
        return g

    def __init__(self, default_value):
        self.cells = {}
        self.default_value = default_value

        self.dirty = True
        self.width = None
        self.height = None

    def __contains__(self, key):
        x, y = key
        return 0 <= x <= self.x_max() and 0 <= y <= self.y_max()

    def __iter__(self):
        for y in self.y_range():
            for x in self.x_range():
                yield x, y

    def __getitem__(self, key):
        return self.cells.get(key, self.default_value)

    def __setitem__(self, key, value):
        self.dirty = True
        self.cells[key] = value

    def __str__(self):
        return "\n".join(["".join([str(self[x, y]) for x in self.x_range()]) for y in self.y_range()])

    def diags(self, x=0, y=0, xy=None, scale=1, prune=False):
        if xy:
            x, y = xy

        rels = [(1, 1), (-1, 1), (1, -1), (-1, -1)]
        abss = [(x + dx * scale, y + dy * scale) for dx, dy in rels]
        if not prune:
            return abss
        return [pt for pt in abss if pt in self]

    def dirs(self, x=0, y=0, xy=None, dist=1, prune=False):
        if xy:
            x, y = xy

        #       right,  down,   left,    up
        #       east,   south,  west,    north
        rels = [(1, 0), (0, 1), (-1, 0), (0, -1)]
        abss = [(x + dx * dist, y + dy * dist) for dx, dy in rels]
        if not prune:
            return abss
        return [pt for pt in abss if pt in self]

    def neighbors(self, x=0, y=0, xy=None, dist=1, prune=False):
        return self.dirs(x, y, xy, dist, prune) + self.diags(x, y, xy, dist, prune)

    def content_map(self):
        cm = defaultdict(list)
        for x, y in self:
            if self[x, y] != self.default_value:
                cm[self[x, y]].append((x, y))
        return cm

    def copy(self):
        g = G(self.default_value)
        g.cells = self.cells.copy()
        return g

    def dims(self):
        return self.x_max() + 1, self.y_max() + 1

    def find(self, value):
        return next(pt for pt in self if self[pt] == value)

    def find_all(self, value):
        return [pt for pt in self if self[pt] == value]

    def find_opt(self, value):
        ms = self.find_all(value)
        if ms:
            return ms[0]
        return None

    def get_all(self, values):
        return [self[v] for v in values]

    def mark(self, points, value):
        for pt in points:
            self[pt] = value
        return self

    def mark_each(self, pvs):
        for pt, value in pvs:
            self[pt] = value
        return self

    def update(self):
        if not self.dirty:
            return

        self.dirty = False
        self.width = max(x for x, _ in self.cells)
        self.height = max(y for _, y in self.cells)

    def x_max(self):
        self.update()
        return self.width

    def x_range(self):
        return range(self.x_max() + 1)

    def xy_max(self):
        return self.x_max(), self.y_max()

    def xy_min(self):
        return 0, 0

    def y_max(self):
        self.update()
        return self.height

    def y_range(self):
        return range(self.y_max() + 1)


# L is for Lines
def L(lines):
    return [line.strip() for line in lines]


# Lint is for Lines mapped to integers
def Lint(lines):
    return Lmap(lines, int)


# Lmap is for Lines mapped to a function
def Lmap(lines, fn):
    return [fn(line.strip()) for line in lines]


# Pwhen is for Partitioning a list into sublists When a condition is met
# By default, splits on empty line
def Pwhen(ls, cond=operator.not_):
    rs = [[]]
    for l in ls:
        if cond(l):
            rs.append([])
        else:
            rs[-1].append(l)
    return rs
