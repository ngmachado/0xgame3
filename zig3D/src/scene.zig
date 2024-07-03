const std = @import("std");
const Camera = @import("camera.zig").Camera;
const Mesh = @import("mesh.zig").Mesh;

pub const Scene = struct {
    camera: Camera,
    meshes: std.ArrayList(Mesh),

    pub fn init(allocator: std.mem.Allocator, camera_config: Camera.Config) !Scene {
        return Scene{
            .camera = Camera.init(camera_config),
            .meshes = std.ArrayList(Mesh).init(allocator),
        };
    }

    pub fn deinit(self: *Scene) void {
        for (self.meshes.items) |mesh| {
            mesh.deinit();
        }
        self.meshes.deinit();
    }

    pub fn loadMesh(self: *Scene, allocator: std.mem.Allocator, filepath: []const u8) !void {
        const mesh = try Mesh.LoadFromObjFile(allocator, filepath);
        try self.meshes.append(mesh);
    }

    pub fn update(self: *Scene, deltaTime: f32) void {
        self.camera.updatePosition(deltaTime);
    }

    pub fn getCamera(self: *Scene) *Camera {
        return &self.camera;
    }
};