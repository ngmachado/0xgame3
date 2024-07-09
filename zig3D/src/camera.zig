const math = @import("std").math;
const vector = @import("vector.zig");
const Vec3f32 = vector.Vec3f32;
const Vec2f32 = vector.Vec2f32;
const Vec4f32 = vector.Vec4f32;
const std = @import("std");
const utils = @import("utils.zig");

pub const Camera = struct {
    position: Vec3f32,
    target_position: Vec3f32,
    screen_width: u32,
    screen_height: u32,
    aspect_ratio: f32,
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
            .aspect_ratio = utils.castU32xF32(config.screen_width) / utils.castU32xF32(config.screen_height),
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

    /// returns the perspective projection matrix for a left-handed coordinate system
    fn perspectiveProjectionMatrix(self: *Camera) [4][4]f32 {
        const aspect_ratio = self.getScreenWidth() / self.getScreenHeight();
        const fov_rad = math.degreesToRadians(self.fov);
        const f = 1.0 / math.tan(fov_rad / 2.0);
        const depth_range = self.far_plane - self.near_plane;

        return [4][4]f32{
            [_]f32{ f / aspect_ratio, 0, 0, 0 },
            [_]f32{ 0, f, 0, 0 },
            [_]f32{ 0, 0, (self.far_plane + self.near_plane) / depth_range, (2.0 * self.far_plane * self.near_plane) / depth_range },
            [_]f32{ 0, 0, 1, 0 },
        };
    }

    pub fn worldToView(self: *Camera, point: Vec3f32) Vec3f32 {
        return point.sub(self.position);
    }

    pub fn viewToClip(self: *Camera, point: Vec3f32) Vec4f32 {
        const proj_matrix = self.perspectiveProjectionMatrix();
        return Vec4f32.init(point.x() * proj_matrix[0][0], point.y() * proj_matrix[1][1], point.z() * proj_matrix[2][2] + proj_matrix[2][3], point.z());
    }

    pub fn clipToNDC(_: *Camera, clip_coords: Vec4f32) Vec3f32 {
        return Vec3f32.init(clip_coords.x() / clip_coords.w(), clip_coords.y() / clip_coords.w(), clip_coords.z() / clip_coords.w());
    }

    pub fn ndcToScreen(self: *Camera, ndc_coords: Vec3f32) Vec2f32 {
        const x = (ndc_coords.x() + 1.0) * 0.5 * self.getScreenWidth();
        const y = (1.0 - ndc_coords.y()) * 0.5 * self.getScreenHeight();
        return Vec2f32.init(x, y);
    }

    pub fn project(self: *Camera, point: Vec3f32) ?Vec2f32 {
        const view_coords = self.worldToView(point);
        const clip_coords = self.viewToClip(view_coords);
        const ndc_coords = self.clipToNDC(clip_coords);
        if (ndc_coords.z() < 0.0 or ndc_coords.z() > 1.0) {
            return null;
        }
        return self.ndcToScreen(ndc_coords);
    }
};
