package main

import "app"
import thread "core:thread"
import fmt "core:fmt"
import time "core:time"

main :: proc() {
    render_thread := thread.create(app.run)

    fmt.println("\n# Starting GUI")
    thread.start(render_thread)

    for ;!thread.is_done(render_thread); {
        // TODO: Define polling of commands here
        time.sleep(10 * time.Millisecond)
    }
}