///|
test "new_fullscreen_quad_command assigns stable resource_cache_key" {
  let dst = @gfx.new_image_handle(1, 320, 240)
  let shader = @gfx.new_shader_handle(2, "postfx")
  let a = new_fullscreen_quad_command(
    dst,
    shader,
    [10],
    [1, 2, 3, 4],
    @gfx.blend_mode_from_int(0),
  )
  let b = new_fullscreen_quad_command(
    dst,
    shader,
    [10],
    [1, 2, 3, 4],
    @gfx.blend_mode_from_int(0),
  )
  let c = new_fullscreen_quad_command(
    dst,
    shader,
    [10],
    [1, 2, 3, 5],
    @gfx.blend_mode_from_int(0),
  )
  let d = new_fullscreen_quad_command(
    dst,
    shader,
    [11],
    [1, 2, 3, 4],
    @gfx.blend_mode_from_int(0),
  )
  assert_true(a.resource_cache_key != 0)
  assert_eq(a.resource_cache_key, b.resource_cache_key)
  assert_true(a.resource_cache_key != c.resource_cache_key)
  assert_true(a.resource_cache_key != d.resource_cache_key)
}
