package main

import "app"
import "core:fmt"
import "core:time"
import "core:mem"
import "core:thread"

main :: proc() {
	start_led()
}

start_led :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	defer mem.tracking_allocator_destroy(&track)
	context.allocator = mem.tracking_allocator(&track)

	t := app.start()
	counter := 0
	for ;!thread.is_done(t); {
        // Feed commands
        time.sleep(100 * time.Millisecond)
		if counter < 5 {
			app.delete_image(123)
		}
		counter += 1
    }
    thread.destroy(t)

    // TODO: remove for prod
	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %m\n", leak.location, leak.size)
	}
	for bad_free in track.bad_free_array {
		fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
	}
}