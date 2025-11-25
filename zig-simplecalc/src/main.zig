const std = @import("std");
const zig_simplecalc = @import("zig_simplecalc");

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var stderr_buffer: [1024]u8 = undefined;
    var stderr_writer = std.fs.File.stderr().writer(&stderr_buffer);
    const stderr = &stderr_writer.interface;

    var gpa : std.heap.GeneralPurposeAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len <= 1) {
        try stderr.print("Usage: {s} <number> [<number> ...]\n", .{args[0]});
        try stderr.print("Sums numbers (int or float).\n", .{});
        try stderr.flush();
        std.process.exit(1);
    }

    const result = zig_simplecalc.addTogether(args[1..]) catch |err| {
        try stderr.print("Error: {s}\n", .{@errorName(err)});
        try stderr.flush();
        std.process.exit(1);
    };

    switch (result) {
        .Int => |v| try stdout.print("{d}\n", .{v}),
        .Float => |v| try stdout.print("{d}\n", .{v}),
    }
    try stdout.flush();
}
