//! simple color buffer implementation that can be used to draw pixels on a screen
//!
//! The color buffer is a simple 2D array of u32 values, where each u32 value represents a pixel
//!
//! Configurable options:
//! - draw_grid: whether to draw a grid on the screen
//! - grid_color: the color of the grid
//! - background_color: the color of the background
//! - draw_center_rect: whether to draw a rectangle in the center of the screen
//! - rect_color: the color of the rectangle
//! - rect_width: the width of the rectangle
//! - rect_height: the height of the rectangle
//!
const std = @import("std");
const Color = @import("color.zig").Color;

pub const ColorBuffer = struct {
    allocator: std.mem.Allocator,
    data: []u32,
    width: u32,
    height: u32,
    config: Config,

    pub const GridOption = enum {
        None,
        Simple,
        Detailed,
    };

    pub const Config = struct {
        draw_grid: GridOption,
        grid_color: ?Color,
        background_color: Color,
        draw_center_rect: bool,
        rect_color: Color,
        rect_width: u32,
        rect_height: u32,
    };

    pub fn init(allocator: std.mem.Allocator, width: u32, height: u32, config: Config) !ColorBuffer {
        const data = try allocator.alloc(u32, width * height);
        // set all pixels to black
        for (data) |*elem| {
            elem.* = 0;
        }

        return ColorBuffer{
            .allocator = allocator,
            .width = width,
            .height = height,
            .data = data,
            .config = config,
        };
    }

    pub fn clear(self: *ColorBuffer) void {
        self.clearWithColor(self.config.background_color);
        if (self.config.draw_grid != GridOption.None) {
            self.drawGrid();
        }
        if (self.config.draw_center_rect) {
            self.drawCenterRect();
        }
    }

    pub fn clearWithColor(self: *ColorBuffer, color: Color) void {
        for (self.data) |*elem| {
            elem.* = color.getARGB();
        }
    }

    pub fn update(self: *ColorBuffer) void {
        self.clear();
        if (self.config.draw_grid != GridOption.None) {
            self.drawGrid();
        }
        if (self.config.draw_center_rect) {
            self.drawCenterRect();
        }
    }

    pub fn drawPixel(self: *ColorBuffer, x: u32, y: u32, color: u32) void {
        if (x < self.width and y < self.height) {
            self.data[x + (y * self.width)] = color;
        }
    }

    pub fn getPtr(self: *ColorBuffer) *u32 {
        return &self.data[0];
    }

    pub fn deinit(self: *ColorBuffer) void {
        self.allocator.free(self.data);
    }

    pub fn drawGrid(self: *ColorBuffer) void {
        const lightGrayColor = Color.fromBytes(200, 200, 200, 255).getARGB();
        const gridColor = self.config.grid_color orelse Color.fromBytes(255, 255, 255, 255);
        const gridColorARGB = gridColor.getARGB();
        var i: u32 = 0;
        var j: u32 = 0;

        while (i < self.width) : (i += 1) {
            self.drawPixel(i, 0, lightGrayColor);
            self.drawPixel(i, self.height - 1, lightGrayColor);
        }
        while (j < self.height) : (j += 1) {
            self.drawPixel(0, j, lightGrayColor);
            self.drawPixel(self.width - 1, j, lightGrayColor);
        }
        i = 0;
        j = 0;
        while (i < self.width) : (i += 20) {
            while (j < self.height) : (j += 20) {
                self.drawPixel(i, j, gridColorARGB);
            }
            j = 0;
        }
    }

    pub fn drawCenterRect(self: *ColorBuffer) void {
        const centerX = self.width / 2;
        const centerY = self.height / 2;
        const halfWidth = self.config.rect_width / 2;
        const halfHeight = self.config.rect_height / 2;
        self.drawRect(centerX - halfWidth, centerY - halfHeight, self.config.rect_width, self.config.rect_height, self.config.rect_color.getARGB());
    }

    pub fn drawRect(self: *ColorBuffer, x: u32, y: u32, width: u32, height: u32, color: u32) void {
        var j: u32 = y;
        while (j < y + height) {
            var i: u32 = x;
            while (i < x + width) {
                self.drawPixel(i, j, color);
                i += 1;
            }
            j += 1;
        }
    }
};
