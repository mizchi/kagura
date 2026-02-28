///|
let screen_w : Int = 320

///|
let screen_h : Int = 240

///|
let atlas_page_id : Int = 100

///|
fn main {
  @web_hooks.install("#app")
  @asset.fetch_image("./assets/sample.png", fn(image_opt) {
    match image_opt {
      None => println("Failed to load image")
      Some(spec) => {
        let atlas = @asset.new_simple_atlas_image_repository(
          spec.width, spec.height, atlas_page_id,
        )
        let key = @asset.new_asset_key("sample")
        let _handle = @asset.create_atlas_image(atlas, key, spec)
        @web_hooks.sync_dirty_atlas_pages_from_repository(atlas) |> ignore
        @engine.run(
          update=fn(_input) {  },
          draw=fn(ctx) {
            let commands : Array[@gfx.DrawTrianglesCommand] = []
            @sprite2d.append_atlas_sprite_draw_command(
              commands,
              atlas,
              key,
              ctx.dst,
              ctx.shader,
              @gfx.new_dst_region(0, 0, screen_w, screen_h, 6),
              0,
              0,
              0,
              @gfx.blend_mode_from_int(1),
              -1.0,
              -1.0,
              1.0,
              1.0,
              [],
            )
            |> ignore
            commands
          },
          width=screen_w,
          height=screen_h,
          title="Fetch Image Demo",
          canvas="#app",
        )
      }
    }
  })
}
