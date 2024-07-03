const Vec3f32 = @import("vector.zig").Vec3f32;

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

    pub fn normal(self: Triangle) Vec3f32 {
        const edge1 = self.v1.sub(self.v0);
        const edge2 = self.v2.sub(self.v0);
        return edge1.cross(edge2).normalize();
    }

    pub fn centroid(self: Triangle) Vec3f32 {
        return (self.v0.add(self.v1).add(self.v2)).divScalar(3);
    }
};
