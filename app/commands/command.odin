package commands

LedCommand :: union {
    CreateImage,
    DeleteImage,
    Move
}

CreateImage :: struct {
    id: int,
    pos: [2]f32,
    size: f32,
    resource: string,
}

Move :: struct {
    id: int,
    pos: [2]f32,
}

DeleteImage :: struct {
    id: int,
}