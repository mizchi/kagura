///|
/// Build a two-triangle quad in NDC covering the pixel rect (x, y, w, h) of a
/// `screen_w` x `screen_h` target -- the same mapping `@renderer2d` applies in
/// `pixel_to_ndc_vertices`.
fn quad_command(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  screen_w : Double,
  screen_h : Double,
  uniform : Array[Int],
  blend : @gfx.BlendMode,
) -> @gfx.DrawTrianglesCommand {
  fn nx(px : Double) -> Double {
    px / screen_w * 2.0 - 1.0
  }

  fn ny(py : Double) -> Double {
    1.0 - py / screen_h * 2.0
  }

  let vertices = [
    nx(x),
    ny(y),
    0.0,
    0.0,
    nx(x + w),
    ny(y),
    1.0,
    0.0,
    nx(x + w),
    ny(y + h),
    1.0,
    1.0,
    nx(x),
    ny(y + h),
    0.0,
    1.0,
  ]
  let indices = [0, 1, 2, 2, 3, 0]
  @gfx.new_draw_triangles_command(
    @gfx.new_image_handle(1, screen_w.to_int(), screen_h.to_int()),
    @gfx.new_shader_handle(1, "test"),
    [
      @gfx.new_dst_region(
        0,
        0,
        screen_w.to_int(),
        screen_h.to_int(),
        indices.length(),
      ),
    ],
    0,
    0,
    0,
    blend,
    vertices,
    indices,
    [],
    uniform,
  )
}

///|
fn pixel_at(target : RasterTarget, x : Int, y : Int) -> (Int, Int, Int, Int) {
  let base = (y * target.width + x) * 4
  (
    target.pixels[base],
    target.pixels[base + 1],
    target.pixels[base + 2],
    target.pixels[base + 3],
  )
}

///|
test "clear fills every pixel with the pass color" {
  let target = RasterTarget::new(4, 3)
  target.clear(@gfx.new_color(1.0, 0.5, 0.25, 1.0))
  assert_eq(target.pixels.length(), 4 * 3 * 4)
  assert_eq(pixel_at(target, 0, 0), (255, 128, 64, 255))
  assert_eq(pixel_at(target, 3, 2), (255, 128, 64, 255))
}

///|
test "an opaque rect covers exactly its pixel rect and nothing else" {
  let target = RasterTarget::new(16, 16)
  target.clear(@gfx.new_color(0.0, 0.0, 0.0, 1.0))
  let drawn = target.draw_command(
    quad_command(
      4.0,
      2.0,
      6.0,
      3.0,
      16.0,
      16.0,
      [255, 0, 0, 255],
      @gfx.BlendMode::Alpha,
    ),
  )
  assert_eq(drawn, 2)
  // Inside the rect.
  assert_eq(pixel_at(target, 4, 2), (255, 0, 0, 255))
  assert_eq(pixel_at(target, 9, 4), (255, 0, 0, 255))
  // One pixel outside each edge.
  assert_eq(pixel_at(target, 3, 2), (0, 0, 0, 255))
  assert_eq(pixel_at(target, 10, 2), (0, 0, 0, 255))
  assert_eq(pixel_at(target, 4, 1), (0, 0, 0, 255))
  assert_eq(pixel_at(target, 4, 5), (0, 0, 0, 255))
  // Exactly w*h pixels changed.
  let mut red = 0
  for i in 0..<(target.width * target.height) {
    if target.pixels[i * 4] == 255 {
      red = red + 1
    }
  }
  assert_eq(red, 18)
}

///|
test "the shared diagonal of a quad is not blended twice" {
  let target = RasterTarget::new(8, 8)
  target.clear(@gfx.new_color(0.0, 0.0, 0.0, 1.0))
  // 50% white over black: every covered pixel must land on 128, including the
  // pixels the two triangles share an edge along. A double blend would push
  // those to 191.
  let _ = target.draw_command(
    quad_command(
      0.0,
      0.0,
      8.0,
      8.0,
      8.0,
      8.0,
      [255, 255, 255, 128],
      @gfx.BlendMode::Alpha,
    ),
  )
  for y in 0..<8 {
    for x in 0..<8 {
      assert_eq(pixel_at(target, x, y), (128, 128, 128, 255))
    }
  }
}

///|
test "Copy overwrites the destination, Alpha composites over it" {
  let copy_target = RasterTarget::new(4, 4)
  copy_target.clear(@gfx.new_color(1.0, 1.0, 1.0, 1.0))
  let _ = copy_target.draw_command(
    quad_command(
      0.0,
      0.0,
      4.0,
      4.0,
      4.0,
      4.0,
      [0, 0, 255, 128],
      @gfx.BlendMode::Copy,
    ),
  )
  assert_eq(pixel_at(copy_target, 1, 1), (0, 0, 255, 128))
  let alpha_target = RasterTarget::new(4, 4)
  alpha_target.clear(@gfx.new_color(1.0, 1.0, 1.0, 1.0))
  let _ = alpha_target.draw_command(
    quad_command(
      0.0,
      0.0,
      4.0,
      4.0,
      4.0,
      4.0,
      [0, 0, 255, 128],
      @gfx.BlendMode::Alpha,
    ),
  )
  // src*a + dst*(1-a) with a = 128/255: red and green fall to 127/255, blue stays.
  assert_eq(pixel_at(alpha_target, 1, 1), (127, 127, 255, 255))
}

///|
test "a dst_region clips the draw to its rectangle" {
  let target = RasterTarget::new(16, 16)
  target.clear(@gfx.new_color(0.0, 0.0, 0.0, 1.0))
  let cmd = quad_command(
    0.0,
    0.0,
    16.0,
    16.0,
    16.0,
    16.0,
    [255, 255, 255, 255],
    @gfx.BlendMode::Alpha,
  )
  let clipped = @gfx.new_draw_triangles_command(
    cmd.dst,
    cmd.shader,
    [@gfx.new_dst_region(4, 4, 4, 4, cmd.indices.length())],
    0,
    0,
    0,
    cmd.blend,
    cmd.vertex_data,
    cmd.indices,
    [],
    cmd.uniform_dwords,
  )
  let _ = target.draw_command(clipped)
  assert_eq(pixel_at(target, 5, 5), (255, 255, 255, 255))
  assert_eq(pixel_at(target, 3, 5), (0, 0, 0, 255))
  assert_eq(pixel_at(target, 8, 5), (0, 0, 0, 255))
}

///|
test "several dst_regions each consume their own slice of the index buffer" {
  let target = RasterTarget::new(16, 8)
  target.clear(@gfx.new_color(0.0, 0.0, 0.0, 1.0))
  // Two independent quads in one command, each with its own scissor.
  let left = quad_command(
    0.0,
    0.0,
    8.0,
    8.0,
    16.0,
    8.0,
    [255, 255, 255, 255],
    @gfx.BlendMode::Alpha,
  )
  let right = quad_command(
    8.0,
    0.0,
    8.0,
    8.0,
    16.0,
    8.0,
    [255, 255, 255, 255],
    @gfx.BlendMode::Alpha,
  )
  let vertices : Array[Double] = []
  for value in left.vertex_data {
    vertices.push(value)
  }
  for value in right.vertex_data {
    vertices.push(value)
  }
  let indices = [0, 1, 2, 2, 3, 0, 4, 5, 6, 6, 7, 4]
  let cmd = @gfx.new_draw_triangles_command(
    left.dst,
    left.shader,
    // The second region is scissored to the left half, so the right quad is
    // entirely rejected -- proof the regions are not all seeing every index.
    [@gfx.new_dst_region(0, 0, 16, 8, 6), @gfx.new_dst_region(0, 0, 8, 8, 6)],
    0,
    0,
    0,
    @gfx.BlendMode::Alpha,
    vertices,
    indices,
    [],
    [255, 255, 255, 255],
  )
  let _ = target.draw_command(cmd)
  assert_eq(pixel_at(target, 2, 2), (255, 255, 255, 255))
  assert_eq(pixel_at(target, 12, 2), (0, 0, 0, 255))
}

///|
test "a registered texture is sampled and modulated by the uniform color" {
  let target = RasterTarget::new(8, 8)
  target.clear(@gfx.new_color(0.0, 0.0, 0.0, 1.0))
  // 2x1 texture: left half white, right half mid-grey.
  target.register_texture(7, 2, 1, [255, 255, 255, 255, 128, 128, 128, 255])
  let base = quad_command(
    0.0,
    0.0,
    8.0,
    8.0,
    8.0,
    8.0,
    [255, 0, 0, 255],
    @gfx.BlendMode::Copy,
  )
  let cmd = @gfx.new_draw_triangles_command(
    base.dst,
    base.shader,
    base.dst_regions,
    0,
    0,
    0,
    base.blend,
    base.vertex_data,
    base.indices,
    [7],
    base.uniform_dwords,
  )
  let _ = target.draw_command(cmd)
  assert_eq(pixel_at(target, 1, 4), (255, 0, 0, 255))
  assert_eq(pixel_at(target, 6, 4), (128, 0, 0, 255))
}

///|
test "an unregistered texture id samples as white, like an unbound GPU slot" {
  let target = RasterTarget::new(4, 4)
  target.clear(@gfx.new_color(0.0, 0.0, 0.0, 1.0))
  let base = quad_command(
    0.0,
    0.0,
    4.0,
    4.0,
    4.0,
    4.0,
    [0, 255, 0, 255],
    @gfx.BlendMode::Copy,
  )
  let cmd = @gfx.new_draw_triangles_command(
    base.dst,
    base.shader,
    base.dst_regions,
    0,
    0,
    0,
    base.blend,
    base.vertex_data,
    base.indices,
    [999],
    base.uniform_dwords,
  )
  let _ = target.draw_command(cmd)
  assert_eq(pixel_at(target, 2, 2), (0, 255, 0, 255))
}

///|
test "3D commands are counted as skipped rather than drawn as garbage" {
  let target = RasterTarget::new(4, 4)
  target.clear(@gfx.new_color(0.0, 0.0, 0.0, 1.0))
  let base = quad_command(
    0.0,
    0.0,
    4.0,
    4.0,
    4.0,
    4.0,
    [255, 255, 255, 255],
    @gfx.BlendMode::Alpha,
  )
  let cmd = @gfx.new_draw_triangles_command(
    base.dst,
    base.shader,
    base.dst_regions,
    0,
    0,
    0,
    base.blend,
    base.vertex_data,
    base.indices,
    [],
    base.uniform_dwords,
    vertex_stride_hint=8,
  )
  let drawn = target.draw_command(cmd)
  assert_eq(drawn, 0)
  assert_eq(target.skipped_commands, 1)
  assert_eq(pixel_at(target, 2, 2), (0, 0, 0, 255))
}

///|
test "out-of-range indices are dropped without touching the framebuffer" {
  let target = RasterTarget::new(4, 4)
  target.clear(@gfx.new_color(0.0, 0.0, 0.0, 1.0))
  let base = quad_command(
    0.0,
    0.0,
    4.0,
    4.0,
    4.0,
    4.0,
    [255, 255, 255, 255],
    @gfx.BlendMode::Alpha,
  )
  let cmd = @gfx.new_draw_triangles_command(
    base.dst,
    base.shader,
    [@gfx.new_dst_region(0, 0, 4, 4, 6)],
    0,
    0,
    0,
    base.blend,
    base.vertex_data,
    [0, 1, 99, 2, 3, 0],
    [],
    base.uniform_dwords,
  )
  let drawn = target.draw_command(cmd)
  assert_eq(drawn, 1)
  assert_eq(pixel_at(target, 0, 3), (255, 255, 255, 255))
}

///|
test "read_rect returns the sub-rectangle and zero-fills outside the target" {
  let target = RasterTarget::new(4, 4)
  target.clear(@gfx.new_color(0.0, 0.0, 1.0, 1.0))
  let inside = target.read_rect(1, 1, 2, 2)
  assert_eq(inside.length(), 16)
  assert_eq(inside[0], 0)
  assert_eq(inside[2], 255)
  let straddling = target.read_rect(3, 3, 2, 2)
  assert_eq(straddling.length(), 16)
  assert_eq(straddling[2], 255)
  assert_eq(straddling[6], 0)
  assert_eq(straddling[7], 0)
}

///|
test "resize discards the framebuffer and keeps it correctly sized" {
  let target = RasterTarget::new(4, 4)
  target.clear(@gfx.new_color(1.0, 1.0, 1.0, 1.0))
  target.resize_target(8, 2)
  assert_eq(target.width, 8)
  assert_eq(target.height, 2)
  assert_eq(target.pixels.length(), 8 * 2 * 4)
  assert_eq(pixel_at(target, 0, 0), (0, 0, 0, 0))
}

///|
test "the GraphicsDriver impl drives a frame end to end" {
  let target = RasterTarget::new(8, 8)
  let driver : &@gfx.GraphicsDriver = target
  driver.initialize()
  let dst = driver.new_image(8, 8)
  let shader = driver.new_shader("test")
  assert_eq(dst.id, 1)
  assert_eq(shader.id, 1)
  driver.begin(
    @gfx.new_render_pass_desc(@gfx.new_color(0.0, 0.0, 0.0, 1.0), true),
  )
  driver.draw_triangles(
    quad_command(
      2.0,
      2.0,
      4.0,
      4.0,
      8.0,
      8.0,
      [255, 255, 0, 255],
      @gfx.BlendMode::Alpha,
    ),
  )
  driver.end(true)
  match driver.read_pixels(0, 0, 8, 8) {
    Some(pixels) => {
      assert_eq(pixels.length(), 8 * 8 * 4)
      let base = (3 * 8 + 3) * 4
      assert_eq(
        (pixels[base], pixels[base + 1], pixels[base + 2]),
        (255, 255, 0),
      )
    }
    None => fail("the CPU rasterizer always supports readback")
  }
}
