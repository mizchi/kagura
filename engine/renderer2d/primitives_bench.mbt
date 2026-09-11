///|
/// Benchmarks for the 2D primitive builders. These are the per-quad path the
/// scene graph uses: `@scene.render_rect` calls `append_rect_fill` once per
/// rect, so a frame of a 2D game pays this N times.

///|
fn bench_primitive_frame() -> RenderFrame2D {
  RenderFrame2D::new(
    dst=@gfx.new_image_handle(1, 320, 240),
    shader=@gfx.new_shader_handle(2, "primitives_bench"),
    screen_w=320,
    screen_h=240,
  )
}

///|
test "bench append_rect_fill 1000" (b : @bench.T) {
  let frame = bench_primitive_frame()
  let color = color_from_hex(0x4A4A6A)
  b.bench(name="primitives/append_rect_fill_1000", fn() {
    let cmds : Array[@gfx.DrawTrianglesCommand] = []
    for i in 0..<1000 {
      let x = (i % 40).to_double() * 8.0
      let y = (i / 40).to_double() * 8.0
      append_rect_fill(
        cmds,
        frame,
        RectFill2D::new(x~, y~, w=6.0, h=6.0, color~),
      )
    }
    b.keep(cmds.length())
  })
}

///|
/// Floor for the bench above: everything `append_rect_fill` does except the
/// geometry and the command. Subtract to price the builder itself.
test "bench append_rect_fill floor 1000" (b : @bench.T) {
  let color = color_from_hex(0x4A4A6A)
  b.bench(name="primitives/append_rect_fill_floor_1000", fn() {
    let cmds : Array[@gfx.DrawTrianglesCommand] = []
    let mut acc = 0.0
    for i in 0..<1000 {
      let x = (i % 40).to_double() * 8.0
      let y = (i / 40).to_double() * 8.0
      let rect = RectFill2D::new(x~, y~, w=6.0, h=6.0, color~)
      acc = acc + rect.x + rect.y
    }
    b.keep(cmds.length() + acc.to_int())
  })
}

///|
test "bench append_rect_fill_geometry 1000" (b : @bench.T) {
  let frame = bench_primitive_frame()
  let color = color_from_hex(0x4A4A6A)
  b.bench(name="primitives/append_rect_fill_geometry_1000", fn() {
    let vertices : Array[Double] = []
    let indices : Array[Int] = []
    for i in 0..<1000 {
      let x = (i % 40).to_double() * 8.0
      let y = (i / 40).to_double() * 8.0
      append_rect_fill_geometry(
        vertices,
        indices,
        frame,
        RectFill2D::new(x~, y~, w=6.0, h=6.0, color~),
      )
    }
    b.keep(vertices.length() + indices.length())
  })
}

///|
test "bench append_dot_text 200 glyphs" (b : @bench.T) {
  let frame = bench_primitive_frame()
  let color = color_from_hex(0xFFFFFF)
  let chars : Array[Int] = []
  for i in 0..<20 {
    chars.push(i % 10)
  }
  b.bench(name="primitives/append_dot_text_10x20", fn() {
    let cmds : Array[@gfx.DrawTrianglesCommand] = []
    for i in 0..<10 {
      append_dot_text(
        cmds,
        frame,
        DotText2D::new(
          chars~,
          cx=4.0,
          cy=i.to_double() * 10.0,
          color~,
          scale=1.0,
        ),
      )
    }
    b.keep(cmds.length())
  })
}

///|
/// The same call as `scene/append_dot_text_direct_12` in
/// `game/scene`: 12 runs of "SCORE 12345" (102 lit dots each) at
/// the same size and position.
///
/// The pair is a reproducer, not a measurement. Under `moon bench -p` the two
/// disagree by about 2.5x; under `moon bench` over the workspace they agree.
/// This one is the side that moves, so its number is only meaningful next to
/// the other -- see `docs/performance/dot-text-batching.md`. The gate reports
/// it as NOISY (its own spread across runs is 3.12x, wider than the 1.5x
/// threshold), which is correct: it cannot be gated.
test "bench append_dot_text scene content 12" (b : @bench.T) {
  let frame = bench_primitive_frame()
  let color = color_from_hex(0xFFFFFF)
  // "SCORE 12345" as the scene renderer's `string_to_char_codes` maps it:
  // letters stay ASCII, digits become their value.
  let chars = [83, 67, 79, 82, 69, 32, 1, 2, 3, 4, 5]
  b.bench(name="primitives/append_dot_text_scene_content_12", fn() {
    let cmds : Array[@gfx.DrawTrianglesCommand] = []
    for i in 0..<12 {
      append_dot_text(
        cmds,
        frame,
        DotText2D::new(
          chars~,
          cx=8.0,
          cy=20.0 + i.to_double() * 12.0,
          color~,
          scale=1.0,
        ),
      )
    }
    b.keep(cmds.length())
  })
}
