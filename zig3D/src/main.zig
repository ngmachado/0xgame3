//! initialize the display and color buffer, and handle input events
const std = @import("std");
const Display = @import("display.zig").Display;
const ColorBuffer = @import("color_buffer.zig").ColorBuffer;
const vector = @import("vector.zig");
const Color = @import("color.zig").Color;
const input = @import("input.zig");
const Scene = @import("scene.zig").Scene;
const Camera = @import("camera.zig").Camera;
const Rasterizer = @import("rasterizer.zig").Rasterizer;

const TargetFPS: u32 = 120;
const TargetFrameDurationMs: i64 = 1000 / TargetFPS;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    var screen = try Display.init(1024, 900);
    defer screen.deinit();

    const colorBufferConfig = ColorBuffer.Config{
        .draw_grid = ColorBuffer.GridOption.Simple,
        .grid_color = null,
        .background_color = Color.fromBytes(0, 0, 0, 255),
        .draw_center_rect = true,
        .rect_color = Color.fromBytes(255, 0, 0, 255),
        .rect_width = 10,
        .rect_height = 10,
    };

    var colorBuffer = try ColorBuffer.init(allocator, screen.width, screen.height, colorBufferConfig);
    defer colorBuffer.deinit();

    // set camera config
    const cameraConfig = Camera.Config{
        .position = vector.Vec3f32.init(0, 0, -1000),
        .screen_width = screen.width,
        .screen_height = screen.height,
        .fov_factor = 800,
        .near_plane = 0.0001,
        .far_plane = 100000.0,
        .speed = 23.14,
    };

    var meshFiles = std.ArrayList([]const u8).init(allocator);
    defer meshFiles.deinit();
    try meshFiles.append("assets/models/city.obj");

    var scene = try Scene.init(allocator, cameraConfig);
    try setupScene(&scene, meshFiles);

    var last_time: i64 = std.time.milliTimestamp();
    var start_time = last_time;
    var frame_count: u32 = 0;
    var quit = false;

    while (!quit) {
        const current_time: i64 = std.time.milliTimestamp();
        const delta_time = calculateDeltaTime(last_time, current_time);
        last_time = current_time;

        handleInput(&quit, &scene.camera);
        if (quit) break;

        update(&scene, &colorBuffer, delta_time);
        rasterizeScene(&scene, &colorBuffer);
        try displayFrame(&screen, &colorBuffer);

        manageFrameRate(current_time, &start_time, &frame_count);
    }
}

fn handleInput(quit: *bool, camera: *Camera) void {
    const event = input.poll();
    switch (event) {
        input.Event.QUIT => {
            quit.* = true;
        },
        input.Event.ESCAPE => {
            quit.* = true;
        },
        input.Event.UP => {
            camera.setTargetPosition(vector.Vec3f32.init(0, 100, 0));
        },
        input.Event.DOWN => {
            camera.setTargetPosition(vector.Vec3f32.init(0, -100, 0));
        },
        input.Event.w => {
            camera.setTargetPosition(vector.Vec3f32.init(0, 0, 100));
        },
        input.Event.s => {
            camera.setTargetPosition(vector.Vec3f32.init(0, 0, -100));
        },
        input.Event.a => {
            camera.setTargetPosition(vector.Vec3f32.init(100, 0, 0));
        },
        input.Event.d => {
            camera.setTargetPosition(vector.Vec3f32.init(-100, 0, 0));
        },
        else => {},
    }
}

fn setupScene(scene: *Scene, files: std.ArrayList([]const u8)) !void {
    for (files.items) |file| {
        try scene.loadMesh(allocator, file);
    }
}

fn update(scene: *Scene, cb: *ColorBuffer, deltaTime: f32) void {
    cb.update();
    scene.update(deltaTime);
}

fn rasterizeScene(scene: *Scene, cb: *ColorBuffer) void {
    Rasterizer.renderScene(scene, cb);
}

fn displayFrame(screen: *Display, cb: *ColorBuffer) !void {
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
        std.time.sleep(@as(u64, @intCast(sleepDuration)) * 1000000);
    }
}
