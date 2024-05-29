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
	world:         entities.World,
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
		update(&state.world)
		rl.BeginDrawing()
		rl.ClearBackground(rl.PINK)
		render(&state.world)
		rl.EndDrawing()
	}
}

@(private = "file")
update :: proc(world: ^entities.World) {
	for easing, idx in world.easings {
		if easing.elapsed < easing.duration {
			instance := &world.instances[easing.target_id]
			progress := easing.fn(easing.elapsed, 0.0, 1.0, easing.duration)
			world.easings[idx].elapsed += rl.GetFrameTime()
			instance.position = easing.start_value + (easing.start_value - easing.end_value) * progress
		}
		// TODO: clean finished animations
	}
}

@(private = "file")
render :: proc(world: ^entities.World) {
	for key, &instance in world.instances {
		#partial switch entity in instance.entity {
		case entities.ImageEntity:
			rl.DrawTextureEx(
				entity.texture,
				instance.position,
				instance.rotation,
				instance.scale,
				rl.WHITE,
			)
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
			on_create_image(&comm, &state.world)

		case commands.DeleteImage:
			comm := comm.(commands.DeleteImage)
			on_delete_image(&comm, &state.world)

		case commands.Move:
			comm := comm.(commands.Move)
			on_move(&comm, &state.world)

		}
		// TODO: free command?
	}
}

on_create_image :: proc(c: ^commands.CreateImage, world: ^entities.World) {
	image := rl.LoadImage(strings.clone_to_cstring(c.resource))
	texture := rl.LoadTextureFromImage(image)
	defer rl.UnloadImage(image)

	world.instances[c.id] = entities.Instance {
		id = c.id,
		entity = entities.ImageEntity{texture = texture, tint = rl.WHITE},
		position = c.pos,
		scale = c.size,
		rotation = 0.0,
		status = entities.Status.LOADED,
		z = 0,
	}
}

on_move :: proc(c: ^commands.Move, world: ^entities.World) {
	instance, ok := &world.instances[c.id]
	if ok {
		append(
			&world.easings,
			entities.Easing {
				target_id= instance.id,
				property=entities.Property.POSITION,
				elapsed= 0.0,
				duration= 1.0,
				start_value = instance.position,
				end_value = c.pos,
				fn= rl.EaseCubicInOut,
			}
		)
	} else {
		fmt.printfln("on_move FAILED: entity not found ID=", c.id)
	}
}

on_delete_image :: proc(c: ^commands.DeleteImage, world: ^entities.World) {
	delete_key(&world.instances, c.id)
}
