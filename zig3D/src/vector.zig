//! Vector.zig - a simple vector math library that wraps Zig's vector types
const std = @import("std");
const math = std.math;
const expect = std.testing.expect;

/// Vector.zig - a simple vector math library

// vector types
const Vec2_f = @Vector(2, f32);
const Vec3_f = @Vector(3, f32);
const Vec2_u32 = @Vector(2, u32);
const Vec3_u32 = @Vector(3, u32);

// ~~ utility functions ~~

// convert degrees to radians
pub fn toRad(angle_degrees: f32) f32 {
    return angle_degrees * math.pi / 180.0;
}

test "toRad" {
    const angle_degrees: f32 = 90.0;
    const angle_radians: f32 = toRad(angle_degrees);
    try expect(angle_radians == math.pi / 2.0);
}

// convert radians to degrees
pub fn toDeg(angle_radians: f32) f32 {
    return angle_radians * 180.0 / math.pi;
}

test "toDeg" {
    const angle_radians: f32 = math.pi / 2.0;
    const angle_degrees: f32 = toDeg(angle_radians);
    try expect(angle_degrees == 90.0);
}

// ~~ vector functions ~~

// 2D unsigned integer vector
pub const Vec2u32 = struct {
    v2u32: Vec2_u32,

    // initialize Vec2u32
    pub fn init(vx: u32, vy: u32) Vec2u32 {
        return Vec2u32{ .v2u32 = .{ vx, vy } };
    }

    // get x component
    pub fn x(self: Vec2u32) u32 {
        return self.v2u32[0];
    }

    // get y component
    pub fn y(self: Vec2u32) u32 {
        return self.v2u32[1];
    }
};

// 2D float vector
pub const Vec2f32 = struct {
    v2: Vec2_f,

    // initialize Vec2f
    pub fn init(vx: f32, vy: f32) Vec2f32 {
        return Vec2f32{ .v2 = .{ vx, vy } };
    }

    // get x component
    pub fn x(self: Vec2f32) f32 {
        return self.v2[0];
    }

    // get y component
    pub fn y(self: Vec2f32) f32 {
        return self.v2[1];
    }

    // add two vectors, returning a new vector
    pub fn add(self: Vec2f32, other: Vec2f32) Vec2f32 {
        return Vec2f32{ .v2 = self.v2 + other.v2 };
    }

    // subtract two vectors, returning a new vector
    pub fn sub(self: Vec2f32, other: Vec2f32) Vec2f32 {
        return Vec2f32{ .v2 = self.v2 - other.v2 };
    }

    // add a scalar to a vector, returning a new vector
    pub fn addScalar(self: Vec2f32, scalar: f32) Vec2f32 {
        const scalar_vec = @as(Vec2_f, @splat(scalar));
        return Vec2f32{ .v2 = self.v2 + scalar_vec };
    }

    // subtract a scalar from a vector, returning a new vector
    pub fn subScalar(self: Vec2f32, scalar: f32) Vec2f32 {
        const scalar_vec = @as(Vec2_f, @splat(scalar));
        return Vec2f32{ .v2 = self.v2 - scalar_vec };
    }

    // multiply a vector by a scalar, returning a new vector
    pub fn mulScalar(self: Vec2f32, scalar: f32) Vec2f32 {
        const scalar_vec = @as(Vec2_f, @splat(scalar));
        return Vec2f32{ .v2 = self.v2 * scalar_vec };
    }

    // divide a vector by a scalar, returning a new vector
    pub fn divScalar(self: Vec2f32, scalar: f32) Vec2f32 {
        const scalar_vec = @as(Vec2_f, @splat(scalar));
        return Vec2f32{ .v2 = self.v2 / scalar_vec };
    }

    // dot product of two vectors
    pub fn dot(self: Vec2f32, other: Vec2f32) f32 {
        return @reduce(.Add, self.v2 * other.v2);
    }

    // get magnitude of vector
    pub fn length(self: Vec2f32) f32 {
        return @sqrt(self.dot(self));
    }

    // get normalized vector
    pub fn normalize(self: Vec2f32) Vec2f32 {
        const len = self.length();
        if (len == 0) {
            return self;
        }

        const norm_vec = self.v2 / @as(Vec2_f, @splat(len));
        return Vec2f32{ .v2 = norm_vec };
    }

    // get angle between two vectors, in degrees
    pub fn angle(self: Vec2f32, other: Vec2f32) f32 {
        const d = self.dot(other);
        const len = self.length() * other.length();
        if (len == 0) {
            return 0;
        }
        return toDeg(math.acos(d / len));
    }

    // rotate vector by angle in degrees over X axis
    pub fn rotateOverX(self: Vec2f32, angle_degrees: f32) Vec2f32 {
        const angle_rad = toRad(angle_degrees);
        const cos = @cos(angle_rad);
        const sin = @sin(angle_rad);
        return Vec2f32.init(self.x(), self.y() * cos - self.x() * sin);
    }

    // rotate vector by angle in degrees over Y axis
    pub fn rotateOverY(self: Vec2f32, angle_degrees: f32) Vec2f32 {
        const angle_rad = toRad(angle_degrees);
        const cos = @cos(angle_rad);
        const sin = @sin(angle_rad);
        return Vec2f32.init(self.x() * cos - self.y() * sin, self.y());
    }
};

// 3D float vector
pub const Vec3f = struct {
    v3: Vec3_f,

    // initialize Vec3f
    pub fn init(vx: f32, vy: f32, vz: f32) Vec3f {
        return Vec3f{ .v3 = .{ vx, vy, vz } };
    }

    pub fn x(self: Vec3f) f32 {
        return self.v3[0];
    }

    pub fn y(self: Vec3f) f32 {
        return self.v3[1];
    }

    pub fn z(self: Vec3f) f32 {
        return self.v3[2];
    }

    // add two vectors, returning a new vector
    pub fn add(self: Vec3f, other: Vec3f) Vec3f {
        return Vec3f{ .v3 = self.v3 + other.v3 };
    }

    // subtract two vectors, returning a new vector
    pub fn sub(self: Vec3f, other: Vec3f) Vec3f {
        return Vec3f{ .v3 = self.v3 - other.v3 };
    }

    // add a scalar to a vector, returning a new vector
    pub fn addScalar(self: Vec3f, scalar: f32) Vec3f {
        const scalar_vec = @as(Vec3_f, @splat(scalar));
        return Vec3f{ .v3 = self.v3 + scalar_vec };
    }

    // subtract a scalar from a vector, returning a new vector
    pub fn subScalar(self: Vec3f, scalar: f32) Vec3f {
        const scalar_vec = @as(Vec3_f, @splat(scalar));
        return Vec3f{ .v3 = self.v3 - scalar_vec };
    }

    // multiply a vector by a scalar, returning a new vector
    pub fn mulScalar(self: Vec3f, scalar: f32) Vec3f {
        const scalar_vec = @as(Vec3_f, @splat(scalar));
        return Vec3f{ .v3 = self.v3 * scalar_vec };
    }

    // divide a vector by a scalar, returning a new vector
    pub fn divScalar(self: Vec3f, scalar: f32) Vec3f {
        const scalar_vec = @as(Vec3_f, @splat(scalar));
        return Vec3f{ .v3 = self.v3 / scalar_vec };
    }

    // dot product of two vectors
    pub fn dot(self: Vec3f, other: Vec3f) f32 {
        return @reduce(.Add, self.v3 * other.v3);
    }

    // cross product of two vectors
    pub fn cross(self: Vec3f, other: Vec3f) Vec3f {
        return Vec3f.init(self.y() * other.z() - self.z() * other.y(), self.z() * other.x() - self.x() * other.z(), self.x() * other.y() - self.y() * other.x());
    }

    // get magnitude of vector
    pub fn length(self: Vec3f) f32 {
        return @sqrt(self.dot(self));
    }

    // get normalized vector
    pub fn normalize(self: Vec3f) Vec3f {
        const len = self.length();
        if (len == 0) {
            return self;
        }

        const norm_vec = self.v3 / @as(Vec3_f, @splat(len));
        return Vec3f{ .v3 = norm_vec };
    }

    // get angle between two vectors, in degrees
    pub fn angle(self: Vec3f, other: Vec3f) f32 {
        const d = self.dot(other);
        const len = self.length() * other.length();
        if (len == 0) {
            return 0;
        }
        return toDeg(math.acos(d / len));
    }

    // rotate vector by angle in degrees over X axis
    pub fn rotateOverX(self: Vec3f, rot_angle: f32) Vec3f {
        const cos = @cos(rot_angle);
        const sin = @sin(rot_angle);

        const _new_x = self.x();
        const _new_y = self.y() * cos - self.z() * sin;
        const _new_z = self.y() * sin + self.z() * cos;

        return Vec3f.init(_new_x, _new_y, _new_z);
    }

    // rotate vector by angle in degrees over Y axis
    pub fn rotateOverY(self: Vec3f, rot_angle: f32) Vec3f {
        const cos = @cos(rot_angle);
        const sin = @sin(rot_angle);

        const _new_x = self.x() * cos - self.z() * sin;
        const _new_y = self.y();
        const _new_z = self.x() * sin + self.z() * cos;

        return Vec3f.init(_new_x, _new_y, _new_z);
    }

    // rotate vector by angle in degrees over Z axis
    pub fn rotateOverZ(self: Vec3f, rot_angle: f32) Vec3f {
        const cos = @cos(rot_angle);
        const sin = @sin(rot_angle);

        const _new_x = self.x() * cos - self.y() * sin;
        const _new_y = self.x() * sin + self.y() * cos;
        const _new_z = self.z();

        return Vec3f.init(_new_x, _new_y, _new_z);
    }

    pub fn rotateY(self: *Vec3f, rot_angle: f32) void {
        self.* = self.rotateOverY(rot_angle);
    }

    pub fn eql(self: Vec3f, other: Vec3f) bool {
        return self.x() == other.x() and self.y() == other.y() and self.z() == other.z();
    }

    pub fn isZero(self: Vec3f) bool {
        return self.x() == 0.0 and self.y() == 0.0 and self.z() == 0.0;
    }

    // negate vector, returning a new vector
    pub fn negate(self: Vec3f) Vec3f {
        return Vec3f.init(-self.x(), -self.y(), -self.z());
    }
};
