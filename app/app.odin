package app

import "../ffmpeg/avcodec"
import "../ffmpeg/avformat"
import "../ffmpeg/swscale"
import "../ffmpeg/types"
import "../ffmpeg/avutil"

import "core:fmt"
import "core:os"
import "core:strings"
import "core:time"
import thread "core:thread"

import rl "vendor:raylib"

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

//global
appState:AppState

run :: proc(t: ^thread.Thread) {
    rl.InitWindow(1280, 720, "My Game")
    //rl.ToggleBorderlessWindowed()
    player_pos := rl.Vector2 { 640, 320}
    speed : f32= 400.0
    image := rl.LoadImage(ASSETS_DIR + `golden_ball.png`)
    appState.current_frame = avutil.frame_alloc()
    //texture := rl.LoadTextureFromImage(image)
    //rl.SetTargetFPS(60)
    rl.SetTraceLogLevel(rl.TraceLogLevel.WARNING)

    vid_ctx:VideofileContext
    open_video_file(&vid_ctx, ASSETS_DIR + `countdown.avi`)

    finished := false
    frame_rate := avutil.q2d(vid_ctx.format_ctx.streams[vid_ctx.vid_stream_idx].avg_frame_rate)
    curr_time := time.now()

    fmt.println("Expected Video FPS: ", frame_rate)
    texture: rl.Texture2D

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLUE)

        if rl.IsKeyDown(.LEFT) {
            player_pos.x -= speed*rl.GetFrameTime()
        }

        if rl.IsKeyDown(.RIGHT) {
            player_pos.x += speed*rl.GetFrameTime()
        }

        if(!finished) {
            if time.duration_seconds(time.diff(curr_time,time.now()))>=1/frame_rate{
                curr_time = time.now()
                finished = grab_video_frame(&vid_ctx)
                fmt.println(rl.GetFPS())
                if(!finished) {
                    img := rl.Image {
                        data = appState.current_frame.data[0],
                        width = appState.current_frame.width,
                        height = appState.current_frame.height,
                        format = rl.PixelFormat.UNCOMPRESSED_R8G8B8A8,
                        mipmaps = 1
                    }
                    texture = rl.LoadTextureFromImage(img)
                }
            }
            rl.DrawTextureEx(texture, player_pos, 0.0, 0.2, rl.WHITE)
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

open_video_file :: proc(vidstruct:^VideofileContext,f_input:cstring){
    c_err:i32

    c_err = avformat.open_input(&vidstruct.format_ctx,f_input,nil,nil)
    assert(c_err==0,fmt.aprintf("Couldn't open input: %s","hi"))
    c_err = avformat.find_stream_info(vidstruct.format_ctx,nil)
    assert(c_err==0,fmt.aprintf("Couldn't find stream info: %s",avutil.av_error(c_err)))

    avformat.dump_format(vidstruct.format_ctx,0,f_input,0)

    vidstruct.vid_stream_idx=-1
    local_codec:^types.Codec
    local_codec_params:^types.Codec_Parameters
    //find video stream
    for i:u32=0; i<vidstruct.format_ctx.nb_streams; i+=1{

        local_codec_params = vidstruct.format_ctx.streams[i].codecpar 
        local_codec = avcodec.find_decoder(local_codec_params.codec_id)
        if local_codec_params.codec_type == types.Media_Type.Video{

            vidstruct.vid_stream_idx = cast(i32)i
            vidstruct.codec=local_codec
            vidstruct.codec_params = local_codec_params
            break
        }

    }

    assert(vidstruct.vid_stream_idx>-1,"Files does not contain a video stream")

    vidstruct.codec_ctx = avcodec.alloc_context3(vidstruct.codec)
    avcodec.parameters_to_context(vidstruct.codec_ctx,vidstruct.codec_params)
    avcodec.open2(vidstruct.codec_ctx,vidstruct.codec,nil)

}

grab_video_frame :: proc(vid_ctx:^VideofileContext) -> (finished: bool){
    packet := avcodec.packet_alloc()
    defer avcodec.packet_free(&packet)

    response:i32
    cerr:i32
    idx:int
    for{
        //grab compressed packet
        cerr = avformat.read_frame(vid_ctx.format_ctx,packet)
        if(cerr < 0) {
            fmt.aprintf("Could not read frame. Error %d",cerr)
            finished = true
            return
        }

        if packet.stream_index == vid_ctx.vid_stream_idx {
            //uncompress if video
            response = decode_packet(packet,vid_ctx.codec_ctx,appState.current_frame)
            idx += 1
            avcodec.packet_unref(packet)
            break
        }
        avcodec.packet_unref(packet)
    }

    finished = false
    return
}

decode_packet :: proc(packet:^types.Packet,codec_ctx:^types.Codec_Context,frame:^types.Frame)->i32{
    response :i32= avcodec.send_packet(codec_ctx,packet)

    //why is this a for loop? Should be one frame each?
    response = avcodec.receive_frame(codec_ctx,frame)
    if  avutil.av_error(response) == types.AVError.EOF || 
        avutil.av_error(response)==types.AVError.EAGAIN {
        return response 
    } else if response<0 {
        //EAGAIN is more like "try again".
        fmt.printf("Error receiving frame from decoder: %s\n",avutil.av_error(response))
        return response
    }

    if response>=0{
        // if frame.format.video != types.Pixel_Format.{
        //     fmt.println("Warning: the generated file may not be a grayscale image, but could e.g. be just the R component if the video format is RGB");
        // }
    }
    
    return 0
}