///! contains functions to work with geometry, like backface culling
const std = @import("std");
const vector = @import("vector.zig");
const Vec2f32 = vector.Vec2f32;
const Triangle = @import("triangle.zig").Triangle;

///functions to work with geometry, like backface culling
pub const Geometry = struct {
    ///return true if the triangle is facing the camera. see more about backface culling here: https://en.wikipedia.org/wiki/Back-face_culling
    pub fn backfaceCulling(triangle: Triangle, cameraPosition: vector.Vec3f32) bool {
        const normal = triangle.normal();
        const centroid = triangle.centroid();
        const viewVector = centroid.sub(cameraPosition).normalize();
        const dotProduct = normal.dot(viewVector);
        return dotProduct < 0;
    }

    ///signed area of the triangle is positive if the vertices are ordered counter-clockwise, see https://glasnost.itcarlow.ie/~powerk/GeneralGraphicsNotes/HSR/backfaceculling.html
    pub fn backfaceCullingSignedArea(p0: Vec2f32, p1: Vec2f32, p2: Vec2f32) bool {
        const area = 0.5 * ((p1.x() - p0.x()) * (p2.y() - p0.y()) - (p2.x() - p0.x()) * (p1.y() - p0.y()));
        return area < 0;
    }
};
