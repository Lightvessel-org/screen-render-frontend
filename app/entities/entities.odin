package entities
import rl "vendor:raylib"

Instance :: struct {
    id: int,
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

World :: struct {
    instances: map[int]Instance,
    easings:   [dynamic]Easing,
}

Property :: enum {
    POSITION,
    SCALE,
    ROTATION,
}

Easing :: struct {
    target_id: int,
    property: Property,
    elapsed: f32,
    duration: f32,
    start_value: [2]f32, // TODO: extract to Property struct
    end_value: [2]f32,
    fn: proc(t, b, c, d: f32) -> f32,
}