package commands

command_e :: enum {
    CREATE_IMAGE,
    DELETE,
    MODIFY,
}

LedCommand :: union {
    CreateImage,
    DeleteImage
}

CreateImage :: struct {
    id: i32,
    pos: [2]f32,
    size: [2]f32,
    resource: string,
}

DeleteImage :: struct {
    id: i32,
}

