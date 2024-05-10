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

    fmt.println("\n# Starting GUI")
    thread.start(render_thread)
    counter :u32 = 0
    for ;!thread.is_done(render_thread); {
        // Feed commands
        time.sleep(10 * time.Millisecond)
    }
}

@(private)
run_render_thread :: proc(t: ^thread.Thread) {
    comms := (^commands.CommandQueue)(&t.user_args[0])^
    start_gui(&comms)
}
