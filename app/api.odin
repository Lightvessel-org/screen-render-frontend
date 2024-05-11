package app

import thread "core:thread"
import fmt "core:fmt"
import time "core:time"
import "core:sync"
import "commands"

start :: proc() {

    command_queue := commands.create_queue()
    defer commands.delete_queue(&command_queue)

    render_thread := thread.create(run_render_thread)
    render_thread.user_args[0] = &command_queue
    thread.start(render_thread)

    time.sleep(100 * time.Millisecond)
    
    devtools_thread := thread.create(run_devtools_thread)
    devtools_thread.user_args[0] = &command_queue
    thread.start(devtools_thread)

    for ;!thread.is_done(render_thread); {
        // Feed commands
        time.sleep(100 * time.Millisecond)
    }
    thread.destroy(devtools_thread)
    thread.destroy(render_thread)
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