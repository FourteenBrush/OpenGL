package engine

import "core:os"
import "core:fmt"
import "core:strings"

import gl "vendor:OpenGL"

// FIXME: type alias for u32?
ShaderProgram :: struct {
    program_id: u32,
}

load_program :: proc(
    vertex_path, fragment_path: cstring, 
    allocator := context.temp_allocator,
) -> (
    program: ShaderProgram,
    ok: bool,
) {
    vertex_shader := load_shader(gl.VERTEX_SHADER, vertex_path) or_return
    fragment_shader := load_shader(gl.FRAGMENT_SHADER, fragment_path) or_return
    defer gl.DeleteShader(vertex_shader)
    defer gl.DeleteShader(fragment_shader)

    program_id := gl.CreateProgram()
    gl.AttachShader(program_id, vertex_shader)
    gl.AttachShader(program_id, fragment_shader)
    gl.LinkProgram(program_id)

    linkage_success: i32
    gl.GetProgramiv(program_id, gl.LINK_STATUS, &linkage_success)
    if linkage_success == 0 {
        info_log: [512]u8
        gl.GetProgramInfoLog(program_id, len(info_log), nil, &info_log[0])
        fmt.eprintln("failed to link program program:", cstring(&info_log[0]))
        return program, false
    }

    program.program_id = program_id
    return program, true
}

@private
load_shader :: proc(type: u32, path: cstring, allocator := context.temp_allocator) -> (shader: u32, ok: bool) {
    id := gl.CreateShader(type)

    spath := strings.string_from_ptr(transmute(^byte) path, len(path))
    data, iok := os.read_entire_file(spath)
    if !iok {
        fmt.eprintln("failed to load shader: no such file", path)
        return shader, false
    }

    defer delete(data)
    strdata := cstring(&data[0])
    gl.ShaderSource(id, 1, &strdata, nil)
    gl.CompileShader(id)

    compilation_success: i32
    gl.GetShaderiv(id, gl.COMPILE_STATUS, &compilation_success)

    if compilation_success == 0 {
        info_log: [512]u8
        gl.GetShaderInfoLog(id, len(info_log), nil, &info_log[0])
        fmt.eprintf("failed to compile shader %v: %v\n", path, cstring(&info_log[0]))
        return shader, false
    }

    return id, true
}

program_destroy :: proc(using program: ShaderProgram) {
    gl.DeleteProgram(program_id)
}

program_use :: proc(using program: ShaderProgram) {
    gl.UseProgram(program_id)
}

program_set_bool :: proc(using program: ShaderProgram, name: cstring, b: bool) {
    loc := get_uniform_loc(program_id, name)
    gl.Uniform1i(loc, i32(b))
}

program_set_int :: proc(using program: ShaderProgram, name: cstring, i: i32) {
    loc := get_uniform_loc(program_id, name)
    gl.Uniform1i(loc, i)
}

program_set_float :: proc(using program: ShaderProgram, name: cstring, f: f32) {
    loc := get_uniform_loc(program_id, name)
    gl.Uniform1f(loc, f)
}

@private
get_uniform_loc :: #force_inline proc(program: u32, name: cstring) -> i32 {
    loc := gl.GetUniformLocation(program, name)
    fmt.assertf(loc != -1, "uniform %v does not exist or is optimized away\n", name)
    return loc
}
