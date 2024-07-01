//! Draw implementation of basic drawing algorithms
//!
//! Provides functions to draw lines, squares, rectangles, and triangles using Bresenham's line
//! Clip lines using Cohen-Sutherland algorithm
const std = @import("std");
const ColorBuffer = @import("color_buffer.zig").ColorBuffer;
const Color = @import("color.zig");

pub const Draw = struct {
    const CohenRegion = enum(u8) { Inside = 0, Left = 1, Right = 2, Bottom = 4, Top = 8 };
    const LineAlgorithm = enum { Bresenham, DDA };

    // computes the Cohen-Sutherland outcode for a point given the clipping boundaries
    fn computeOutCode(x: f32, y: f32, x_min: f32, y_min: f32, x_max: f32, y_max: f32) u8 {
        var code = @intFromEnum(CohenRegion.Inside);
        if (x < x_min) code |= @intFromEnum(CohenRegion.Left);
        if (x > x_max) code |= @intFromEnum(CohenRegion.Right);
        if (y < y_min) code |= @intFromEnum(CohenRegion.Bottom);
        if (y > y_max) code |= @intFromEnum(CohenRegion.Top);
        return code;
    }

    // intersection of a line with the clipping boundaries.
    fn findIntersection(x0: f32, y0: f32, x1: f32, y1: f32, outcodeOut: u8, x_min: f32, y_min: f32, x_max: f32, y_max: f32) struct { x: f32, y: f32 } {
        var x: f32 = 0;
        var y: f32 = 0;
        if ((outcodeOut & @intFromEnum(CohenRegion.Top)) != 0) {
            x = x0 + (x1 - x0) * (y_max - y0) / (y1 - y0);
            y = y_max;
        } else if ((outcodeOut & @intFromEnum(CohenRegion.Bottom)) != 0) {
            x = x0 + (x1 - x0) * (y_min - y0) / (y1 - y0);
            y = y_min;
        } else if ((outcodeOut & @intFromEnum(CohenRegion.Right)) != 0) {
            y = y0 + (y1 - y0) * (x_max - x0) / (x1 - x0);
            x = x_max;
        } else if ((outcodeOut & @intFromEnum(CohenRegion.Left)) != 0) {
            y = y0 + (y1 - y0) * (x_min - x0) / (x1 - x0);
            x = x_min;
        }
        return .{ .x = x, .y = y };
    }

    // Cohen-Sutherland clipping algorithm: see https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm
    pub fn cohenSutherlandClip(x0: f32, y0: f32, x1: f32, y1: f32, width: f32, height: f32) struct { x0: f32, y0: f32, x1: f32, y1: f32, accept: bool } {
        var _x0 = x0;
        var _y0 = y0;
        var _x1 = x1;
        var _y1 = y1;
        var outcode0 = computeOutCode(x0, y0, 0, 0, width, height);
        var outcode1 = computeOutCode(x1, y1, 0, 0, width, height);

        var accept = false;
        while (true) {
            if ((outcode0 | outcode1) == @intFromEnum(CohenRegion.Inside)) {
                accept = true;
                break;
            } else if ((outcode0 & outcode1) != 0) {
                break;
            } else {
                const outcodeOut: u8 = if (outcode0 != @intFromEnum(CohenRegion.Inside)) outcode0 else outcode1;
                const intersection = findIntersection(x0, y0, x1, y1, outcodeOut, 0, 0, width, height);

                if (outcodeOut == outcode0) {
                    _x0 = intersection.x;
                    _y0 = intersection.y;
                    outcode0 = computeOutCode(x0, y0, 0, 0, width, height);
                } else {
                    _x1 = intersection.x;
                    _y1 = intersection.y;
                    outcode1 = computeOutCode(x1, y1, 0, 0, width, height);
                }
            }
        }
        return .{ .x0 = x0, .y0 = y0, .x1 = x1, .y1 = y1, .accept = accept };
    }

    // Bresenham's line drawing algorithm see https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
    pub fn bresenhamLine(cb: *ColorBuffer, x1: u32, y1: u32, x2: u32, y2: u32, color: u32) void {
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

    // Digital Differential Analyzer (DDA) line drawing algorithm see https://en.wikipedia.org/wiki/Digital_differential_analyzer_(graphics_algorithm)
    pub fn ddaLine(cb: *ColorBuffer, x1: u32, y1: u32, x2: u32, y2: u32, color: u32) void {
        _ = cb;
        _ = x1;
        _ = y1;
        _ = x2;
        _ = y2;
        _ = color;

        // TODO: Implement DDA line drawing algorithm, just for the sake of completeness
    }

    // Generic function to draw a line using a selected algorithm
    pub fn drawLine(cb: *ColorBuffer, x1: u32, y1: u32, x2: u32, y2: u32, color: u32, algorithm: LineAlgorithm) void {
        switch (algorithm) {
            .Bresenham => bresenhamLine(cb, x1, y1, x2, y2, color),
            .DDA => ddaLine(cb, x1, y1, x2, y2, color),
        }
    }

    pub fn line(cb: *ColorBuffer, x1: u32, y1: u32, x2: u32, y2: u32, color: u32) void {
        drawLine(cb, x1, y1, x2, y2, color, LineAlgorithm.Bresenham);
    }

    pub fn drawSquare(cb: *ColorBuffer, x: u32, y: u32, size: u32, color: u32) void {
        drawLine(cb, x, y, x + size, y, color, LineAlgorithm.Bresenham);
        drawLine(cb, x, y, x, y + size, color, LineAlgorithm.Bresenham);
        drawLine(cb, x + size, y, x + size, y + size, color, LineAlgorithm.Bresenham);
        drawLine(cb, x, y + size, x + size, y + size, color, LineAlgorithm.Bresenham);
    }

    pub fn drawRectangle(cb: *ColorBuffer, x: u32, y: u32, width: u32, height: u32, color: u32) void {
        drawLine(cb, x, y, x + width, y, color, LineAlgorithm.Bresenham);
        drawLine(cb, x, y, x, y + height, color, LineAlgorithm.Bresenham);
        drawLine(cb, x + width, y, x + width, y + height, color, LineAlgorithm.Bresenham);
        drawLine(cb, x, y + height, x + width, y + height, color, LineAlgorithm.Bresenham);
    }

    pub fn drawTriangle(cb: *ColorBuffer, x1: u32, y1: u32, x2: u32, y2: u32, x3: u32, y3: u32, color: u32) void {
        drawLine(cb, x1, y1, x2, y2, color, LineAlgorithm.Bresenham);
        drawLine(cb, x2, y2, x3, y3, color, LineAlgorithm.Bresenham);
        drawLine(cb, x3, y3, x1, y1, color, LineAlgorithm.Bresenham);
    }
};
