package app

import "core:thread"
import "core:fmt"
import "core:time"
import "core:sync"
import "core:mem"
import "core:runtime"

import "commands"

GlobalState :: struct {
    id_counter: i32,
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
    start()
    return 0
}

next_id :: proc() -> i32 {
    global.id_counter += 1;
    return global.id_counter
}

@export
version ::proc "c" () -> i32 {
    context = runtime.default_context();
    return 100
}

counter :i32 = 0

@export
create_image ::proc "c" () -> i32 {
    context = runtime.default_context();
    fmt.println("Create Image called")
    counter += 1
    command := commands.CreateImage {
        id = counter
    }
    commands.enqueue(&global.command_queue, command)
    return 0
}

@export
delete_image ::proc "c" (id: i32) -> i32 {
    context = runtime.default_context();
    fmt.println("Delete Image called")
    command := commands.DeleteImage {
        id = id
    }
    commands.enqueue(&global.command_queue, command)
    return 0
}

start :: proc() -> ^thread.Thread {
    global.command_queue = commands.create_queue()
    fmt.println("Command Queue created.")
    render_thread := thread.create(run_render_thread)
    fmt.println("Preparing render thread.")
    render_thread.user_args[0] = &global.command_queue
    fmt.println("Starting render thread.")
    thread.start(render_thread)

    //time.sleep(100 * time.Millisecond)
    //fmt.println("Starting devtools thread.")
    //devtools_thread := thread.create(run_devtools_thread)
    //devtools_thread.user_args[0] = &global.command_queue
    //thread.start(devtools_thread)

    //defer thread.destroy(devtools_thread)
    //defer thread.destroy(render_thread)
    fmt.println("--------------------------------------------")
    return render_thread
}

@(private)
run_render_thread :: proc(t: ^thread.Thread) {
    comms := (^commands.CommandQueue)(&t.user_args[0])^
    start_presenter(&global.command_queue)
}

@(private)
run_devtools_thread :: proc(t: ^thread.Thread) {
    comms := (^commands.CommandQueue)(&t.user_args[0])^
    start_devtools(&global.command_queue)
}