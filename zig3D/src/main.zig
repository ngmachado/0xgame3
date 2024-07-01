//! Initialize the display and color buffer, and handle input events
const std = @import("std");
const display = @import("display.zig");
const buffer = @import("color_buffer.zig");
const vector = @import("vector.zig");
const Color = @import("color.zig").Color;
const input = @import("input.zig");
const Scene = @import("scene.zig").Scene;
const Camera = @import("camera.zig").Camera;

const TargetFPS: u32 = 120;
const TargetFrameDurationMs: i64 = 1000 / TargetFPS;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    var screen = try display.Display.init(1024, 900);
    defer screen.deinit();

    const config = buffer.ColorBufferConfig{
        .draw_grid = buffer.GridOption.Simple,
        .grid_color = null,
        .background_color = Color.fromBytes(0, 0, 0, 255),
        .draw_center_rect = true,
        .rect_color = Color.fromBytes(255, 0, 0, 255),
        .rect_width = 50,
        .rect_height = 50,
    };

    var colorBuffer = try buffer.ColorBuffer.init(allocator, screen.size.getWidth(), screen.size.getHeight(), config);
    defer colorBuffer.deinit();

    // set camera config
    const cameraConfig = Camera.Config{
        .position = vector.Vec3f.init(0.0, 0.0, 0.0),
        .orientation = vector.Vec3f.init(0.0, 0.0, 0.0),
        .screen_width = screen.size.getWidth(),
        .screen_height = screen.size.getHeight(),
        .fov_factor = 90.0,
        .near_plane = 0.1,
        .far_plane = 100.0,
        .speed = 0.1,
    };

    var scene = try Scene.init(allocator, cameraConfig);
    try setupScene(&scene);

    var last_time: i64 = std.time.milliTimestamp();
    var start_time = last_time;
    var frame_count: u32 = 0;
    var quit = false;

    while (!quit) {
        const current_time: i64 = std.time.milliTimestamp();
        //const delta_time = calculateDeltaTime(last_time, current_time);
        last_time = current_time;

        handleInput(&quit);
        if (quit) break;

        colorBuffer.clear();
        try displayOutput(&screen, &colorBuffer);

        manageFrameRate(current_time, &start_time, &frame_count);
    }
}

fn handleInput(quit: *bool) void {
    const event = input.poll();
    switch (event) {
        input.Event.QUIT => {
            quit.* = true;
        },
        input.Event.ESCAPE => {
            quit.* = true;
        },
        input.Event.UP => {
            std.debug.print("UP\n", .{});
        },
        input.Event.DOWN => {
            std.debug.print("DOWN\n", .{});
        },
        input.Event.w => {
            std.debug.print("w\n", .{});
        },
        input.Event.s => {
            std.debug.print("s\n", .{});
        },
        input.Event.a => {
            std.debug.print("a\n", .{});
        },
        input.Event.d => {
            std.debug.print("d\n", .{});
        },
        else => {},
    }
}

fn setupScene(scene: *Scene) !void {
    try scene.loadMesh(allocator, "assets/bunny.obj");
}

fn displayOutput(screen: *display.Display, cb: *buffer.ColorBuffer) !void {
    try screen.render(cb.getPtr());
}

fn calculateDeltaTime(lastTime: i64, currentTime: i64) f32 {
    return @as(f32, @floatFromInt(currentTime - lastTime)) / 1000.0;
}

fn manageFrameRate(currentTime: i64, startTime: *i64, frameCount: *u32) void {
    frameCount.* += 1;
    if (currentTime - startTime.* >= 1000) {
        const fps = frameCount.*;
        std.debug.print("FPS: {}\n", .{fps});
        frameCount.* = 0;
        startTime.* = currentTime;
    }

    const frameDuration: i64 = std.time.milliTimestamp() - currentTime;
    if (frameDuration < TargetFrameDurationMs) {
        const sleepDuration = TargetFrameDurationMs - frameDuration;
        std.time.sleep(@as(u64, @intCast(sleepDuration)) * 1000000); // Convert milliseconds to nanoseconds
    }
}
