const std = @import("std");

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const al = arena.allocator();

    var inbuf = std.io.bufferedReader(stdin);
    var grids = try parseAll(al, inbuf.reader());

    var score1 = calcAllScores(al, grids);
    try stdout.print("Answers: {!}\n", .{score1});
}

const XY = struct { usize, usize };

const Cells = std.AutoHashMap(XY, u8);

const Grid = struct {
    cols: usize,
    rows: usize,
    cells: Cells,
};

const ScoreSet = struct { usize, usize };

fn add(a: ScoreSet, b: ScoreSet, m: usize) ScoreSet {
    return .{ a[0] + b[0] * m, a[1] + b[1] * m };
}

fn calcAllScores(al: std.mem.Allocator, gs: []Grid) ScoreSet {
    var total = ScoreSet{ 0, 0 };
    for (gs) |g| {
        //render(g);
        total = add(total, calcGridScore(al, g), 1);
    }
    return total;
}

fn calcGridScore(al: std.mem.Allocator, g: Grid) ScoreSet {
    var score = ScoreSet{ 0, 0 };
    score = add(score, calcRowsScore(g), 100);

    var r = rotate(al, g) catch unreachable; // assume always rotateable :(
    score = add(score, calcRowsScore(r), 1);

    return score;
}

fn calcRowsScore(g: Grid) ScoreSet {
    var score1: usize = 0;
    var score2: usize = 0;

    // -1 to exclude calculating reflections after last row
    for (0..g.rows - 1) |y| {
        var misses = countMissesOnRow(g, y);
        //stdout.print("  > row={!} misses={!}\n", .{ y, misses }) catch unreachable;
        if (misses == 0) {
            score1 += (y + 1);
        }
        if (misses == 1) {
            score2 += (y + 1);
        }
    }

    return .{ score1, score2 };
}

fn countMissesOnRow(g: Grid, row: usize) usize {
    var misses: usize = 0;

    // how for we can scan - min of distances from current `row` to either top
    // or bottom of grid `g`
    var bound = @min((g.rows - 1) - row, row + 1);
    //stdout.print("row={!} bound={!}\n", .{ row, bound }) catch unreachable;
    for (0..bound) |y| {
        var y1 = row - y;
        var y2 = row + y + 1;
        //stdout.print("  y={!} compare({!}, {!})\n", .{ y, y1, y2 }) catch unreachable;
        for (0..g.cols) |x| {
            var c1 = g.cells.get(.{ x, y1 });
            var c2 = g.cells.get(.{ x, y2 });
            //stdout.print("    equal({?}, {?})\n", .{ c1, c2 }) catch unreachable;
            if (c1 != c2) {
                misses += 1;
            }
        }
    }

    return misses;
}

// parse input file (any reader) into a slice of grids
//
// r is a std.io.Reader
fn parseAll(al: std.mem.Allocator, r: anytype) ![]Grid {
    var grids = std.ArrayList(Grid).init(al);
    while (true) {
        var grid = try parseGrid(al, r);
        if (grid.rows == 0) {
            break;
        }
        try grids.append(grid);
    }

    return grids.toOwnedSlice();
}

const MAX_READ = 4096;

// parse input file (any reader) into a single grid.
fn parseGrid(al: std.mem.Allocator, r: anytype) !Grid {
    var cells = Cells.init(al);

    var cols: usize = 0;
    var rows: usize = 0;
    while (try r.readUntilDelimiterOrEofAlloc(al, '\n', MAX_READ)) |line| {
        if (line.len == 0) {
            break;
        }

        for (line, 0..) |ch, x| {
            try cells.putNoClobber(.{ x, rows }, ch);
            cols = @max(cols, x + 1);
        }

        rows += 1;
    }

    return Grid{
        .cols = cols,
        .rows = rows,
        .cells = cells,
    };
}

fn render(g: Grid) void {
    for (0..g.rows) |y| {
        for (0..g.cols) |x| {
            var ch = g.cells.get(.{ x, y }) orelse '?';
            std.debug.print("{c}", .{ch});
        }
        std.debug.print("\n", .{});
    }
}

const RotateError = error{
    SparseGrid,
};

// clockwise. rets copy.
fn rotate(al: std.mem.Allocator, g: Grid) !Grid {
    var cells = Cells.init(al);
    for (0..g.rows) |y| {
        for (0..g.cols) |x| {
            var ch = g.cells.get(.{ x, y }) orelse return RotateError.SparseGrid;
            // in 5 x 10 grid, e.g., (4, 9) -> (9, 4)
            // so (x, y) -> (-y, x) where (-) = (g.rows - 1) ?
            try cells.putNoClobber(.{ g.rows - 1 - y, x }, ch);
        }
    }

    return Grid{
        .cols = g.rows,
        .rows = g.cols,
        .cells = cells,
    };
}
