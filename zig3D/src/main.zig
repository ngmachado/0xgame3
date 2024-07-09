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
        .grid_color = Color.fromPallet(Color.ModernPallet.RichBlack),
        .background_color = Color.fromPallet(Color.ModernPallet.MidnightGreen),
        .draw_center_rect = true,
        .rect_color = Color.fromPallet(Color.ModernPallet.Rufous),
        .rect_width = 10,
        .rect_height = 10,
    };

    var colorBuffer = try ColorBuffer.init(allocator, screen.width, screen.height, colorBufferConfig);
    defer colorBuffer.deinit();

    // set camera config
    const cameraConfig = Camera.Config{
        .position = vector.Vec3f32.init(-0.9, 0, 5.5),
        .screen_width = screen.width,
        .screen_height = screen.height,
        .fov_factor = 60, // common values are: 30, 45, 60, 90
        .near_plane = 0.001,
        .far_plane = -10000,
        .speed = 23.14,
    };

    var meshFiles = std.ArrayList([]const u8).init(allocator);
    defer meshFiles.deinit();
    try meshFiles.append("assets/models/bunny3.obj");
    // try meshFiles.append("assets/models/cube.obj");
    //try meshFiles.append("assets/models/teapot.obj");

    var scene = try Scene.init(allocator, cameraConfig);
    try setupScene(&scene, meshFiles);

    var last_time: i64 = std.time.milliTimestamp();
    var start_time = last_time;
    var frame_count: u32 = 0;
    var quit = false;
    var changed = true; // first frame should be rendered, this way we just for testing FPS. Will break with transformations

    while (!quit) {
        const current_time: i64 = std.time.milliTimestamp();
        const delta_time = calculateDeltaTime(last_time, current_time);
        last_time = current_time;

        handleInput(&quit, &scene.camera, &changed);
        if (quit) break;
        if (changed) {
            update(&scene, &colorBuffer, delta_time);
            rasterizeScene(&scene, &colorBuffer);
            try displayFrame(&screen, &colorBuffer);
            changed = false;
        }
        manageFrameRate(current_time, &start_time, &frame_count);
    }
}

fn handleInput(quit: *bool, camera: *Camera, changed: *bool) void {
    const event = input.poll();
    const step = 0.1;
    switch (event) {
        input.Event.QUIT => {
            quit.* = true;
        },
        input.Event.ESCAPE => {
            quit.* = true;
        },
        input.Event.UP => {
            changed.* = true;
            camera.setTargetPosition(vector.Vec3f32.init(0, -step, 0));
        },
        input.Event.DOWN => {
            changed.* = true;
            camera.setTargetPosition(vector.Vec3f32.init(0, step, 0));
        },
        input.Event.w => {
            changed.* = true;
            camera.setTargetPosition(vector.Vec3f32.init(0, 0, -step));
        },
        input.Event.s => {
            changed.* = true;
            camera.setTargetPosition(vector.Vec3f32.init(0, 0, step));
        },
        input.Event.a => {
            changed.* = true;
            camera.setTargetPosition(vector.Vec3f32.init(-step, 0, 0));
        },
        input.Event.d => {
            changed.* = true;
            camera.setTargetPosition(vector.Vec3f32.init(step, 0, 0));
        },
        input.Event.c => {
            changed.* = true;
            camera.setTargetPosition(vector.Vec3f32.init(-0.9, 0, 5.5));
        },
        else => {},
    }
}

fn setupScene(scene: *Scene, files: std.ArrayList([]const u8)) !void {
    var init_pos = vector.Vec3f32.init(0, 0, 0);
    const pos_offset = vector.Vec3f32.init(2, 2, 2);

    for (files.items) |file| {
        try scene.loadMesh(allocator, file, init_pos);
        init_pos = init_pos.add(pos_offset);
    }
}

fn update(scene: *Scene, cb: *ColorBuffer, deltaTime: f32) void {
    cb.update();
    scene.update(deltaTime);
}

fn rasterizeScene(scene: *Scene, cb: *ColorBuffer) void {
    Rasterizer.renderScene(scene, cb, true);
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
