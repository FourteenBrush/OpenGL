package engine

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"

Renderer :: struct {
    shader_program: ShaderProgram,
    buffers: Buffers,
    vertices: [6 * 3]f32,
    clear_color: Color,
}

Buffers :: [BufferType]u32

BufferType :: enum {
    VBO, VAO, EBO,
}

renderer_new :: proc() -> (renderer: Renderer, ok: bool) {
    using renderer

    shader_program = load_program(
        "res/shaders/vertex.glsl",
        "res/shaders/fragment.glsl",
    ) or_return

    program_use(shader_program)
    program_set_float(shader_program, "uHorOffset", 0.3)

    gl.GenVertexArrays(1, &buffers[.VAO])
    gl.BindVertexArray(buffers[.VAO])

    gl.GenBuffers(1, &buffers[.VBO])
    gl.GenBuffers(1, &buffers[.EBO])

    vertices = {
        // positions     // colors
        0.5, -0.5, 0.0,  1.0, 0.0, 0.0,   // bottom right
       -0.5, -0.5, 0.0,  0.0, 1.0, 0.0,   // bottom let
        0.0,  0.5, 0.0,  0.0, 0.0, 1.0,   // top 
    }
    clear_color = Color {0.2, 0.3, 0.3, 1}

    gl.BindBuffer(gl.ARRAY_BUFFER, buffers[.VBO])
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices[0], gl.STATIC_DRAW)

    //   VERTEX 1   |   VERTEX 2   |
    // X Y Z  R G B | X Y Z  R G B |
    
    VERTEX_STRIDE :: 2 * size_of(Vec3)

    // position
    gl.VertexAttribPointer(0, VEC3_COMPONENTS, gl.FLOAT, gl.FALSE, VERTEX_STRIDE, 0)
    gl.EnableVertexAttribArray(0)
    
    // color
    gl.VertexAttribPointer(1, VEC3_COMPONENTS, gl.FLOAT, gl.FALSE, VERTEX_STRIDE, uintptr(size_of(Vec3)))
    gl.EnableVertexAttribArray(1)

    return renderer, true
}

renderer_destroy :: proc(using renderer: ^Renderer) {
    gl.DeleteBuffers(1, &buffers[.VBO])
    gl.DeleteVertexArrays(1, &buffers[.VAO])
    program_destroy(shader_program)
}

render :: proc(using renderer: Renderer) {
    gl.ClearColor(expand_values(clear_color))
    gl.Clear(gl.COLOR_BUFFER_BIT)

    //gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
    gl.DrawArrays(gl.TRIANGLES, 0, 3)
    //gl.DrawElements(gl.TRIANGLES, len(indices), gl.UNSIGNED_INT, nil)
}
