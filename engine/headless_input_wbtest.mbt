///|
test "headless input callback replays press release and press in tick order" {
  let observed : Array[Bool] = []
  let result = render_headless_frame(
    update=input => observed.push(input.pressed_keys.contains(9)),
    draw=_ => [],
    width=2,
    height=2,
    frames=3,
    input_at=tick => {
      @core.new_input_snapshot(
        0.0,
        0.0,
        0.0,
        0.0,
        if tick == 1 {
          []
        } else {
          [9]
        },
      )
    },
  )
  assert_eq(observed, [true, false, true])
  assert_eq(result.frames, 3)
}

///|
test "headless capture reads textures registered during the captured draw" {
  let textures : Array[HeadlessTexture] = []
  let frame = render_headless_frame(
    update=_ => (),
    draw=ctx => {
      textures.push({ id: 7, width: 1, height: 1, pixels: [0, 255, 0, 255], })
      let base = @renderer2d.new_ndc_rect_fill_command(
        ctx.dst,
        ctx.shader,
        0.0,
        0.0,
        2.0,
        2.0,
        2.0,
        2.0,
        @gfx.new_color(1.0, 1.0, 1.0, 1.0),
        0,
      )
      [
        @gfx.new_draw_triangles_command(
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
        ),
      ]
    },
    width=2,
    height=2,
    frames=1,
    textures_at=() => textures,
  )
  assert_eq(frame.pixels[0], 0)
  assert_eq(frame.pixels[1], 255)
  assert_eq(frame.pixels[2], 0)
}
