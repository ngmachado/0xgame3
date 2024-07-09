const std = @import("std");
const vector = @import("vector.zig");
const Vec3f32 = vector.Vec3f32;
const Vec3u32 = vector.Vec3u32;
const math = std.math;

pub const Mesh = struct {
    allocator: std.mem.Allocator,
    vertices: std.ArrayList(Vec3f32),
    faces: std.ArrayList(Vec3u32),
    world_position: Vec3f32 = Vec3f32.initZero(),

    pub fn init(allocator: std.mem.Allocator) !Mesh {
        return Mesh{
            .allocator = allocator,
            .vertices = std.ArrayList(Vec3f32).init(allocator),
            .faces = std.ArrayList(Vec3u32).init(allocator),
        };
    }

    pub fn deinit(self: Mesh) void {
        self.allocator.free(self.vertices);
        self.allocator.free(self.faces);
    }

    pub fn applyTransform(self: *Mesh, transform: fn (Vec3f32, f32) Vec3f32, param: f32) void {
        for (self.vertices.items, 0..) |vertex, i| {
            self.vertices.items[i] = transform(vertex, param);
        }
    }

    pub fn addVertex(self: *Mesh, x: f32, y: f32, z: f32) !void {
        try self.vertices.append(Vec3f32.init(x, y, z));
    }

    pub fn addFace(self: *Mesh, a: u32, b: u32, c: u32) !void {
        try self.faces.append(Vec3u32.init(a, b, c));
    }

    pub fn center(self: *Mesh) void {
        const bbox = self.calculateBoundingBox();
        const _center = Vec3f32.init(
            (bbox.min.x() + bbox.max.x()) / 2.0,
            (bbox.min.y() + bbox.max.y()) / 2.0,
            (bbox.min.z() + bbox.max.z()) / 2.0,
        );
        const translation = _center.mulScalar(-1.0);
        for (self.vertices.items) |*vertex| {
            vertex.* = vertex.add(translation);
        }
    }

    pub fn calculateBoundingBox(self: *Mesh) struct { min: Vec3f32, max: Vec3f32 } {
        const f32inf = math.inf(f32);
        var min = Vec3f32.init(f32inf, f32inf, f32inf);
        var max = Vec3f32.init(-f32inf, -f32inf, -f32inf);

        for (self.vertices.items) |vertex| {
            min = Vec3f32.init(
                @min(min.x(), vertex.x()),
                @min(min.y(), vertex.y()),
                @min(min.z(), vertex.z()),
            );
            max = Vec3f32.init(
                @max(max.x(), vertex.x()),
                @max(max.y(), vertex.y()),
                @max(max.z(), vertex.z()),
            );
        }

        return .{
            .min = min,
            .max = max,
        };
    }

    pub fn translateToPosition(self: *Mesh, position: Vec3f32) void {
        for (self.vertices.items) |*vertex| {
            vertex.* = vertex.add(position);
        }
    }

    pub fn LoadFromObjFile(allocator: std.mem.Allocator, path: []const u8) !Mesh {
        var mesh = try Mesh.init(allocator);
        var file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        var buffered = std.io.bufferedReader(file.reader());
        var reader = buffered.reader();

        var arr = std.ArrayList(u8).init(allocator);
        defer arr.deinit();

        while (true) {
            reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
                error.EndOfStream => break,
                else => return err,
            };
            var lines = std.mem.splitAny(u8, arr.items, "\n");
            if (std.mem.startsWith(u8, arr.items, "v ")) {
                while (lines.next()) |line| {
                    if (!std.mem.eql(u8, line, " ")) {
                        if (line.len < 4) {
                            continue;
                        }
                        var line_components = std.mem.splitAny(u8, line, " ");
                        _ = line_components.next(); // ignore the first element
                        const x = try std.fmt.parseFloat(f32, line_components.next().?);
                        const y = try std.fmt.parseFloat(f32, line_components.next().?);
                        const z = try std.fmt.parseFloat(f32, line_components.next().?);
                        try mesh.addVertex(x, -y, z);
                    }
                }
            } else if (std.mem.startsWith(u8, arr.items, "f ")) {
                while (lines.next()) |line| {
                    var parts = std.mem.splitAny(u8, line, " ");
                    _ = parts.next();

                    const part1 = parts.next() orelse return error.InvalidFormat;
                    var line_components = std.mem.splitAny(u8, part1, "/");
                    const idx_a = try std.fmt.parseUnsigned(u32, line_components.next() orelse return error.InvalidFormat, 10);

                    const part2 = parts.next() orelse return error.InvalidFormat;
                    line_components = std.mem.splitAny(u8, part2, "/");
                    const idx_b = try std.fmt.parseUnsigned(u32, line_components.next() orelse return error.InvalidFormat, 10);

                    const part3 = parts.next() orelse return error.InvalidFormat;
                    line_components = std.mem.splitAny(u8, part3, "/");
                    const idx_c = try std.fmt.parseUnsigned(u32, line_components.next() orelse return error.InvalidFormat, 10);

                    try mesh.addFace(idx_a - 1, idx_b - 1, idx_c - 1);
                }
            }

            arr.clearRetainingCapacity();
        }

        return mesh;
    }
};
