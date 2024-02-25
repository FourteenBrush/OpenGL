package engine

Vec3 :: distinct [3]f32
Color :: distinct [4]f32

VEC3_COMPONENTS :: 3

vec3 :: #force_inline proc(x, y, z: f32) -> Vec3 {
    return Vec3{x, y, z}
}
