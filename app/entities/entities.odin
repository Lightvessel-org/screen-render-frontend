package entities

entity_tag :: enum {
    TWEEN,
    VIDEO,
    POSITION,
    SCALE,
    ALPHA,
}

Entity :: struct{
    id:  u32,
    components: bit_set[entity_tag; u32],
}