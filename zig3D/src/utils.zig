// castU32xF32

pub fn castU32xF32(a: u32) f32 {
    return @as(f32, @floatFromInt(a));
}
