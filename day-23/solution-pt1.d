module solution;

import std.typecons;
alias Coord = Tuple!(ulong, "row", ulong, "col");
alias Cell  = Tuple!(Coord, "coord", char, "dir");

immutable enum Rune: char {
	Right = '>',
	Left  = '<',
	Up    = '^',
	Down  = 'v',
	Path  = '.',
	Wall  = '#',
}

Rune opp(Rune d) {
	//assert(hasOpp(cast(d)));
	switch(d) {
		case Rune.Right: return Rune.Left;
		case Rune.Left:  return Rune.Right;
		case Rune.Up:    return Rune.Down;
		case Rune.Down:  return Rune.Up;
		default:         assert(0); // :(
	}
}

bool hasOpp(char d) {
	switch(d) {
		case Rune.Right, Rune.Left, Rune.Up, Rune.Down:
			return true;
		default:
			return false;
	}
}

immutable Coord[char] heads;
shared static this() {
	heads = [
		Rune.Right: Coord( 0,  1),
		Rune.Left:  Coord( 0, -1),
		Rune.Up:    Coord(-1,  0),
		Rune.Down:  Coord( 1,  0),
	];
}

Cell find(string[] grid, ulong row, char ch) {
	import std.string;
	auto idx = indexOf(grid[row], ch);
	assert(idx > -1);
	return Cell(Coord(row, idx), ch);
}

bool inGrid(string[] grid, Coord c) {
	if (c.row < 0 || c.col < 0) {
		return false;
	}
	if (c.row >= grid.length || c.col >= grid[0].length) {
		return false;
	}
	return true;
}

Cell atGrid(string[] grid, Coord c) {
	return Cell(c, grid[c.row][c.col]);
}

class CQ { // cost queue?
	import std.container;
	import std.range;

	int[][][] costs; // distance
	DList!Cell queue;

	this(ulong rc, ulong cc) {
		// ugh... technically costs[int][int][char] and *really* should be sparse
		// but this works
		costs = new int[][][](rc, cc, Rune.max);
		queue = DList!Cell();
	}

	int cost(Cell cell) {
		return costs[cell.coord.row][cell.coord.col][cell.dir - 1];
	}

	int maxCost(Cell cell) {
		import std.algorithm;
		return costs[cell.coord.row][cell.coord.col][].maxElement;
	}

	bool empty() {
		return queue.empty();
	}

	void en(ulong r, ulong c, char ch, int cost) {
		costs[r][c][ch - 1] = cost;
		queue ~= Cell(Coord(r, c), ch);
	}

	void en(Cell cell, int cost) {
		this.en(cell.coord.row, cell.coord.col, cell.dir, cost);
	}

	Cell pop() {
		auto c = queue.front();
		queue.removeFront();
		return c;
	}
}

void traverse(string[] grid, CQ q) {
	import std.traits;
	while (!q.empty()) {
		auto last = q.pop();
		auto cost = q.cost(last);
		auto cur  = atGrid(grid, last.coord);
		//writeln("at (", last.coord.row, ", ", last.coord.col, ") going ", last.dir);

		foreach (immutable dir; EnumMembers!Rune) {
			// skip non-directional runes; shoulda separated those out eek
			if (!hasOpp(dir)) {
				continue;
			}

			// skip proposals to go the opposite direction we have to go
			if (hasOpp(last.dir) && opp(dir) == last.dir) {
				continue;
			}
			// skip proposals that don't go the required direction
			if (hasOpp(cur.dir) && dir != cur.dir) {
				continue;
			}

			// calculate new coord after move; skip new coords that put out out of bounds
			auto move = heads[dir];
			auto newCoord = Coord(last.coord.row + move.row, last.coord.col + move.col);
			if (!inGrid(grid, newCoord)) {
				continue;
			}

			// skip if new coord is a wall
			auto next = atGrid(grid, newCoord);
			if (next.dir == Rune.Wall) {
				continue;
			}

			// enqueue proposed direction
			q.en(Cell(newCoord, dir), cost + 1);
		}
	}
}

void main() {
	import std.algorithm;
	import std.array;
	import std.container;
	import std.conv;
	import std.stdio;

	//auto grid = stdin.byLine().array(); // need copy orelse array will just have the last item over and over
	string[] grid = stdin.byLineCopy().array();
	ulong rc = grid.length;
	ulong cc = grid[0].length;

	auto q = new CQ(rc, cc);

	// enqueue starting point
	auto start = find(grid, 0, '.');
	q.en(Cell(start.coord, Rune.Down), 0);
	traverse(grid, q);

	// find coordinate of end goal and get cost
	auto end = find(grid, rc - 1, '.');
	writeln("Longest hike: ", q.maxCost(end));
}
