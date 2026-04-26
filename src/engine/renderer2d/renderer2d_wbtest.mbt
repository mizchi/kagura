///|
fn test_atlas_source(page_image_id : Int) -> @asset.AtlasDrawSource {
  let repo = @asset.new_simple_atlas_image_repository(8, 8, page_image_id)
  let key = @asset.new_asset_key("renderer2d/source")
  let _ = @asset.create_atlas_image(repo, key, @asset.default_image_spec(2, 2))
  match @asset.get_atlas_draw_source(repo, key) {
    Some(value) => value
    None => panic()
  }
}

///|
test "render_atlas_quads builds frame-targeted 2d commands" {
  let frame = RenderFrame2D::new(
    dst=@gfx.new_image_handle(1, 320, 240),
    shader=@gfx.new_shader_handle(2, "sprite"),
    screen_w=320,
    screen_h=240,
  )
  let quad = AtlasQuad2D::new(
    source=test_atlas_source(77),
    left=10.0,
    top=20.0,
    right=26.0,
    bottom=36.0,
  )
  let cmds = render_atlas_quads(frame, [quad])
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].dst.id, 1)
  assert_eq(cmds[0].shader.id, 2)
  assert_eq(cmds[0].src_image_ids[0], 77)
  assert_eq(cmds[0].dst_regions[0].width, 320)
  assert_eq(cmds[0].dst_regions[0].height, 240)
}

///|
test "append_atlas_quad preserves draw metadata overrides" {
  let frame = RenderFrame2D::new(
    dst=@gfx.new_image_handle(3, 64, 64),
    shader=@gfx.new_shader_handle(4, "sprite"),
    screen_w=64,
    screen_h=64,
    pipeline_id=12,
    uniform_hash=34,
    blend=@gfx.blend_mode_from_int(2),
  )
  let quad = AtlasQuad2D::new(
    source=test_atlas_source(88),
    left=-0.5,
    top=-0.5,
    right=0.5,
    bottom=0.5,
    uniform_dwords=[1, 2, 3, 4],
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  append_atlas_quad(cmds, frame, quad)
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].pipeline_id, 12)
  assert_eq(cmds[0].uniform_hash, 34)
  assert_eq(@gfx.blend_mode_to_int(cmds[0].blend), 2)
  assert_eq(cmds[0].uniform_dwords.length(), 4)
}
