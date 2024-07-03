const std = @import("std");
const ColorBuffer = @import("color_buffer.zig").ColorBuffer;
const Color = @import("color.zig");

const CohenRegion = enum(u8) { Inside = 0, Left = 1, Right = 2, Bottom = 4, Top = 8 };

pub fn CohenComputeOutCode(x: f32, y: f32, xmin: f32, ymin: f32, xmax: f32, ymax: f32) u8 {
    var code = @intFromEnum(CohenRegion.Inside);

    if (x < xmin) {
        code |= @intFromEnum(CohenRegion.Left);
    } else if (x > xmax) {
        code |= @intFromEnum(CohenRegion.Right);
    }

    if (y < ymin) {
        code |= @intFromEnum(CohenRegion.Bottom);
    } else if (y > ymax) {
        code |= @intFromEnum(CohenRegion.Top);
    }

    return code;
}

// Cohen-Sutherland line clipping algorithm see more at https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm
pub fn CohenSutherlandClip(x0: f32, y0: f32, x1: f32, y1: f32, width: f32, height: f32) struct { x0: f32, y0: f32, x1: f32, y1: f32, accept: bool } {
    const xmin = 0;
    const ymin = 0;
    const xmax = width;
    const ymax = height;
    var outcode0 = CohenComputeOutCode(x0, y0, xmin, ymin, xmax, ymax);
    var outcode1 = CohenComputeOutCode(x1, y1, xmin, ymin, xmax, ymax);
    var accept = false;
    var _x0 = x0;
    var _y0 = y0;
    var _x1 = x1;
    var _y1 = y1;
    while (true) {
        if (outcode0 == @intFromEnum(CohenRegion.Inside) and outcode1 == @intFromEnum(CohenRegion.Inside)) {
            accept = true;
            break;
        } else if (outcode0 & outcode1 != @intFromEnum(CohenRegion.Inside)) {
            accept = false;
            break;
        } else {
            var x: f32 = 0;
            var y: f32 = 0;

            const outcodeOut = if (outcode0 != @intFromEnum(CohenRegion.Inside)) outcode0 else outcode1;
            if (outcodeOut & @intFromEnum(CohenRegion.Top) != 0) {
                x = _x0 + (_x1 - _x0) * (ymax - _y0) / (_y1 - _y0);
                y = ymax;
            } else if (outcodeOut & @intFromEnum(CohenRegion.Bottom) != 0) {
                x = _x0 + (_x1 - _x0) * (ymin - _y0) / (_y1 - _y0);
                y = ymin;
            } else if (outcodeOut & @intFromEnum(CohenRegion.Right) != 0) {
                y = _y0 + (_y1 - _y0) * (xmax - _x0) / (_x1 - _x0);
                x = xmax;
            } else if (outcodeOut & @intFromEnum(CohenRegion.Left) != 0) {
                y = _y0 + (_y1 - _y0) * (xmin - _x0) / (_x1 - _x0);
                x = xmin;
            }

            if (outcodeOut == outcode0) {
                _x0 = x;
                _y0 = y;
                outcode0 = CohenComputeOutCode(_x0, _y0, xmin, ymin, xmax, ymax);
            } else {
                _x1 = x;
                _y1 = y;
                outcode1 = CohenComputeOutCode(_x1, _y1, xmin, ymin, xmax, ymax);
            }
        }
    }
    return .{ .x0 = _x0, .y0 = _y0, .x1 = _x1, .y1 = _y1, .accept = accept };
}

const LineAlgorithm = enum {
    Bresenham,
    DDA,
};

// Bresenham's line algorithm see more at https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
pub fn bresenham_line(cb: *ColorBuffer, x1: u32, y1: u32, x2: u32, y2: u32, color: u32) void {
    // avoid overflows
    const _x1: f32 = @floatFromInt(x1);
    const _y1: f32 = @floatFromInt(y1);
    const _x2: f32 = @floatFromInt(x2);
    const _y2: f32 = @floatFromInt(y2);

    const dx: f32 = @abs(_x2 - _x1);
    const dy: f32 = @abs(_y2 - _y1);

    const sx: i32 = if (x1 < x2) 1 else -1;
    const sy: i32 = if (y1 < y2) 1 else -1;

    var err = dx - dy;
    var x: i32 = @intCast(x1);
    var y: i32 = @intCast(y1);

    while (true) {
        cb.drawPixel(@intCast(x), @intCast(y), color);
        if (x == x2 and y == y2) {
            break;
        }
        const e2 = 2 * err;
        if (e2 > -dy) {
            err -= dy;
            x += sx;
        }
        if (e2 < dx) {
            err += dx;
            y += sy;
        }
    }
}

pub fn dda_line(x1: u32, y1: u32, x2: u32, y2: u32, color: u32) void {
    _ = x1;
    _ = y1;
    _ = x2;
    _ = y2;
    _ = color;

    // draw line using DDA line algorithm
    // DDA line algorithm is the following:
    // 1. Calculate the difference between the start and end points
    // 2. Calculate the slope of the line
    // 3. If the slope is less than 1, iterate over the x axis
    // 4. If the slope is greater than 1, iterate over the y axis
    // 5. Draw the pixel at the current x and y position
    // 6. Repeat until the end point is reached
}

pub fn draw_line(cb: *ColorBuffer, x1: u32, y1: u32, x2: u32, y2: u32, color: u32, line_algo: LineAlgorithm) void {
    switch (line_algo) {
        .Bresenham => {
            bresenham_line(cb, x1, y1, x2, y2, color);
        },
        .DDA => {
            dda_line(x1, y1, x2, y2, color);
        },
    }
}

pub fn line(cb: *ColorBuffer, x1: u32, y1: u32, x2: u32, y2: u32, color: u32) void {
    draw_line(cb, x1, y1, x2, y2, color, LineAlgorithm.Bresenham);
}

pub fn square(x: f32, y: f32, size: f32, color: u32) void {
    // draw a square with the specified size and color
    line(x, y, x + size, y, color);
    line(x, y, x, y + size, color);
    line(x + size, y, x + size, y + size, color);
    line(x, y + size, x + size, y + size, color);
}

pub fn triangle(x1: u32, y1: u32, x2: u32, y2: u32, x3: u32, y3: u32, color: u32) void {
    // draw a triangle with the specified vertices and color
    line(x1, y1, x2, y2, color);
    line(x2, y2, x3, y3, color);
    line(x3, y3, x1, y1, color);
}
