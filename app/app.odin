package app

import "commands"
import "core:fmt"
import "core:strings"
import "entities"
import rl "vendor:raylib"

import glm "core:math/linalg/glsl"
import "core:time"
import gl "vendor:OpenGL"

import "../ffmpeg/avcodec"
import "../ffmpeg/avformat"
import "../ffmpeg/avutil"
import "../ffmpeg/swscale"
import "../ffmpeg/types"

ASSETS_DIR :: `assets/`

VideofileContext :: struct {
	fname:          cstring,
	format_ctx:     ^types.Format_Context,
	codec_ctx:      ^types.Codec_Context,
	codec:          ^types.Codec,
	codec_params:   ^types.Codec_Parameters,
	vid_stream_idx: i32,
}

Window :: struct {
	name:          cstring,
	width:         i32,
	height:        i32,
	fps:           i32,
	control_flags: rl.ConfigFlags,
}

AppState :: struct {
	current_frame: ^types.Frame,
	instances:     [dynamic]entities.Instance,
}

start_presenter :: proc(command_queue: ^commands.CommandQueue) {
	state: AppState

	WINDOW_WIDTH :: 854
	WINDOW_HEIGHT :: 480

	window := Window{"Game Of Life", 1024, 1024, 60, rl.ConfigFlags{.WINDOW_RESIZABLE}}

	rl.InitWindow(window.width, window.height, window.name)
	rl.SetWindowState(window.control_flags)
	rl.SetTargetFPS(window.fps)

	for !rl.WindowShouldClose() {
		process_commands(command_queue, &state)
		update(&state)
		rl.BeginDrawing()
		rl.ClearBackground(rl.PINK)
		render(&state)
		rl.EndDrawing()
	}
}

@(private = "file")
update :: proc(state: ^AppState) {
	for instance, index in state.instances {
		// TODO: run animations
	}
}

@(private = "file")
render :: proc(state: ^AppState) {
	for instance, index in state.instances {
		#partial switch entity in instance.entity {
		case entities.ImageEntity:
			rl.DrawTextureEx(entity.texture, instance.position, instance.rotation, instance.scale, rl.WHITE);
		}
	}
}

@(private = "file")
process_commands :: proc(command_queue: ^commands.CommandQueue, state: ^AppState) {
	comm, ok := commands.dequeue(command_queue)
	if ok {
		fmt.printfln("PROCESSING COMMAND: ", comm)
		#partial switch _ in comm {

		case commands.CreateImage:
			comm := comm.(commands.CreateImage)
			on_create_image(&comm, state)

		case commands.DeleteImage:
			comm := comm.(commands.DeleteImage)
			on_delete_image(&comm, state)
	
		case commands.Move:
			comm := comm.(commands.Move)
			on_move(&comm, state)

		}	
		// TODO: free command?
	}
}

on_create_image :: proc(c: ^commands.CreateImage, state: ^AppState) {
	image := rl.LoadImage(strings.clone_to_cstring(c.resource))
    texture := rl.LoadTextureFromImage(image)
	defer rl.UnloadImage(image)

	append(
		&state.instances,
		entities.Instance {
			id = c.id,
			entity = entities.ImageEntity{
				texture = texture,
				tint = rl.WHITE,
			},
			position = c.pos,
			scale = c.size,
			rotation = 0.0,
			status = entities.Status.LOADED,
			z = 0,
		},
	)
}

on_move :: proc(c: ^commands.Move, state: ^AppState) {
	instance := find_instancy_by_id(state, c.id)
	if instance != nil {
		instance.position = c.pos
	}
}

on_delete_image :: proc(c: ^commands.DeleteImage, state: ^AppState) {
	fmt.printfln("Delete Image command. ID=%d", c.id)
}


find_instancy_by_id :: proc(state: ^AppState, id: i32) -> ^entities.Instance {
	for instance, idx in state.instances {
		if instance.id == id {
			return &state.instances[idx]
		}
	}
	return nil
}