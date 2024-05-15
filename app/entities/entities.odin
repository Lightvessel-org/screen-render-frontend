package entities

/*

*/

ImageEntity :: struct {
    label: string,
    file: string,
    pos:[2]f32,
}


//entity_tag :: enum {
//   POSITION,
//   SCALE,
//   IMAGE_RESOURCE,
//
//
//ntity :: struct{
//   id:  u32,
//   components: bit_set[entity_tag; u32],
//

// main :: proc() {
//     ent: entity_t
// 
//     showbits(ent.components)
//     ent.components += {.RENDER2D}
//     showbits(ent.components)
// 
//     fmt.println((hasComponent(ent, .POSITION)) ? "can move" : "cannot move")
// 
//     ent.components += {.POSITION}
//     showbits(ent.components)
// 
//     fmt.println((hasComponent(ent, .POSITION)) ? "can move" : "cannot move")
// }
// [12:53 PM]
// showbits :: proc(x: bit_set[components_e; u32]) {
//     fmt.println(x)
// }