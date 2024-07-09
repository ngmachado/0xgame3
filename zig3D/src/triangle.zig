const vector = @import("vector.zig");
const Vec3f32 = vector.Vec3f32;
const Vec2f32 = vector.Vec2f32;

pub const Triangle = struct {
    v0: Vec3f32,
    v1: Vec3f32,
    v2: Vec3f32,

    pub fn init(v0: Vec3f32, v1: Vec3f32, v2: Vec3f32) Triangle {
        return Triangle{
            .v0 = v0,
            .v1 = v1,
            .v2 = v2,
        };
    }

    pub fn sortVerticesByY(v0: Vec3f32, v1: Vec3f32, v2: Vec3f32) Triangle {
        var triangle = Triangle{
            .v0 = v0,
            .v1 = v1,
            .v2 = v2,
        };
        triangle.sortByY();
        return triangle;
    }

    pub fn normal(self: Triangle) Vec3f32 {
        const edge1 = self.v1.sub(self.v0);
        const edge2 = self.v2.sub(self.v0);
        return edge1.cross(edge2).normalize();
    }

    pub fn centroid(self: Triangle) Vec3f32 {
        return (self.v0.add(self.v1).add(self.v2)).divScalar(3);
    }

    pub fn barycentric(self: Triangle, p: Vec2f32) Vec3f32 {
        const v0 = self.v1.sub(self.v0).toVec2();
        const v1 = self.v2.sub(self.v0).toVec2();
        const v2 = p.sub(self.v0.toVec2());

        const d00 = v0.dot(v0);
        const d01 = v0.dot(v1);
        const d11 = v1.dot(v1);
        const d20 = v2.dot(v0);
        const d21 = v2.dot(v1);

        const denom = d00 * d11 - d01 * d01;
        const v = (d11 * d20 - d01 * d21) / denom;
        const w = (d00 * d21 - d01 * d20) / denom;
        const u = 1.0 - v - w;

        return Vec3f32.init(u, v, w);
    }
};
