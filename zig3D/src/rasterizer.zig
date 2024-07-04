const Camera = @import("camera.zig").Camera;
const ColorBuffer = @import("color_buffer.zig").ColorBuffer;
const vector = @import("vector.zig");
const Color = @import("color.zig").Color;
const draw = @import("draw.zig");
const Mesh = @import("mesh.zig").Mesh;
const Scene = @import("scene.zig").Scene;
const utils = @import("utils.zig");
const Triangle = @import("triangle.zig").Triangle;
const Geometry = @import("geometry.zig").Geometry;

const std = @import("std");

pub const Rasterizer = struct {
    pub fn renderScene(scene: *Scene, cb: *ColorBuffer) void {
        for (scene.meshes.items) |*mesh| {
            renderMesh(&scene.camera, cb, mesh);
        }
    }

    pub fn renderMesh(cam: *Camera, cb: *ColorBuffer, mesh: *Mesh) void {
        const width = utils.castU32xF32(cam.screen_width);
        const height = utils.castU32xF32(cam.screen_height);
        const half_width = width / 2.0;
        const half_height = height / 2.0;

        for (mesh.faces.items) |face| {
            const v0 = mesh.vertices.items[face.v3u32[0]];
            const v1 = mesh.vertices.items[face.v3u32[1]];
            const v2 = mesh.vertices.items[face.v3u32[2]];

            const opt_p0 = cam.perspectiveProjection(v0);
            const opt_p1 = cam.perspectiveProjection(v1);
            const opt_p2 = cam.perspectiveProjection(v2);

            // horrible, fix this quickly
            if (opt_p0) |p0| {
                if (opt_p1) |p1| {
                    if (opt_p2) |p2| {
                        if (Geometry.backfaceCullingSignedArea(p0, p1, p2)) {
                            continue;
                        }

                        const x0 = p0.x() + half_width;
                        const y0 = p0.y() + half_height;
                        const x1 = p1.x() + half_width;
                        const y1 = p1.y() + half_height;
                        const x2 = p2.x() + half_width;
                        const y2 = p2.y() + half_height;

                        // Clip and draw the first line segment
                        const line1 = draw.CohenSutherlandClip(x0, y0, x1, y1, width, height);
                        if (line1.accept) {
                            const x0_clip: u32 = @intFromFloat(line1.x0);
                            const y0_clip: u32 = @intFromFloat(line1.y0);
                            const x1_clip: u32 = @intFromFloat(line1.x1);
                            const y1_clip: u32 = @intFromFloat(line1.y1);
                            draw.line(cb, x0_clip, y0_clip, x1_clip, y1_clip, @intFromEnum(Color.Pallet.Magenta));
                        }

                        // Clip and draw the second line segment
                        const line2 = draw.CohenSutherlandClip(x1, y1, x2, y2, width, height);
                        if (line2.accept) {
                            const x1_clip: u32 = @intFromFloat(line2.x0);
                            const y1_clip: u32 = @intFromFloat(line2.y0);
                            const x2_clip: u32 = @intFromFloat(line2.x1);
                            const y2_clip: u32 = @intFromFloat(line2.y1);
                            draw.line(cb, x1_clip, y1_clip, x2_clip, y2_clip, @intFromEnum(Color.Pallet.Magenta));
                        }

                        // Clip and draw the third line segment
                        const line3 = draw.CohenSutherlandClip(x2, y2, x0, y0, width, height);
                        if (line3.accept) {
                            const x2_clip: u32 = @intFromFloat(line3.x0);
                            const y2_clip: u32 = @intFromFloat(line3.y0);
                            const x0_clip: u32 = @intFromFloat(line3.x1);
                            const y0_clip: u32 = @intFromFloat(line3.y1);
                            draw.line(cb, x2_clip, y2_clip, x0_clip, y0_clip, @intFromEnum(Color.Pallet.Magenta));
                        }
                    }
                }
            }
        }
    }

    fn drawLine(p0: vector.Vec2f, p1: vector.Vec2f, half_width: f32, half_height: f32, cam: *Camera, cb: *ColorBuffer) void {
        const x0 = p0.x() + half_width;
        const y0 = p0.y() + half_height;
        const x1 = p1.x() + half_width;
        const y1 = p1.y() + half_height;

        const line_in = draw.cohenSutherlandClip(x0, y0, x1, y1, cam.width, cam.height);
        if (line_in.accept) {
            const x0_clip: u32 = @intFromFloat(line_in.x0);
            const y0_clip: u32 = @intFromFloat(line_in.y0);
            const x1_clip: u32 = @intFromFloat(line_in.x1);
            const y1_clip: u32 = @intFromFloat(line_in.y1);
            draw.line(cb, x0_clip, y0_clip, x1_clip, y1_clip, @intFromEnum(Color.Pallet.Magenta));
        }
    }
};
