package commands

LedCommand :: union {
    CreateImage,
    DeleteImage,
    Move
}

CreateImage :: struct {
    id: i32,
    pos: [2]f32,
    size: f32,
    resource: string,
}

Move :: struct {
    id: i32,
    pos: [2]f32,
}

DeleteImage :: struct {
    id: i32,
}