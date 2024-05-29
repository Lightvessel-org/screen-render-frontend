package entities
import rl "vendor:raylib"

Instance :: struct {
    id: i32,
    entity:Entity,
    status: Status,
    position: rl.Vector2, 
    rotation: f32, 
    scale: f32, 
    z: int,
}

Entity :: union {
    ImageEntity
}

ImageEntity :: struct {
    texture: rl.Texture2D,
    tint: rl.Color
}

Status :: enum {
    NEEDS_TO_LOAD,
    LOADING,
    LOADED
}