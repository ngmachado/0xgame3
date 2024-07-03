const math = @import("std").math;
pub fn castU32xF32(a: u32) f32 {
    return @as(f32, @floatFromInt(a));
}

pub fn castF32U32(a: f32) u32 {
    return @as(u32, @intFromFloat(a));
}

pub fn toRad(angle_degrees: f32) f32 {
    return angle_degrees * math.pi / 180.0;
}

pub fn toDeg(angle_radians: f32) f32 {
    return angle_radians * 180.0 / math.pi;
}
