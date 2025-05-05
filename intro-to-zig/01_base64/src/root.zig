const std = @import("std");
const math = std.math;
const testing = std.testing;

const Base64 = struct {
    _t: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const nums = "0123456789";
        const syms = "+/";
        return Base64{
            ._t = upper ++ lower ++ nums ++ syms,
        };
    }

    fn _at(self: Base64, idx: u8) u8 {
        return self._t[idx];
    }

    test "simple _at function" {
        const b = Base64.init();
        try testing.expect(b._at(2) == 'C');
    }

    fn _idx(self: Base64, char: u8) u8 {
        if (char == '=') {
            return 64;
        }

        for (self._t, 0..) |c, idx| {
            if (c == char) {
                return @intCast(idx);
            }
        }

        return 0;
    }

    fn enclen(in: []const u8) !usize {
        if (in.len < 3) {
            return 4;
        }

        return try math.divCeil(usize, in.len, 3) * 4;
    }

    pub fn encode(self: Base64, allocator: std.mem.Allocator, in: []const u8) ![]u8 {
        if (in.len == 0) {
            return "";
        }

        const outlen = try enclen(in);
        var out = try allocator.alloc(u8, outlen);
        var buf = [_]u8{ 0, 0, 0 };

        var count: u8 = 0;
        var outidx: u64 = 0;

        for (in, 0..) |_, inidx| {
            buf[count] = in[inidx];
            count += 1;
            if (count == 3) {
                out[outidx] = self._at(buf[0] >> 2);
                out[outidx + 1] = self._at(((buf[0] & 0x03) << 4) + (buf[1] >> 4));
                out[outidx + 2] = self._at(((buf[1] & 0x0f) << 2) + (buf[2] >> 6));
                out[outidx + 3] = self._at(buf[2] & 0x3f);

                count = 0;
                outidx += 4;
            }
        }

        if (count == 1) {
            out[outidx] = self._at(buf[0] >> 2);
            out[outidx + 1] = self._at((buf[0] & 0x03) << 4);
            out[outidx + 2] = '=';
            out[outidx + 3] = '=';
        }

        if (count == 2) {
            out[outidx] = self._at(buf[0] >> 2);
            out[outidx + 1] = self._at(((buf[0] & 0x03) << 4) + (buf[1] >> 4));
            out[outidx + 2] = self._at((buf[1] & 0x0f) << 2);
            out[outidx + 3] = '=';

            outidx += 4;
        }

        return out;
    }

    test "encode of string with no equals" {
        const in = "something";
        const expect = "c29tZXRoaW5n";

        const b = Base64.init();

        const in_result = try b.encode(testing.allocator, in);
        defer testing.allocator.free(in_result);

        try testing.expectEqualDeep(in_result, expect);
    }

    test "encode test with one equals" {
        const in = "ernie";
        const expect = "ZXJuaWU=";

        const b = Base64.init();

        const in_result = try b.encode(testing.allocator, in);
        defer testing.allocator.free(in_result);

        try testing.expectEqualDeep(in_result, expect);
    }

    test "encode test with two equals" {
        const in = "muppets";
        const expect = "bXVwcGV0cw==";

        const b = Base64.init();

        const in_result = try b.encode(testing.allocator, in);
        defer testing.allocator.free(in_result);

        try testing.expectEqualDeep(in_result, expect);
    }

    fn declen(in: []const u8) !usize {
        if (in.len < 4) {
            return 3;
        }

        const l: usize = try math.divFloor(usize, in.len, 4);

        if (in[in.len - 2] == '=') {
            return l * 3 - 2;
        }
        if (in[in.len - 1] == '=') {
            return l * 3 - 1;
        }
        return l * 3;
    }

    pub fn decode(self: Base64, allocator: std.mem.Allocator, in: []const u8) ![]u8 {
        if (in.len == 0) {
            return "";
        }

        const l = try declen(in);
        var out = try allocator.alloc(u8, l);
        var count: u8 = 0;
        var outidx: u64 = 0;
        var buf = [_]u8{ 0, 0, 0, 0 };

        for (0..in.len) |inidx| {
            buf[count] = self._idx(in[inidx]);

            count += 1;
            if (count == 4) {
                out[outidx] = (buf[0] << 2) + (buf[1] >> 4);
                if (buf[2] != 64) {
                    out[outidx + 1] = (buf[1] << 4) + (buf[2] >> 2);
                }
                if (buf[3] != 64) {
                    out[outidx + 2] = (buf[2] << 6) + buf[3];
                }
                outidx += 3;
                count = 0;
            }
        }

        return out;
    }
};

test "decode test without equals" {
    const in = "c29tZXRoaW5n";
    const expect = "something";

    const b = Base64.init();

    const in_result = try b.decode(testing.allocator, in);
    defer testing.allocator.free(in_result);

    try testing.expectEqualDeep(expect, in_result);
}

test "decode test with one equals" {
    const in = "ZXJuaWU=";
    const expect = "ernie";

    const b = Base64.init();

    const in_result = try b.decode(testing.allocator, in);
    defer testing.allocator.free(in_result);

    try testing.expectEqualDeep(expect, in_result);
}

test "decode test with two equals" {
    const in = "bXVwcGV0cw==";
    const expect = "muppets";

    const b = Base64.init();

    const in_result = try b.decode(testing.allocator, in);
    defer testing.allocator.free(in_result);

    try testing.expectEqualDeep(expect, in_result);
}
