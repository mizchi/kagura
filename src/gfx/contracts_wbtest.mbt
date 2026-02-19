///|
let test_native_gfx_init_calls : Ref[Int] = Ref::new(0)

///|
let test_native_gfx_begin_calls : Ref[Int] = Ref::new(0)

///|
let test_native_gfx_end_calls : Ref[Int] = Ref::new(0)

///|
let test_native_gfx_draw_calls : Ref[Int] = Ref::new(0)

///|
fn test_native_gfx_try_initialize(_width : Int, _height : Int) -> Bool {
  test_native_gfx_init_calls.val = test_native_gfx_init_calls.val + 1
  true
}

///|
fn test_native_gfx_on_begin(active : Bool, _pass : RenderPassDesc) -> Unit {
  if active {
    test_native_gfx_begin_calls.val = test_native_gfx_begin_calls.val + 1
  }
}

///|
fn test_native_gfx_on_end(active : Bool, present : Bool) -> Unit {
  if active && present {
    test_native_gfx_end_calls.val = test_native_gfx_end_calls.val + 1
  }
}

///|
fn test_native_gfx_on_draw(
  active : Bool,
  _command : DrawTrianglesCommand,
) -> Unit {
  if active {
    test_native_gfx_draw_calls.val = test_native_gfx_draw_calls.val + 1
  }
}

///|
let test_web_gfx_init_calls : Ref[Int] = Ref::new(0)

///|
let test_web_gfx_begin_calls : Ref[Int] = Ref::new(0)

///|
let test_web_gfx_end_calls : Ref[Int] = Ref::new(0)

///|
let test_web_gfx_draw_calls : Ref[Int] = Ref::new(0)

///|
fn test_web_gfx_try_initialize(
  kind : GraphicsBackendKind,
  _width : Int,
  _height : Int,
) -> Bool {
  test_web_gfx_init_calls.val = test_web_gfx_init_calls.val + 1
  match kind {
    GraphicsBackendKind::WebGpu => true
    GraphicsBackendKind::WebGl2 => true
    _ => false
  }
}

///|
fn test_web_gfx_on_begin(
  active : Bool,
  kind : GraphicsBackendKind,
  _pass : RenderPassDesc,
) -> Unit {
  if active {
    match kind {
      GraphicsBackendKind::WebGpu | GraphicsBackendKind::WebGl2 =>
        test_web_gfx_begin_calls.val = test_web_gfx_begin_calls.val + 1
      _ => ()
    }
  }
}

///|
fn test_web_gfx_on_end(
  active : Bool,
  kind : GraphicsBackendKind,
  present : Bool,
) -> Unit {
  if active && present {
    match kind {
      GraphicsBackendKind::WebGpu | GraphicsBackendKind::WebGl2 =>
        test_web_gfx_end_calls.val = test_web_gfx_end_calls.val + 1
      _ => ()
    }
  }
}

///|
fn test_web_gfx_on_draw(
  active : Bool,
  kind : GraphicsBackendKind,
  _command : DrawTrianglesCommand,
) -> Unit {
  if active {
    match kind {
      GraphicsBackendKind::WebGpu | GraphicsBackendKind::WebGl2 =>
        test_web_gfx_draw_calls.val = test_web_gfx_draw_calls.val + 1
      _ => ()
    }
  }
}

///|
test "native graphics hooks can be overridden and reset" {
  reset_native_graphics_hooks()
  test_native_gfx_init_calls.val = 0
  test_native_gfx_begin_calls.val = 0
  test_native_gfx_end_calls.val = 0
  test_native_gfx_draw_calls.val = 0

  set_native_graphics_hooks(
    new_native_graphics_hooks(
      test_native_gfx_try_initialize, test_native_gfx_on_begin, test_native_gfx_on_end,
      test_native_gfx_on_draw,
    ),
  )

  let surface = @platform.create_offscreen_surface_token(320, 240)
  let options = default_graphics_backend_options()
  let driver = create_wgpu_native_graphics(surface, options)
  driver.initialize()

  let dst = driver.new_image(64, 64)
  let shader = driver.new_shader("shader")
  let command : DrawTrianglesCommand = {
    dst,
    shader,
    dst_regions: [{ x: 0, y: 0, width: 64, height: 64, index_count: 3 }],
    index_offset: 0,
    blend: BlendMode::Alpha,
  }
  let pass = new_render_pass_desc(new_color(0.0, 0.0, 0.0, 1.0), true)

  driver.begin(pass)
  driver.draw_triangles(command)
  driver.end(true)

  assert_eq(test_native_gfx_init_calls.val, 1)
  assert_eq(test_native_gfx_begin_calls.val, 1)
  assert_eq(test_native_gfx_end_calls.val, 1)
  assert_eq(test_native_gfx_draw_calls.val, 1)

  reset_native_graphics_hooks()

  let before_init_calls = test_native_gfx_init_calls.val
  let before_begin_calls = test_native_gfx_begin_calls.val
  let before_end_calls = test_native_gfx_end_calls.val
  let before_draw_calls = test_native_gfx_draw_calls.val
  let driver2 = create_wgpu_native_graphics(surface, options)
  driver2.initialize()

  let dst2 = driver2.new_image(64, 64)
  let shader2 = driver2.new_shader("shader")
  driver2.begin(pass)
  driver2.draw_triangles({
    dst: dst2,
    shader: shader2,
    dst_regions: [{ x: 0, y: 0, width: 64, height: 64, index_count: 3 }],
    index_offset: 0,
    blend: BlendMode::Alpha,
  })
  driver2.end(true)

  assert_true(!driver2.native_active)
  assert_eq(test_native_gfx_init_calls.val, before_init_calls)
  assert_eq(test_native_gfx_begin_calls.val, before_begin_calls)
  assert_eq(test_native_gfx_end_calls.val, before_end_calls)
  assert_eq(test_native_gfx_draw_calls.val, before_draw_calls)
}

///|
test "web graphics hooks can be overridden and reset" {
  reset_web_graphics_hooks()
  test_web_gfx_init_calls.val = 0
  test_web_gfx_begin_calls.val = 0
  test_web_gfx_end_calls.val = 0
  test_web_gfx_draw_calls.val = 0

  set_web_graphics_hooks(
    new_web_graphics_hooks(
      test_web_gfx_try_initialize, test_web_gfx_on_begin, test_web_gfx_on_end, test_web_gfx_on_draw,
    ),
  )

  let surface = @platform.create_offscreen_surface_token(320, 240)
  let options = default_graphics_backend_options()
  let driver = create_webgpu_graphics(surface, options)
  driver.initialize()

  let dst = driver.new_image(64, 64)
  let shader = driver.new_shader("shader")
  let command : DrawTrianglesCommand = {
    dst,
    shader,
    dst_regions: [{ x: 0, y: 0, width: 64, height: 64, index_count: 3 }],
    index_offset: 0,
    blend: BlendMode::Alpha,
  }
  let pass = new_render_pass_desc(new_color(0.0, 0.0, 0.0, 1.0), true)

  driver.begin(pass)
  driver.draw_triangles(command)
  driver.end(true)

  assert_eq(test_web_gfx_init_calls.val, 1)
  assert_eq(test_web_gfx_begin_calls.val, 1)
  assert_eq(test_web_gfx_end_calls.val, 1)
  assert_eq(test_web_gfx_draw_calls.val, 1)

  reset_web_graphics_hooks()

  let before_init_calls = test_web_gfx_init_calls.val
  let before_begin_calls = test_web_gfx_begin_calls.val
  let before_end_calls = test_web_gfx_end_calls.val
  let before_draw_calls = test_web_gfx_draw_calls.val
  let driver2 = create_webgpu_graphics(surface, options)
  driver2.initialize()

  let dst2 = driver2.new_image(64, 64)
  let shader2 = driver2.new_shader("shader")
  driver2.begin(pass)
  driver2.draw_triangles({
    dst: dst2,
    shader: shader2,
    dst_regions: [{ x: 0, y: 0, width: 64, height: 64, index_count: 3 }],
    index_offset: 0,
    blend: BlendMode::Alpha,
  })
  driver2.end(true)

  assert_eq(test_web_gfx_init_calls.val, before_init_calls)
  assert_eq(test_web_gfx_begin_calls.val, before_begin_calls)
  assert_eq(test_web_gfx_end_calls.val, before_end_calls)
  assert_eq(test_web_gfx_draw_calls.val, before_draw_calls)
}

///|
test "command queue flush calls driver draw" {
  let driver = create_null_graphics(320, 240)
  driver.initialize()

  let dst = driver.new_image(64, 64)
  let shader = driver.new_shader("shader")
  let queue = new_simple_command_queue()
  queue.enqueue_draw_triangles({
    dst,
    shader,
    dst_regions: [{ x: 0, y: 0, width: 64, height: 64, index_count: 3 }],
    index_offset: 0,
    blend: BlendMode::Alpha,
  })

  flush_commands(driver, queue, true)

  assert_eq(driver.draw_count, 1)
  assert_eq(driver.begin_count, 1)
  assert_eq(driver.end_count, 1)
}

///|
test "null graphics backend constructors are available" {
  let surface = @platform.create_offscreen_surface_token(320, 240)
  let options = default_graphics_backend_options()
  let _ = create_webgpu_graphics(surface, options)
  let _ = create_webgl_graphics(surface, options)
  let _ = create_wgpu_native_graphics(surface, options)
}
