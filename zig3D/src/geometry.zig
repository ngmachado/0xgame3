const std = @import("std");
const vector = @import("vector.zig");
const Triangle = @import("triangle.zig").Triangle;

pub const Geometry = struct {
    // return true if the triangle is facing the camera. see more about backface culling here: https://en.wikipedia.org/wiki/Back-face_culling
    pub fn backfaceCulling(triangle: Triangle, cameraPosition: vector.Vec3f32) bool {
        const normal = triangle.normal();
        const centroid = triangle.centroid();
        const viewVector = centroid.sub(cameraPosition).normalize();
        const dotProduct = normal.dot(viewVector);
        return dotProduct < 0;
    }
};
