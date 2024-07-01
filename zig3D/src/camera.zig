const math = @import("std").math;
const vector = @import("vector.zig");
const ColorBuffer = @import("color_buffer.zig").ColorBuffer;
const std = @import("std");
const utils = @import("utils.zig");

pub const Camera = struct {
    position: vector.Vec3f,
    orientation: vector.Vec3f,
    screen_width: usize,
    screen_height: usize,
    fov_factor: f32,
    near_plane: f32,
    far_plane: f32,
    speed: f32,

    pub const Config = struct {
        position: vector.Vec3f,
        orientation: vector.Vec3f,
        screen_width: usize,
        screen_height: usize,
        fov_factor: f32,
        near_plane: f32,
        far_plane: f32,
        speed: f32,
    };

    pub fn init(config: Config) Camera {
        return Camera{
            .position = config.position,
            .orientation = config.orientation,
            .screen_width = config.screen_width,
            .screen_height = config.screen_height,
            .fov_factor = config.fov_factor,
            .near_plane = config.near_plane,
            .far_plane = config.far_plane,
            .speed = config.speed,
        };
    }

    pub fn getScreenWidth(self: *Camera) f32 {
        return utils.castUsizeToF32(self.screen_width);
    }

    pub fn getScreenHeight(self: *Camera) f32 {
        return utils.castUsizeToF32(self.screen_height);
    }

    pub fn getHalfScreenWidth(self: *Camera) f32 {
        return utils.castUsizeToF32(self.screen_width) / 2.0;
    }

    pub fn getHalfScreenHeight(self: *Camera) f32 {
        return utils.castUsizeToF32(self.screen_height) / 2.0;
    }

    pub fn updatePosition(self: *Camera, delta_time: f32) void {
        if (self.target_position.isZero()) {
            return;
        }
        const movement = self.target_position.mulScalar(self.speed).mulScalar(delta_time);
        self.position = self.position.add(movement);
        self.resetTargetPosition();
    }

    pub fn move(self: *Camera, direction: vector.Vec3f, delta_time: f32) void {
        const forward = self.getForwardVector().mulScalar(direction.z);
        const right = self.getRightVector().mulScalar(direction.x);
        const up = self.getUpVector().mulScalar(direction.y);
        const left = right.negate();
        const down = up.negate();

        const movement = forward.add(right).add(up).add(left).add(down).mulScalar(self.speed).mulScalar(delta_time);
        self.position = self.position.add(movement);
    }

    pub fn moveForward(self: *Camera, units: f32, delta_time: f32) void {
        self.move(vector.Vec3f.init(0.0, 0.0, units), delta_time);
    }

    pub fn moveBackward(self: *Camera, units: f32, delta_time: f32) void {
        self.move(vector.Vec3f.init(0.0, 0.0, -units), delta_time);
    }

    pub fn moveLeft(self: *Camera, units: f32, delta_time: f32) void {
        self.move(vector.Vec3f.init(-units, 0.0, 0.0), delta_time);
    }

    pub fn moveRight(self: *Camera, units: f32, delta_time: f32) void {
        self.move(vector.Vec3f.init(units, 0.0, 0.0), delta_time);
    }

    pub fn moveUp(self: *Camera, units: f32, delta_time: f32) void {
        self.move(vector.Vec3f.init(0.0, units, 0.0), delta_time);
    }

    pub fn moveDown(self: *Camera, units: f32, delta_time: f32) void {
        self.move(vector.Vec3f.init(0.0, -units, 0.0), delta_time);
    }

    pub fn setTargetPosition(self: *Camera, target: vector.Vec3f) void {
        self.target_position = target;
    }

    pub fn getCameraPosition(self: *Camera) vector.Vec3f {
        return self.position;
    }

    pub fn orthographicProjection(self: *Camera, scale_factor: u32, point: vector.Vec3f) vector.Vec2f {
        const scale_factor_f32 = utils.castU32xF32(scale_factor);
        const x = (point.x() - self.min.x()) * scale_factor_f32;
        const y = (point.y() - self.min.y()) * scale_factor_f32;
        return vector.Vec2f.init(x, y);
    }

    pub const ProjectionResult = struct {
        success: bool,
        point: vector.Vec2f,
    };

    pub fn perspectiveProjection(self: *Camera, point: vector.Vec3f) ProjectionResult {
        const translated_point = point.sub(self.position);
        if (translated_point.z() < self.near_plane or translated_point.z() > self.far_plane) {
            return ProjectionResult{ .success = false, .point = vector.Vec2f.init(0, 0) };
        }
        const x = (self.fov_factor * translated_point.x()) / translated_point.z();
        const y = (self.fov_factor * translated_point.y()) / translated_point.z();
        return ProjectionResult{ .success = true, .point = vector.Vec2f.init(x, y) };
    }

    fn resetTargetPosition(self: *Camera) void {
        self.target_position = vector.Vec3f.init(0.0, 0.0, 0.0);
    }

    fn getForwardVector(self: *Camera) vector.Vec3f {
        const yaw = self.orientation.x;
        const pitch = self.orientation.y;
        return vector.Vec3f.init(math.cos(yaw) * math.cos(pitch), math.sin(pitch), math.sin(yaw) * math.cos(pitch));
    }

    fn getRightVector(self: *Camera) vector.Vec3f {
        const yaw = self.orientation.x;
        return vector.Vec3f.init(math.sin(yaw - math.pi / 2.0), 0.0, math.cos(yaw - math.pi / 2.0));
    }

    fn getUpVector(_: *Camera) vector.Vec3f {
        return vector.Vec3f.init(0.0, 1.0, 0.0);
    }
};
