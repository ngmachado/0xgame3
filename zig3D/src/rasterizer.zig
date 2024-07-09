const Camera = @import("camera.zig").Camera;
const ColorBuffer = @import("color_buffer.zig").ColorBuffer;
const vector = @import("vector.zig");
const Vec2f32 = vector.Vec2f32;
const Vec3f32 = vector.Vec3f32;
const Color = @import("color.zig").Color;
const draw = @import("draw.zig");
const Mesh = @import("mesh.zig").Mesh;
const Scene = @import("scene.zig").Scene;
const utils = @import("utils.zig");
const Triangle = @import("triangle.zig").Triangle;
const Geometry = @import("geometry.zig").Geometry;

const std = @import("std");

pub const Rasterizer = struct {
    /// renders the scene to the color buffer
    pub fn renderScene(scene: *Scene, cb: *ColorBuffer, show_wire: bool) void {
        for (scene.meshes.items) |*mesh| {
            mesh.center();
            mesh.translateToPosition(Vec3f32.init(0, 0, -1.0));
            renderMesh(&scene.camera, cb, mesh, show_wire);
        }
    }

    /// renders the mesh to the color buffer
    pub fn renderMesh(cam: *Camera, cb: *ColorBuffer, mesh: *Mesh, show_wire: bool) void {
        const width = utils.castU32xF32(cam.screen_width);
        const height = utils.castU32xF32(cam.screen_height);
        for (mesh.faces.items) |face| {
            const v0 = mesh.vertices.items[face.v3u32[0]];
            const v1 = mesh.vertices.items[face.v3u32[1]];
            const v2 = mesh.vertices.items[face.v3u32[2]];

            const opt_p0 = cam.project(v0);
            const opt_p1 = cam.project(v1);
            const opt_p2 = cam.project(v2);

            if (opt_p0) |p0| {
                if (opt_p1) |p1| {
                    if (opt_p2) |p2| {
                        if (Geometry.backfaceCullingSignedArea(p0, p1, p2)) {
                            continue;
                        }

                        if (show_wire) {
                            drawWireframe(cb, p0, p1, p2, width, height, @intFromEnum(Color.ModernPallet.Rust));
                        }
                        // fill triangle using barycentric coordinates
                        const trig = Triangle.init(p0.toVec3(), p1.toVec3(), p2.toVec3());
                        fillTriangle(cb, trig, width, height, v0.z(), v1.z(), v2.z());
                    }
                }
            }
        }
    }

    fn drawWireframe(cb: *ColorBuffer, p0: Vec2f32, p1: Vec2f32, p2: Vec2f32, width: f32, height: f32, color: u32) void {
        const z = -1000.0;
        drawClippedLine(cb, p0, p1, width, height, color, z, z);
        drawClippedLine(cb, p1, p2, width, height, color, z, z);
        drawClippedLine(cb, p2, p0, width, height, color, z, z);
    }

    fn drawClippedLine(cb: *ColorBuffer, p0: Vec2f32, p1: Vec2f32, width: f32, height: f32, color: u32, z0: f32, z1: f32) void {
        const x0 = p0.x();
        const y0 = p0.y();
        const x1 = p1.x();
        const y1 = p1.y();

        const line = draw.CohenSutherlandClip(x0, y0, x1, y1, width, height);
        if (line.accept) {
            const x0_clip: u32 = @intFromFloat(line.x0);
            const y0_clip: u32 = @intFromFloat(line.y0);
            const x1_clip: u32 = @intFromFloat(line.x1);
            const y1_clip: u32 = @intFromFloat(line.y1);
            const z = (z0 + z1) / 2.0;
            draw.line(cb, x0_clip, y0_clip, x1_clip, y1_clip, color, z);
        }
    }

    /// fills the triangle with the given color using barycentric coordinates. see: https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-stage.html
    fn fillTriangle(cb: *ColorBuffer, triangle: Triangle, width: f32, height: f32, z0: f32, z1: f32, z2: f32) void {
        const _minX = @max(0.0, @min(triangle.v0.x(), @min(triangle.v1.x(), triangle.v2.x())));
        const _maxX = @min(width - 1, @max(triangle.v0.x(), @max(triangle.v1.x(), triangle.v2.x())));
        const _minY = @max(0.0, @min(triangle.v0.y(), @min(triangle.v1.y(), triangle.v2.y())));
        const _maxY = @min(height - 1, @max(triangle.v0.y(), @max(triangle.v1.y(), triangle.v2.y())));

        var y: f32 = _minY;
        while (y <= _maxY) {
            var x: f32 = _minX;
            while (x <= _maxX) {
                const p = Vec2f32.init(x, y);
                const bary = triangle.barycentric(p);
                if (bary.x() >= 0 and bary.y() >= 0 and bary.z() >= 0) {
                    const z = bary.x() * z0 + bary.y() * z1 + bary.z() * z2;
                    cb.drawPixel(@intFromFloat(@round(x)), @intFromFloat(@round(y)), @intFromEnum(Color.ModernPallet.Vanilla), z);
                }
                x += 0.5;
            }
            y += 0.5;
        }
    }
};
