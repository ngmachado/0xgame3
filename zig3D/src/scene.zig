const std = @import("std");
const Camera = @import("camera.zig").Camera;
const Mesh = @import("mesh.zig").Mesh;
const vector = @import("vector.zig");

pub const Scene = struct {
    camera: Camera,
    meshes: std.ArrayList(Mesh),

    pub fn init(allocator: std.mem.Allocator, cameraConfig: Camera.Config) !Scene {
        return Scene{
            .camera = Camera.init(cameraConfig),
            .meshes = std.ArrayList(Mesh).init(allocator),
        };
    }

    pub fn loadMesh(self: *Scene, allocator: std.mem.Allocator, filepath: []const u8) !void {
        const mesh = try Mesh.LoadFromFile(filepath, allocator);
        try self.meshes.append(mesh);
    }
};
