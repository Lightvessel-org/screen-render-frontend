package main

import "app"
import "core:fmt"
import "core:time"
import "core:mem"
import "core:thread"

/**
* SOLO PARA TESTEO
* Este backend por terminal reemplaza al backend de visual basic
**/
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

	app.create_image("golden_ball.png", 0.0, 0.0, 0.5)

	for ;!thread.is_done(t); {
        // Feed commands
        time.sleep(100 * time.Millisecond)
    }
	
    thread.destroy(t)

	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %m\n", leak.location, leak.size)
	}
	for bad_free in track.bad_free_array {
		fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
	}
}