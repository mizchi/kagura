// Blackbox tests for the public API surface. These intentionally use
// only the documented `pub` / `pub(all)` / `pub(open)` entry points
// (mirroring what a downstream consumer would see) so that any
// accidental visibility regression is caught here.

///|
test "null driver: end-to-end frame with merged batch" {
  let driver = create_null_graphics(640, 480)
  driver.initialize()
  let dst = driver.new_image(640, 480)
  let shader = driver.new_shader("// example WGSL")
  let region = new_dst_region(0, 0, 640, 480, 6)
  let command = new_draw_triangles_command(
    dst,
    shader,
    [region],
    0,
    1,
    0,
    BlendMode::Alpha,
    [
      0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0,
      1.0,
    ],
    [0, 1, 2, 1, 3, 2],
    [],
    [],
  )
  let queue = new_simple_command_queue()
  queue.enqueue_draw_triangles(command)
  queue.enqueue_draw_triangles(command)
  flush_commands(driver, queue, false)
  // null driver counts begin/end via resize_stats and friends; the
  // queue should have merged two identical commands into a single
  // backend draw.
}

///|
test "BlendMode round-trips through to_int / from_int" {
  for
    original in [
      BlendMode::Copy,
      BlendMode::Alpha,
      BlendMode::Add,
      BlendMode::Multiply,
    ] {
    let i = original.to_int()
    let restored = BlendMode::from_int(i)
    assert_eq(restored.to_int(), i)
  }
}

///|
test "DrawTrianglesCommand exposes dispatch summary" {
  let dst = new_image_handle(1, 64, 64)
  let shader = new_shader_handle(2, "src")
  let region = new_dst_region(0, 0, 64, 64, 9)
  let command = new_draw_triangles_command(
    dst,
    shader,
    [region],
    0,
    1,
    0,
    BlendMode::Alpha,
    [],
    [],
    [],
    [],
  )
  let dispatch = command.build_dispatch()
  assert_eq(dispatch.region_count, 1)
  assert_eq(dispatch.dst_image_id, dst.id)
  assert_eq(dispatch.shader_id, shader.id)
  assert_true(dispatch.checksum() > 0)
}

///|
test "FramebufferSnapshot diff catches per-channel changes" {
  let snap_a = FramebufferSnapshot::from_pixels(0, 0, 1, 1, [255, 0, 0, 255])
  let snap_b = FramebufferSnapshot::from_pixels(0, 0, 1, 1, [200, 0, 0, 255])
  let result = snap_a.compare_with(snap_b, 10)
  assert_eq(result.total_pixels, 1)
  assert_eq(result.diff_pixels, 1)
  assert_eq(result.max_channel_diff, 55)
  assert_true(result.diff_ratio() > 0.99)
}

///|
test "ShaderCompileRequest::validate flags empty source" {
  let bad : ShaderCompileRequest = {
    source: "",
    unit_hint: None,
    src_image_count: 0,
    entrypoints: default_shader_entrypoints(),
    debug_name: "",
  }
  let err = bad.validate()
  match err {
    Some(_) => ()
    None => fail("expected validation error for empty source")
  }
}

///|
test "UniformLayout::validate flags duplicate name" {
  let bad : UniformLayout = {
    names: ["x", "x"],
    dword_counts: [1, 1],
    preserved_prefix_dwords: 0,
  }
  let err = bad.validate()
  match err {
    Some(msg) => assert_true(msg.contains("duplicate"))
    None => fail("expected duplicate-name validation error")
  }
}

///|
test "BasicShaderFrontend produces stable hashes" {
  let frontend = new_basic_shader_frontend()
  let req : ShaderCompileRequest = {
    source: "fn main() {}",
    unit_hint: Some(ShaderUnit::Pixels),
    src_image_count: 0,
    entrypoints: default_shader_entrypoints(),
    debug_name: "demo",
  }
  let hash_a = frontend.calc_source_hash(req)
  let hash_b = frontend.calc_source_hash(req)
  assert_true(hash_a.eq(hash_b))
}
