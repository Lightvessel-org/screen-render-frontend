package app

import "core:fmt"
import SDL "vendor:sdl2"
import "commands"

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
    current_frame:^types.Frame
}

start_presenter :: proc(t: ^commands.CommandQueue) {
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
				// NOTE(bill): "direct3d" seems to not work correctly
				if info.name == "opengl" {
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

    vid_ctx:VideofileContext

    open_video_file(&vid_ctx, ASSETS_DIR + `countdown_raw.avi`)
    

    state.current_frame = avutil.frame_alloc()
    finished := false
    frame_rate := avutil.q2d(vid_ctx.format_ctx.streams[vid_ctx.vid_stream_idx].avg_frame_rate)
    curr_time := time.now()
    elapsed_duration:f64 = 0.0
    video_duration:f32 = f32(vid_ctx.format_ctx.duration) / 1_000_000
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

        frame_duration := time.duration_seconds(time.diff(curr_time,time.now()))

        fmt.println("Elapsed duration: ", t, "                 ", video_duration)
        if(t > video_duration) {
            finished = true
        }
        if !finished && frame_duration >= 1/frame_rate{
            curr_time = time.now()
            finished = grab_video_frame(&vid_ctx, &state)
            if(!finished) {
                data := state.current_frame.data[0]
                render_sdl_texture(state.current_frame, renderer)
                SDL.RenderPresent(renderer)
            } else {
                fmt.println("Video Finished")
            }
        } else {
            SDL.Delay(10) // If there is nothing to process, we should add a small delay in order to prevent 
        }
	}
}