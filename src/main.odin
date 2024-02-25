package engine

main :: proc() {
    engine, ok := engine_startup()
    if !ok do return

    defer engine_destroy(&engine)
    engine_run(engine)
}
