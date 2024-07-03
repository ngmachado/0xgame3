const std = @import("std");
const utils = @import("utils.zig");

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub fn fromBytes(r: u8, g: u8, b: u8, a: u8) Color {
        return Color{ .r = r, .g = g, .b = b, .a = a };
    }

    pub fn fromU32(color: u32) Color {
        return Color{
            .r = @as(u8, color >> 16),
            .g = @as(u8, color >> 8),
            .b = @as(u8, color),
            .a = @as(u8, color >> 24),
        };
    }

    // format: RGB, #RGB, RGBA or #RGBA
    pub fn parse(comptime str: []const u8) !Color {
        switch (str.len) {
            3 => {
                const r = try std.fmt.parseInt(u8, str[0..1], 16);
                const g = try std.fmt.parseInt(u8, str[1..2], 16);
                const b = try std.fmt.parseInt(u8, str[2..3], 16);

                return Color{ .r = r, .g = g, .b = b, .a = 25 };
            },
            4 => {
                if (str[0] == '#') {
                    return parse(str[1..]);
                }

                const r = try std.fmt.parseInt(u8, str[0..1], 16);
                const g = try std.fmt.parseInt(u8, str[1..2], 16);
                const b = try std.fmt.parseInt(u8, str[2..3], 16);
                const a = try std.fmt.parseInt(u8, str[3..4], 16);

                return Color{ .r = r, .g = g, .b = b, .a = a };
            },
            5 => return parse(str[1..]),
            else => return error.UnknownFormat,
        }
    }

    pub fn getColorHex(self: Color) u32 {
        return @as(u32, self.r) | (@as(u32, self.g) << 8) | (@as(u32, self.b) << 16) | (@as(u32, self.a) << 24);
    }

    pub fn getARGB(self: Color) u32 {
        return @as(u32, self.a) | (@as(u32, self.r) << 8) | (@as(u32, self.g) << 16) | (@as(u32, self.b) << 24);
    }

    pub const Pallet = enum(u32) {
        Red = Color.fromBytes(255, 0, 0, 255).getARGB(),
        Green = Color.fromBytes(0, 255, 0, 255).getARGB(),
        Blue = Color.fromBytes(0, 0, 255, 255).getARGB(),
        White = Color.fromBytes(255, 255, 255, 255).getARGB(),
        Black = Color.fromBytes(0, 0, 0, 255).getARGB(),
        Yellow = Color.fromBytes(255, 255, 0, 255).getARGB(),
        Cyan = Color.fromBytes(0, 255, 255, 255).getARGB(),
        Magenta = Color.fromBytes(255, 0, 255, 255).getARGB(),
        Transparent = Color.fromBytes(0, 0, 0, 0).getARGB(),
        LightGray = Color.fromBytes(211, 211, 211, 255).getARGB(),
        Gray = Color.fromBytes(128, 128, 128, 255).getARGB(),
    };
};
