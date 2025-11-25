const std = @import("std");
const testing = std.testing;

pub const AddResult = union(enum) {
    Int: i64,
    Float: f64,
};

pub fn addTogether(args: []const []const u8) !AddResult {
    var sum_int: i64 = 0;
    var sum_float: f64 = 0.0;
    var any_float = false;

    for (args) |arg| {
        const int_parse = std.fmt.parseInt(i64, arg, 10);
        if (int_parse) |val| {
            if (any_float) {
                sum_float += @floatFromInt(val);
            } else {
                sum_int += val;
            }
            continue;
        } else |_| {}

        const float_parse = std.fmt.parseFloat(f64, arg);
        if (float_parse) |val| {
            if (!any_float) {
                sum_float = @floatFromInt(sum_int);
                any_float = true;
            }
            sum_float += val;
            continue;
        } else |_| {}

        return error.InvalidNumber;
    }

    if (any_float) {
        return AddResult{ .Float = sum_float };
    } else {
        return AddResult{ .Int = sum_int };
    }
}

test "addTogether with empty array" {
    const args: []const []const u8 = &.{};
    const result = try addTogether(args);
    try testing.expectEqual(AddResult{ .Int = 0 }, result);
}

test "addTogether with single integer" {
    const args = &[_][]const u8{"42"};
    const result = try addTogether(args);
    try testing.expectEqual(AddResult{ .Int = 42 }, result);
}

test "addTogether with multiple integers" {
    const args = &[_][]const u8{ "1", "2", "3", "4" };
    const result = try addTogether(args);
    try testing.expectEqual(AddResult{ .Int = 10 }, result);
}

test "addTogether with negative integers" {
    const args = &[_][]const u8{ "-5", "10", "-3" };
    const result = try addTogether(args);
    try testing.expectEqual(AddResult{ .Int = 2 }, result);
}

test "addTogether with single float" {
    const args = &[_][]const u8{"3.14"};
    const result = try addTogether(args);
    try testing.expectEqual(AddResult.Float, @as(std.meta.Tag(AddResult), result));
    try testing.expectApproxEqAbs(3.14, result.Float, 0.0001);
}

test "addTogether with multiple floats" {
    const args = &[_][]const u8{ "1.5", "2.5", "3.0" };
    const result = try addTogether(args);
    try testing.expectEqual(AddResult.Float, @as(std.meta.Tag(AddResult), result));
    try testing.expectApproxEqAbs(7.0, result.Float, 0.0001);
}

test "addTogether with mixed int and float (int first)" {
    const args = &[_][]const u8{ "10", "2.5" };
    const result = try addTogether(args);
    try testing.expectEqual(AddResult.Float, @as(std.meta.Tag(AddResult), result));
    try testing.expectApproxEqAbs(12.5, result.Float, 0.0001);
}

test "addTogether with mixed float and int (float first)" {
    const args = &[_][]const u8{ "2.5", "10" };
    const result = try addTogether(args);
    try testing.expectEqual(AddResult.Float, @as(std.meta.Tag(AddResult), result));
    try testing.expectApproxEqAbs(12.5, result.Float, 0.0001);
}

test "addTogether with negative floats" {
    const args = &[_][]const u8{ "-1.5", "3.0", "-0.5" };
    const result = try addTogether(args);
    try testing.expectEqual(AddResult.Float, @as(std.meta.Tag(AddResult), result));
    try testing.expectApproxEqAbs(1.0, result.Float, 0.0001);
}

test "addTogether with zero" {
    const args = &[_][]const u8{"0"};
    const result = try addTogether(args);
    try testing.expectEqual(AddResult{ .Int = 0 }, result);
}

test "addTogether with zero float" {
    const args = &[_][]const u8{"0.0"};
    const result = try addTogether(args);
    try testing.expectEqual(AddResult.Float, @as(std.meta.Tag(AddResult), result));
    try testing.expectApproxEqAbs(0.0, result.Float, 0.0001);
}

test "addTogether with large integers" {
    const args = &[_][]const u8{ "1000000", "2000000", "3000000" };
    const result = try addTogether(args);
    try testing.expectEqual(AddResult{ .Int = 6000000 }, result);
}

test "addTogether with invalid number returns error" {
    const args = &[_][]const u8{"not_a_number"};
    const result = addTogether(args);
    try testing.expectError(error.InvalidNumber, result);
}

test "addTogether with invalid number among valid ones" {
    const args = &[_][]const u8{ "1", "invalid", "3" };
    const result = addTogether(args);
    try testing.expectError(error.InvalidNumber, result);
}

test "addTogether with empty string returns error" {
    const args = &[_][]const u8{""};
    const result = addTogether(args);
    try testing.expectError(error.InvalidNumber, result);
}
