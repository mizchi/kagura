///|
fn test_atlas_source(page_image_id : Int) -> @atlas.AtlasDrawSource {
  let repo = @atlas.new_simple_atlas_image_repository(8, 8, page_image_id)
  let key = @atlas.new_asset_key("renderer2d/source")
  let _ = @atlas.create_atlas_image(repo, key, @atlas.default_image_spec(2, 2))
  match @atlas.get_atlas_draw_source(repo, key) {
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
    blend=@gfx.BlendMode::from_int(2),
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
  assert_eq(@gfx.BlendMode::to_int(cmds[0].blend), 2)
  assert_eq(cmds[0].uniform_dwords.length(), 4)
}

///|
test "color_to_uniform_dwords packs RGBA bytes" {
  assert_eq(color_to_uniform_dwords(color_from_hex_alpha(0x336699, 0.5)), [
    51, 102, 153, 127,
  ])
}

///|
test "append_rect_fill builds frame-targeted primitive command" {
  let frame = RenderFrame2D::new(
    dst=@gfx.new_image_handle(9, 100, 50),
    shader=@gfx.new_shader_handle(10, "solid"),
    screen_w=100,
    screen_h=50,
    pipeline_id=7,
    uniform_hash=11,
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  append_rect_fill(
    cmds,
    frame,
    RectFill2D::new(
      x=10.0,
      y=5.0,
      w=20.0,
      h=10.0,
      color=color_from_hex_alpha(0x336699, 0.5),
    ),
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].dst.id, 9)
  assert_eq(cmds[0].dst_regions[0].width, 100)
  assert_eq(cmds[0].pipeline_id, 7)
  assert_eq(cmds[0].uniform_hash, 11)
  assert_eq(cmds[0].indices.length(), 6)
  assert_eq(cmds[0].uniform_dwords[3], 127)
}

///|
test "append_rect_fill_geometry rebases batched rect indices" {
  let frame = RenderFrame2D::new(
    dst=@gfx.new_image_handle(17, 100, 50),
    shader=@gfx.new_shader_handle(18, "solid"),
    screen_w=100,
    screen_h=50,
  )
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  append_rect_fill_geometry(
    vertices,
    indices,
    frame,
    RectFill2D::new(x=10.0, y=5.0, w=20.0, h=10.0, color=color_white()),
  )
  append_rect_fill_geometry(
    vertices,
    indices,
    frame,
    RectFill2D::new(x=40.0, y=15.0, w=10.0, h=8.0, color=color_white()),
  )
  assert_eq(vertices.length(), 32)
  assert_eq(indices, [0, 1, 2, 2, 3, 0, 4, 5, 6, 6, 7, 4])
}

///|
test "append_primitive_batch builds a single batched command" {
  let frame = RenderFrame2D::new(
    dst=@gfx.new_image_handle(19, 100, 50),
    shader=@gfx.new_shader_handle(20, "solid"),
    screen_w=100,
    screen_h=50,
  )
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  append_rect_fill_geometry(
    vertices,
    indices,
    frame,
    RectFill2D::new(x=10.0, y=5.0, w=20.0, h=10.0, color=color_white()),
  )
  append_rect_fill_geometry(
    vertices,
    indices,
    frame,
    RectFill2D::new(x=40.0, y=15.0, w=10.0, h=8.0, color=color_white()),
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  append_primitive_batch(
    cmds,
    frame,
    vertices,
    indices,
    color_from_hex(0x336699),
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].dst.id, 19)
  assert_eq(cmds[0].vertex_data.length(), 32)
  assert_eq(cmds[0].indices.length(), 12)
  assert_eq(cmds[0].dst_regions[0].width, 100)
}

///|
test "append_line and append_rect_outline emit NDC primitive commands" {
  let frame = RenderFrame2D::new(
    dst=@gfx.new_image_handle(11, 320, 240),
    shader=@gfx.new_shader_handle(12, "solid"),
    screen_w=320,
    screen_h=240,
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  append_line(
    cmds,
    frame,
    Line2D::new(
      x0=0.0,
      y0=0.0,
      x1=10.0,
      y1=0.0,
      width=2.0,
      color=color_from_hex(0xFFFFFF),
    ),
  )
  append_rect_outline(
    cmds,
    frame,
    RectOutline2D::new(
      x=2.0,
      y=3.0,
      w=20.0,
      h=10.0,
      line_width=1.5,
      color=color_from_hex(0x00FF00),
    ),
  )
  assert_eq(cmds.length(), 2)
  assert_eq(cmds[0].indices.length(), 6)
  assert_eq(cmds[1].indices.length(), 24)
  assert_eq(cmds[0].dst_regions[0].height, 240)
}

///|
test "append_dot_text expands glyphs through rect fill path" {
  let frame = RenderFrame2D::new(
    dst=@gfx.new_image_handle(13, 160, 90),
    shader=@gfx.new_shader_handle(14, "solid"),
    screen_w=160,
    screen_h=90,
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  append_dot_text(
    cmds,
    frame,
    DotText2D::new(
      chars=[65],
      cx=40.0,
      cy=30.0,
      color=color_from_hex(0xFFFFFF),
      scale=1.0,
    ),
  )
  assert_eq(cmds.length(), 10)
  assert_eq(cmds[0].dst.id, 13)
  assert_eq(cmds[0].indices.length(), 6)
}

///|
test "append_number expands numeric glyphs" {
  let frame = RenderFrame2D::new(
    dst=@gfx.new_image_handle(15, 160, 90),
    shader=@gfx.new_shader_handle(16, "solid"),
    screen_w=160,
    screen_h=90,
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  append_number(
    cmds,
    frame,
    Number2D::new(number=12, cx=40.0, cy=30.0, color=color_white(), scale=1.0),
  )
  assert_true(cmds.length() > 10)
  assert_eq(cmds[0].dst.id, 15)
  assert_eq(cmds[0].indices.length(), 6)
}
