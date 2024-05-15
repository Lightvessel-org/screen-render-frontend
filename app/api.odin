package app

import "core:thread"
import "core:fmt"
import "core:time"
import "core:sync"
import "core:mem"
import "core:runtime"

import "commands"

GlobalState :: struct {
    command_queue: commands.CommandQueue
}

global : GlobalState

@export
run_precioled :: proc "c" () -> i32 {
    context = runtime.default_context()
    track: mem.Tracking_Allocator
    fmt.println("Initializing tracking allocator")
	mem.tracking_allocator_init(&track, context.allocator)
	defer mem.tracking_allocator_destroy(&track)
    fmt.println("Configured debug tracking allocator")
	context.allocator = mem.tracking_allocator(&track)
    fmt.println("starting frontend...")
    return start()
}

@export
version ::proc "c" () -> i32 {
    context = runtime.default_context();
    return 100
}

start :: proc() -> i32 {
    global.command_queue = commands.create_queue()
    defer commands.delete_queue(&global.command_queue)
    fmt.println("Command Queue created.")
    render_thread := thread.create(run_render_thread)
    fmt.println("Preparing render thread.")
    render_thread.user_args[0] = &global.command_queue
    fmt.println("Starting render thread.")
    thread.start(render_thread)

    time.sleep(100 * time.Millisecond)
    fmt.println("Starting devtools thread.")
    devtools_thread := thread.create(run_devtools_thread)
    devtools_thread.user_args[0] = &global.command_queue
    thread.start(devtools_thread)

    for ;!thread.is_done(render_thread); {
        // Feed commands
        time.sleep(100 * time.Millisecond)
    }
    thread.destroy(devtools_thread)
    thread.destroy(render_thread)

    return 0
}

@(private)
run_render_thread :: proc(t: ^thread.Thread) {
    comms := (^commands.CommandQueue)(&t.user_args[0])^
    start_presenter(&comms)
}

@(private)
run_devtools_thread :: proc(t: ^thread.Thread) {
    comms := (^commands.CommandQueue)(&t.user_args[0])^
    start_devtools(&comms)
}