const std = @import("std");
const vector = @import("vector.zig");

pub const Face = struct {
    vertex_indices: vector.Vec3u32,

    pub fn init(vertex_indices: vector.Vec3u32) Face {
        return Face{
            .vertex_indices = vertex_indices,
        };
    }
};

pub const Texture = struct {
    u: f32,
    v: f32,

    pub fn init(u: f32, v: f32) Texture {
        return Texture{ .u = u, .v = v };
    }
};

pub const Mesh = struct {
    allocator: std.mem.Allocator,

    vertices: std.ArrayList(vector.Vec3f),
    normals: std.ArrayList(vector.Vec3f),
    texture_coords: std.ArrayList(Texture),
    faces: std.ArrayList(Face),

    pub fn init(allocator: std.mem.Allocator) !Mesh {
        return Mesh{
            .allocator = allocator,
            .vertices = std.ArrayList(vector.Vec3f).init(allocator),
            .normals = std.ArrayList(vector.Vec3f).init(allocator),
            .texture_coords = std.ArrayList(Texture).init(allocator),
            .faces = std.ArrayList(Face).init(allocator),
        };
    }

    pub fn deinit(self: *Mesh) void {
        self.vertices.deinit();
        self.normals.deinit();
        self.texture_coords.deinit();
        self.faces.deinit();
    }

    pub fn addVertex(self: *Mesh, x: f32, y: f32, z: f32) !void {
        try self.vertices.append(vector.Vec3f.init(x, y, z));
    }

    pub fn addFace(self: *Mesh, a: u32, b: u32, c: u32) !void {
        try self.faces.append(Face.init(vector.Vec3u32.init(a, b, c)));
    }

    pub fn addNormal(self: *Mesh, x: f32, y: f32, z: f32) !void {
        try self.normals.append(vector.Vec3f.init(x, y, z));
    }

    pub fn addTextureCoord(self: *Mesh, u: f32, v: f32) !void {
        try self.texture_coords.append(Texture.init(u, v));
    }

    pub fn applyTransform(self: *Mesh, transform: fn (vector.Vec3f, f32) vector.Vec3f, param: f32) void {
        for (self.vertices.items, 0..) |vertex, i| {
            self.vertices.items[i] = transform(vertex, param);
        }
        for (self.normals.items, 0..) |normal, i| {
            self.normals.items[i] = transform(normal, param);
        }
    }

    pub fn LoadFromFile(path: []const u8, allocator: std.mem.Allocator) !Mesh {
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
            var lines = std.mem.splitAny(u8, arr.items, "\n"); // todo: fix this, terminator on windows is \r\n
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
            } else if (std.mem.startsWith(u8, arr.items, "vn ")) {
                while (lines.next()) |line| {
                    if (!std.mem.eql(u8, line, " ")) {
                        if (line.len < 5) {
                            continue;
                        }
                        var line_components = std.mem.splitAny(u8, line, " ");
                        _ = line_components.next(); // ignore the first element
                        const x = try std.fmt.parseFloat(f32, line_components.next().?);
                        const y = try std.fmt.parseFloat(f32, line_components.next().?);
                        const z = try std.fmt.parseFloat(f32, line_components.next().?);
                        try mesh.addNormal(x, y, z);
                    }
                }
            } else if (std.mem.startsWith(u8, arr.items, "vt ")) {
                while (lines.next()) |line| {
                    if (!std.mem.eql(u8, line, " ")) {
                        if (line.len < 5) {
                            continue;
                        }
                        var line_components = std.mem.splitAny(u8, line, " ");
                        _ = line_components.next(); // ignore the first element
                        const u = try std.fmt.parseFloat(f32, line_components.next().?);
                        const v = try std.fmt.parseFloat(f32, line_components.next().?);
                        try mesh.addTextureCoord(u, v);
                    }
                }
            } else if (std.mem.startsWith(u8, arr.items, "f ")) {
                while (lines.next()) |line| {
                    var parts = std.mem.splitAny(u8, line, " ");
                    _ = parts.next(); // ignore the first element

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
