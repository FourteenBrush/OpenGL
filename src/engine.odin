package engine

import "core:c"
import "core:fmt"
import "core:runtime"

import "vendor:glfw"
import gl "vendor:OpenGL"

CONTEXT_VERSION_MAJOR :: 4
CONTEXT_VERSION_MINOR :: 3

WINDOW_TITLE :: "Demo"
WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600

Engine :: struct {
    window: glfw.WindowHandle,
    renderer: Renderer,
}

engine_startup :: proc() -> (engine: Engine, ok: bool) {
    if !glfw.Init() {
        fmt.eprintln("failed to initialize glfw")
        return engine, false
    }

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, CONTEXT_VERSION_MAJOR)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, CONTEXT_VERSION_MINOR)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
when ODIN_OS == .Darwin {
    glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, gl.TRUE)
}

    using engine
    window = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE, nil, nil)
    if window == nil {
        fmt.eprintln("failed to create glfw window")
        return engine, false
    }

    glfw.MakeContextCurrent(window)
    gl.load_up_to(CONTEXT_VERSION_MAJOR, CONTEXT_VERSION_MINOR, glfw.gl_set_proc_address)

    gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
    gl.DebugMessageCallback(debug_message_callback, nil)

    renderer = renderer_new() or_return
    return engine, true
}

engine_destroy :: proc(using engine: ^Engine) {
    renderer_destroy(&renderer)
    glfw.Terminate()
}

engine_run :: proc(using engine: Engine) {
    for !glfw.WindowShouldClose(window) {
        process_input(engine)
        render(renderer)

        glfw.SwapBuffers(window)
        glfw.PollEvents()
    } 
}

@private
process_input :: proc(using engine: Engine) {
    if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
        glfw.SetWindowShouldClose(window, true)
    }
}

@private
framebuffer_size_callback :: proc "c" (_window: glfw.WindowHandle, width, height: c.int) {
    gl.Viewport(0, 0, width, height)
}

@private
debug_message_callback :: proc "c" (source, type, id, severity: u32, length: i32, message: cstring, userParam: rawptr) {
    context = runtime.default_context()
    fmt.eprintln(message)
}

