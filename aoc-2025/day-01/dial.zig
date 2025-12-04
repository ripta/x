const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <inputfile>\n", .{args[0]});
        std.process.exit(1);
    }

    const file_path = args[1];
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    var start_pos: i32 = 50;
    var part1_cnt: u32 = 0;
    var part2_cnt: u32 = 0;

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0)
            continue;

        const dir = line[0];
        const dist = try std.fmt.parseInt(i32, line[1..], 10);

        var zeros_cnt: u32 = 0;
        if (dir == 'L') {
            if (start_pos == 0) {
                zeros_cnt = @intCast(@divFloor(dist, 100));
            } else if (dist >= start_pos) {
                zeros_cnt = @intCast(@divFloor(dist - start_pos, 100) + 1);
            }
            start_pos = @mod(start_pos - dist, 100);
        } else if (dir == 'R') {
            zeros_cnt = @intCast(@divFloor(start_pos + dist, 100));
            start_pos = @mod(start_pos + dist, 100);
        }

        // std.debug.print("line {s} - start_pos {}", .{ line, start_pos });
        // if (zeros_cnt > 0) {
        //     std.debug.print(" (zeros {})", .{zeros_cnt});
        // }
        // std.debug.print("\n", .{});

        if (start_pos == 0)
            part1_cnt += 1;
        part2_cnt += zeros_cnt;
    }

    std.debug.print("Part 1 - Times ending at 0: {}\n", .{part1_cnt});
    std.debug.print("Part 2 - Total times pointing at 0: {}\n", .{part2_cnt});
}
