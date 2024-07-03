///! Camera module
///!
///! Config:
///!     - position: Vec3f32 (camera position)
///!     - screen_width: u32 (screen width)
///!     - screen_height: u32 (screen height)
///!     - fov_factor: f32 (field of view factor)
///!     - near_plane: f32 (near plane)
///!     - far_plane: f32 (far plane)
///!     - speed: f32 (camera speed)
///!
const math = @import("std").math;
const vector = @import("vector.zig");
const Vec3f32 = vector.Vec3f32;
const Vec2f32 = vector.Vec2f32;
const ColorBuffer = @import("color_buffer.zig").ColorBuffer;
const std = @import("std");
const utils = @import("utils.zig");

pub const Camera = struct {
    position: Vec3f32,
    target_position: Vec3f32,
    screen_width: u32,
    screen_height: u32,
    fov: f32,
    near_plane: f32,
    far_plane: f32,
    speed: f32,

    pub const Config = struct {
        position: Vec3f32,
        screen_width: u32,
        screen_height: u32,
        fov_factor: f32,
        near_plane: f32,
        far_plane: f32,
        speed: f32,
    };

    pub fn init(config: Config) Camera {
        return Camera{
            .position = config.position,
            .target_position = Vec3f32.zero(),
            .screen_width = config.screen_width,
            .screen_height = config.screen_height,
            .fov = config.fov_factor,
            .near_plane = config.near_plane,
            .far_plane = config.far_plane,
            .speed = config.speed,
        };
    }

    pub fn getScreenWidth(self: *Camera) f32 {
        return utils.castU32xF32(self.screen_width);
    }

    pub fn getScreenHeight(self: *Camera) f32 {
        return utils.castU32xF32(self.screen_height);
    }

    pub fn updatePosition(self: *Camera, delta_time: f32) void {
        if (self.target_position.isZero()) {
            return;
        }
        const movement = self.target_position.mulScalar(self.speed).mulScalar(delta_time);
        self.position = self.position.add(movement);
        self.target_position = Vec3f32.zero();
    }

    pub fn setTargetPosition(self: *Camera, target: Vec3f32) void {
        self.target_position = target;
    }

    pub fn getCameraPosition(self: *Camera) Vec3f32 {
        return self.position;
    }

    pub fn orthographicProjection(self: *Camera, scale_factor: u32, point: Vec3f32) Vec2f32 {
        const scale_factor_f32 = utils.castU32xF32(scale_factor);
        const x = (point.x() - self.min.x()) * scale_factor_f32;
        const y = (point.y() - self.min.y()) * scale_factor_f32;
        return Vec2f32.init(x, y);
    }

    pub fn perspectiveProjection(self: *Camera, point: Vec3f32) ?Vec2f32 {
        const translated_point = point.sub(self.position);
        if (translated_point.z() < self.near_plane or translated_point.z() > self.far_plane) {
            return null;
        }

        const x = (self.fov * translated_point.x()) / translated_point.z();
        const y = (self.fov * translated_point.y()) / translated_point.z();
        return Vec2f32.init(x, y);
    }
};
