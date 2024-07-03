const std = @import("std");
const math = std.math;
const utils = @import("utils.zig");

const Vec2_f32 = @Vector(2, f32);
const Vec3_f32 = @Vector(3, f32);
const Vec2_u32 = @Vector(2, u32);
const Vec3_u32 = @Vector(3, u32);

pub const Vec2u32 = struct {
    v2u32: Vec2_u32,

    pub fn init(vx: u32, vy: u32) Vec2u32 {
        return Vec2u32{ .v2u32 = .{ vx, vy } };
    }

    pub fn initZero() Vec2u32 {
        return Vec2u32.init(0, 0);
    }

    pub fn x(self: Vec2u32) u32 {
        return self.v2u32[0];
    }

    pub fn y(self: Vec2u32) u32 {
        return self.v2u32[1];
    }
};

pub const Vec3u32 = struct {
    v3u32: Vec3_u32,

    pub fn init(vx: u32, vy: u32, vz: u32) Vec3u32 {
        return Vec3u32{ .v3u32 = .{ vx, vy, vz } };
    }

    pub fn initZero() Vec3u32 {
        return Vec3u32.init(0, 0, 0);
    }

    pub fn x(self: Vec3u32) u32 {
        return self.v3u32[0];
    }

    pub fn y(self: Vec3u32) u32 {
        return self.v3u32[1];
    }

    pub fn z(self: Vec3u32) u32 {
        return self.v3u32[2];
    }
};

pub const Vec2f32 = struct {
    v2: Vec2_f32,

    pub fn init(vx: f32, vy: f32) Vec2f32 {
        return Vec2f32{ .v2 = .{ vx, vy } };
    }

    pub fn initZero() Vec2f32 {
        return Vec2f32.init(0.0, 0.0);
    }

    pub fn x(self: Vec2f32) f32 {
        return self.v2[0];
    }

    pub fn y(self: Vec2f32) f32 {
        return self.v2[1];
    }

    pub fn add(self: Vec2f32, other: Vec2f32) Vec2f32 {
        return Vec2f32{ .v2 = self.v2 + other.v2 };
    }

    pub fn sub(self: Vec2f32, other: Vec2f32) Vec2f32 {
        return Vec2f32{ .v2 = self.v2 - other.v2 };
    }

    pub fn mul(self: Vec2f32, other: Vec2f32) Vec2f32 {
        return Vec2f32{ .v2 = self.v2 * other.v2 };
    }

    pub fn div(self: Vec2f32, other: Vec2f32) Vec2f32 {
        return Vec2f32{ .v2 = self.v2 / other.v2 };
    }

    pub fn addScalar(self: Vec2f32, scalar: f32) Vec2f32 {
        const scalar_vec = @as(Vec2_f32, @splat(scalar));
        return Vec2f32{ .v2 = self.v2 + scalar_vec };
    }

    pub fn subScalar(self: Vec2f32, scalar: f32) Vec2f32 {
        const scalar_vec = @as(Vec2_f32, @splat(scalar));
        return Vec2f32{ .v2 = self.v2 - scalar_vec };
    }

    pub fn mulScalar(self: Vec2f32, scalar: f32) Vec2f32 {
        const scalar_vec = @as(Vec2_f32, @splat(scalar));
        return Vec2f32{ .v2 = self.v2 * scalar_vec };
    }

    pub fn divScalar(self: Vec2f32, scalar: f32) Vec2f32 {
        const scalar_vec = @as(Vec2_f32, @splat(scalar));
        return Vec2f32{ .v2 = self.v2 / scalar_vec };
    }

    pub fn dot(self: Vec2f32, other: Vec2f32) f32 {
        // @reduce is a builtin function that reduces a vector using the specified operation
        return @reduce(.Add, self.v2 * other.v2);
    }

    pub fn cross(self: Vec2f32, other: Vec2f32) f32 {
        return self.x() * other.y() - self.y() * other.x();
    }

    pub fn length(self: Vec2f32) f32 {
        return @sqrt(self.dot(self));
    }

    pub fn normalize(self: Vec2f32) Vec2f32 {
        const len = self.length();
        if (len == 0) {
            return self;
        }

        const norm_vec = self.v2 / @as(Vec2_f32, @splat(len));
        return Vec2f32{ .v2 = norm_vec };
    }

    pub fn angle(self: Vec2f32, other: Vec2f32) f32 {
        const d = self.dot(other);
        const len = self.length() * other.length();
        if (len == 0) {
            return 0;
        }
        return utils.toDeg(math.acos(d / len));
    }

    pub fn rotateOverX(self: Vec2f32, angle_degrees: f32) Vec2f32 {
        const angle_rad = utils.toRad(angle_degrees);
        const cos = @cos(angle_rad);
        const sin = @sin(angle_rad);
        return Vec2f32.init(self.x(), self.y() * cos - self.x() * sin);
    }

    pub fn rotateOverY(self: Vec2f32, angle_degrees: f32) Vec2f32 {
        const angle_rad = utils.toRad(angle_degrees);
        const cos = @cos(angle_rad);
        const sin = @sin(angle_rad);
        return Vec2f32.init(self.x() * cos - self.y() * sin, self.y());
    }
};

pub const Vec3f32 = struct {
    v3: Vec3_f32,

    pub fn init(vx: f32, vy: f32, vz: f32) Vec3f32 {
        return Vec3f32{ .v3 = .{ vx, vy, vz } };
    }

    pub fn initZero() Vec3f32 {
        return Vec3f32.init(0.0, 0.0, 0.0);
    }

    pub fn x(self: Vec3f32) f32 {
        return self.v3[0];
    }

    pub fn y(self: Vec3f32) f32 {
        return self.v3[1];
    }

    pub fn z(self: Vec3f32) f32 {
        return self.v3[2];
    }

    pub fn add(self: Vec3f32, other: Vec3f32) Vec3f32 {
        return Vec3f32{ .v3 = self.v3 + other.v3 };
    }

    pub fn sub(self: Vec3f32, other: Vec3f32) Vec3f32 {
        return Vec3f32{ .v3 = self.v3 - other.v3 };
    }

    pub fn mul(self: Vec3f32, other: Vec3f32) Vec3f32 {
        return Vec3f32{ .v3 = self.v3 * other.v3 };
    }

    pub fn div(self: Vec3f32, other: Vec3f32) Vec3f32 {
        return Vec3f32{ .v3 = self.v3 / other.v3 };
    }

    pub fn addScalar(self: Vec3f32, scalar: f32) Vec3f32 {
        const scalar_vec = @as(Vec3_f32, @splat(scalar));
        return Vec3f32{ .v3 = self.v3 + scalar_vec };
    }

    pub fn subScalar(self: Vec3f32, scalar: f32) Vec3f32 {
        const scalar_vec = @as(Vec3_f32, @splat(scalar));
        return Vec3f32{ .v3 = self.v3 - scalar_vec };
    }

    pub fn mulScalar(self: Vec3f32, scalar: f32) Vec3f32 {
        const scalar_vec = @as(Vec3_f32, @splat(scalar));
        return Vec3f32{ .v3 = self.v3 * scalar_vec };
    }

    pub fn divScalar(self: Vec3f32, scalar: f32) Vec3f32 {
        const scalar_vec = @as(Vec3_f32, @splat(scalar));
        return Vec3f32{ .v3 = self.v3 / scalar_vec };
    }

    pub fn dot(self: Vec3f32, other: Vec3f32) f32 {
        return @reduce(.Add, self.v3 * other.v3);
    }

    pub fn cross(self: Vec3f32, other: Vec3f32) Vec3f32 {
        return Vec3f32.init(self.y() * other.z() - self.z() * other.y(), self.z() * other.x() - self.x() * other.z(), self.x() * other.y() - self.y() * other.x());
    }

    pub fn length(self: Vec3f32) f32 {
        return @sqrt(self.dot(self));
    }

    pub fn normalize(self: Vec3f32) Vec3f32 {
        const len = self.length();
        if (len == 0) {
            return self;
        }

        const norm_vec = self.v3 / @as(Vec3_f32, @splat(len));
        return Vec3f32{ .v3 = norm_vec };
    }

    pub fn angle(self: Vec3f32, other: Vec3f32) f32 {
        const d = self.dot(other);
        const len = self.length() * other.length();
        if (len == 0) {
            return 0;
        }
        return utils.toDeg(math.acos(d / len));
    }

    pub fn rotateOverX(self: Vec3f32, rot_angle: f32) Vec3f32 {
        const cos = @cos(rot_angle);
        const sin = @sin(rot_angle);

        const _new_x = self.x();
        const _new_y = self.y() * cos - self.z() * sin;
        const _new_z = self.y() * sin + self.z() * cos;

        return Vec3f32.init(_new_x, _new_y, _new_z);
    }

    pub fn rotateOverY(self: Vec3f32, rot_angle: f32) Vec3f32 {
        const cos = @cos(rot_angle);
        const sin = @sin(rot_angle);

        const _new_x = self.x() * cos - self.z() * sin;
        const _new_y = self.y();
        const _new_z = self.x() * sin + self.z() * cos;

        return Vec3f32.init(_new_x, _new_y, _new_z);
    }

    pub fn rotateOverZ(self: Vec3f32, rot_angle: f32) Vec3f32 {
        const cos = @cos(rot_angle);
        const sin = @sin(rot_angle);

        const _new_x = self.x() * cos - self.y() * sin;
        const _new_y = self.x() * sin + self.y() * cos;
        const _new_z = self.z();

        return Vec3f32.init(_new_x, _new_y, _new_z);
    }

    pub fn isZero(self: Vec3f32) bool {
        return eql(self, Vec3f32.zero());
    }

    pub fn eql(self: Vec3f32, other: Vec3f32) bool {
        return self.x() == other.x() and self.y() == other.y() and self.z() == other.z();
    }

    pub fn zero() Vec3f32 {
        return Vec3f32.init(0.0, 0.0, 0.0);
    }
};
