package commands

command_e :: enum {
    CREATE_IMAGE,
    DELETE,
    MODIFY,
}

LedCommand :: union #no_nil {
    CreateImage,
    DeleteImage,
}

CreateImage :: struct {
    label: string,
    pos: [2]f32,
    size: [2]f32,
    resource: string,
}

DeleteImage :: struct {
    label: string,
}

