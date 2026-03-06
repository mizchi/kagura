///|
let screen_w : Int = 320

///|
let screen_h : Int = 240

///|
let frame_w : Int = 16

///|
let frame_h : Int = 16

///|
let atlas_page_id : Int = 100

///|
/// Generate a 4x1 sprite sheet with solid-color frames (red, green, blue, yellow).
fn generate_sprite_sheet() -> @asset.ImageSpec {
  let cols = 4
  let w = frame_w * cols
  let h = frame_h
  let pixels : Array[Int] = Array::make(w * h * 4, 0)
  let colors : Array[Array[Int]] = [
    [255, 0, 0, 255],
    [0, 255, 0, 255],
    [0, 0, 255, 255],
    [255, 255, 0, 255],
  ]
  for row in 0..<h {
    for col_idx in 0..<cols {
      let color = colors[col_idx]
      for px in 0..<frame_w {
        let x = col_idx * frame_w + px
        let idx = (row * w + x) * 4
        pixels[idx] = color[0]
        pixels[idx + 1] = color[1]
        pixels[idx + 2] = color[2]
        pixels[idx + 3] = color[3]
      }
    }
  }
  @asset.image_spec_with_rgba8(w, h, pixels)
}

///|
fn main {
  @web_hooks.install("#app")
  let sheet = generate_sprite_sheet()
  let frames = @animation2d.split_sprite_sheet(
    sheet, "frame", 4, 1, frame_w, frame_h,
  )
  let inputs : Array[@sprite_packer.SpriteInput] = []
  for pair in frames {
    let (key, spec) = pair
    inputs.push({ key: key.value, spec })
  }
  let result = @sprite_packer.pack_sprites(inputs).unwrap()
  let atlas = @sprite_packer.create_packed_atlas_repository(
    inputs, result, atlas_id=atlas_page_id,
  )
  @web_hooks.sync_dirty_atlas_pages_from_repository(atlas) |> ignore
  let keys = @animation2d.sprite_sheet_keys("frame", 4)
  let clip = @animation2d.SpriteAnimationClip::uniform("walk", keys, 0.25)
  let player = @animation2d.SpriteAnimationPlayer::new(clip)
  let dt = 1.0 / 60.0
  @engine.run(
    update=fn(_input) { player.update(dt) },
    draw=fn(ctx) {
      let commands : Array[@gfx.DrawTrianglesCommand] = []
      @animation2d.draw_sprite_animation(
        commands, atlas, player, ctx.dst, ctx.shader,
        @gfx.new_dst_region(0, 0, screen_w, screen_h, 6),
        @gfx.blend_mode_from_int(1), -1.0, -1.0, 1.0, 1.0,
      )
      |> ignore
      commands
    },
    width=screen_w,
    height=screen_h,
    title="Sprite Animation Demo",
    canvas="#app",
  )
}
