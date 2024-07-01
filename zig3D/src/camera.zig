const math = @import("std").math;
const vector = @import("vector.zig");
const ColorBuffer = @import("color_buffer.zig").ColorBuffer;
const std = @import("std");
const utils = @import("utils.zig");

pub const Camera = struct {
    position: vector.Vec3f,
    target_position: vector.Vec3f,
    screen_width: usize,
    screen_height: usize,
    fov_factor: f32,
    near_plane: f32,
    far_plane: f32,
    speed: f32,

    pub fn init(position: vector.Vec3f, screen_width: usize, screen_height: usize, fov: f32, near_plane: f32, far_plane: f32, movement_speed: f32) Camera {
        return Camera{
            .position = position,
            .target_position = vector.Vec3f.init(0.0, 0.0, 0.0),
            .screen_width = screen_width,
            .screen_height = screen_height,
            .fov_factor = fov,
            .near_plane = near_plane,
            .far_plane = far_plane,
            .speed = movement_speed,
        };
    }

    pub fn getScreenWidth(self: *Camera) f32 {
        return @floatFromInt(self.screen_width);
    }

    pub fn getScreenHeight(self: *Camera) f32 {
        return @floatFromInt(self.screen_height);
    }

    pub fn getHalfScreenWidth(self: *Camera) f32 {
        const a = utils.castU32xF32(self.screen_width);
        return a / 2.0;
    }

    pub fn getHalfScreenHeight(self: *Camera) f32 {
        const a = utils.castU32xF32(self.screen_height);
        return a / 2.0;
    }

    pub fn updatePosition(self: *Camera, delta_time: f32) void {
        if (self.target_position.isZero()) {
            return;
        }
        const target = self.target_position;
        const movement = target.mulScalar(self.speed).mulScalar(delta_time);
        self.position = self.position.add(movement);
        // reset the target position
        self.target_position = vector.Vec3f.init(0.0, 0.0, 0.0);
    }

    pub fn moveForward(self: *Camera, units: f32) void {
        self.target_position = vector.Vec3f.init(0.0, 0.0, units);
    }

    pub fn moveBackward(self: *Camera, units: f32) void {
        self.target_position = vector.Vec3f.init(0.0, 0.0, units);
    }

    pub fn moveLeft(self: *Camera, units: f32) void {
        self.target_position = vector.Vec3f.init(units, 0.0, 0.0);
    }

    pub fn moveRight(self: *Camera, units: f32) void {
        self.target_position = vector.Vec3f.init(units, 0.0, 0.0);
    }

    pub fn moveUp(self: *Camera, units: f32) void {
        self.target_position = vector.Vec3f.init(0.0, units, 0.0);
    }

    pub fn moveDown(self: *Camera, units: f32) void {
        self.target_position = vector.Vec3f.init(0.0, units, 0.0);
    }

    pub fn setTargetPosition(self: *Camera, target: vector.Vec3f) void {
        self.target_position = target;
    }

    pub fn getCameraPosition(self: *Camera) vector.Vec3f {
        return self.position;
    }

    pub fn orthographicProjection(self: *Camera, scale_factor: u32, point: vector.Vec3f) vector.Vec2f {
        const scale_factor_f32 = utils.castU32xF32(scale_factor);
        // shift point to positive space
        const x = (point.x() - self.min.x()) * scale_factor_f32;
        const y = (point.y() - self.min.y()) * scale_factor_f32;
        return vector.Vec2f.init(x, y);
    }

    pub fn perspectiveProjection(self: *Camera, point: vector.Vec3f) ?vector.Vec2f {

        // transform the point by subtracting the camera position
        const translated_point = point.sub(self.position);

        // cut off points that are behind the camera or too far away
        if (translated_point.z() < self.near_plane or translated_point.z() > self.far_plane) {
            return null;
        }

        //const x = (self.fov_factor * point.x()) / point.z();
        //const y = (self.fov_factor * point.y()) / point.z();
        const x = (self.fov_factor * translated_point.x()) / translated_point.z();
        const y = (self.fov_factor * translated_point.y()) / translated_point.z();
        return vector.Vec2f.init(x, y);
    }
};
