package app

import "core:fmt"
import SDL "vendor:sdl2"
import "commands"
import "entities"

import glm "core:math/linalg/glsl"
import "core:time"
import gl "vendor:OpenGL"

import "../ffmpeg/avcodec"
import "../ffmpeg/avformat"
import "../ffmpeg/swscale"
import "../ffmpeg/types"
import "../ffmpeg/avutil"

ASSETS_DIR :: `assets/`

VideofileContext :: struct{
    fname:cstring,
    format_ctx:^types.Format_Context,
    codec_ctx:^types.Codec_Context,
    codec:^types.Codec,
    codec_params:^types.Codec_Parameters,
    vid_stream_idx:i32,
}

AppState :: struct{
    current_frame:^types.Frame,
    images: [dynamic]entities.ImageEntity,
}

start_presenter :: proc(command_queue: ^commands.CommandQueue) {
    state:AppState

	WINDOW_WIDTH  :: 854
	WINDOW_HEIGHT :: 480

	SDL.Init({.VIDEO})
	defer SDL.Quit()

	window := SDL.CreateWindow("Odin SDL2 Demo", SDL.WINDOWPOS_UNDEFINED, SDL.WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, {.OPENGL})
	if window == nil {
		fmt.eprintln("Failed to create window")
		return
	}
	defer SDL.DestroyWindow(window)

    SDL.SetWindowBordered(window, false)

	// high precision timer
	start_tick := time.tick_now()

    backend_idx: i32 = -1
	if n := SDL.GetNumRenderDrivers(); n <= 0 {
		fmt.eprintln("No render drivers available")
		return
	} else {
		for i in 0..<n {
			info: SDL.RendererInfo
			if err := SDL.GetRenderDriverInfo(i, &info); err == 0 {
				if info.name == "direct3d" {
					backend_idx = i
					break
				}
			}
		}
	}

    renderer := SDL.CreateRenderer(window, backend_idx, {.ACCELERATED, .PRESENTVSYNC})
    if renderer == nil {
		fmt.eprintln("SDL.CreateRenderer:", SDL.GetError())
		return
	}
	defer SDL.DestroyRenderer(renderer)

	loop: for {
		duration := time.tick_since(start_tick)
		t := f32(time.duration_seconds(duration))

		// event polling
		event: SDL.Event
		for SDL.PollEvent(&event) {
			// #partial switch tells the compiler not to error if every case is not present
			#partial switch event.type {
			case .KEYDOWN:
				#partial switch event.key.keysym.sym {
				case .ESCAPE:
					// labelled control flow
					break loop
				}
			case .QUIT:
				// labelled control flow
				break loop
			}
		}

        comms, ok := commands.dequeue_all(command_queue)
        if ok {
            process_commands(comms, &state)
        }
        update(&state)

        SDL.RenderPresent(renderer)
	}
}

update :: proc(state:^AppState) {

}

process_commands :: proc(comms: []commands.LedCommand, state:^AppState) {
    if len(comms) > 0 {
        fmt.printfln("Processing Commands")
    }
    for c in comms {
        switch _ in c {
			case commands.DeleteImage:
				c := c.(commands.DeleteImage)
                on_delete_image(&c, state)
            case commands.CreateImage:
                c := c.(commands.CreateImage)
                on_create_image(&c, state)
        }
    }
}

on_create_image :: proc(c:^commands.CreateImage, state:^AppState) {
    fmt.printfln("Create Image command. ID=%d", c.id)
}

on_delete_image :: proc(c:^commands.DeleteImage, state:^AppState) {
    fmt.printfln("Delete Image command. ID=%d", c.id)
}