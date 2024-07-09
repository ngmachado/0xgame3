const std = @import("std");
const Camera = @import("camera.zig").Camera;
const Mesh = @import("mesh.zig").Mesh;
const Vec3f32 = @import("vector.zig").Vec3f32;

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

    pub fn loadMesh(self: *Scene, allocator: std.mem.Allocator, filepath: []const u8, word_position: Vec3f32) !void {
        var mesh = try Mesh.LoadFromObjFile(allocator, filepath);
        mesh.world_position = word_position;
        try self.meshes.append(mesh);
    }

    pub fn update(self: *Scene, deltaTime: f32) void {
        self.camera.updatePosition(deltaTime);
    }

    pub fn getCamera(self: *Scene) *Camera {
        return &self.camera;
    }
};
