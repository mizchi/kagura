///|
priv struct NativeCapture {
  config : @capture.CaptureConfig
  request : CaptureRequest?
}

///|
// Outer None means unread; Some(None) means interactive mode.
let native_capture : Ref[NativeCapture??] = Ref(None)

///|
let native_capture_context : Ref[String] = Ref("null")

///|
let gpu_capture_for_test : Ref[Bool] = Ref(false)

///|
/// Playing 3D in this game draws into `pipeline.scene_target` (handle ids 300+),
/// which GPU capture never registered. When capturing, draw into `ctx.dst`.
pub fn is_native_gpu_capture() -> Bool {
  if gpu_capture_for_test.val {
    return true
  }
  match load_native_capture() {
    Some({ config, .. }) => config.backend == Gpu
    None => false
  }
}

///|
pub fn set_gpu_capture_for_test(enabled : Bool) -> Unit {
  gpu_capture_for_test.val = enabled
}

///|
fn load_native_capture() -> NativeCapture? {
  if native_capture.val is Some(value) {
    return value
  }
  let loaded = match
    @capture.read_native_capture_text(
      @capture.capture_config_filename,
      config=true,
    ) {
    None => None
    Some(text) => {
      let config = @capture.parse_capture_config(text).unwrap_or_else(() => {
        abort("Invalid native capture config")
      })
      let request = match @capture.capture_request_path(text) {
        None => None
        Some(path) => {
          let json = @capture.read_native_capture_text(path).unwrap_or_else(() => {
            abort("Missing capture request: " + path)
          })
          Some(
            parse_capture_request(json) catch {
              error => abort("Invalid capture request: " + error.to_string())
            },
          )
        }
      }
      Some({ config, request, })
    }
  }
  native_capture.val = Some(loaded)
  loaded
}

///|
/// Resolve the capture size before constructing game state and laying out UI.
pub fn capture_viewport(width : Int, height : Int) -> (Int, Int) {
  match load_native_capture() {
    Some({ request: Some(request), .. }) => (request.width, request.height)
    _ => (width, height)
  }
}

///|
/// Publish context from the same update/draw that produces the captured frame.
/// Native-only; the game adapter serializes UISnapshot without coupling UI to engine.
pub fn publish_capture_context(json : String) -> Unit {
  if load_native_capture() is Some(_) {
    native_capture_context.val = json
  }
}

///|
fn try_run_native_capture(
  update~ : (@core.InputSnapshot) -> Unit,
  draw~ : (EngineContext) -> Array[@gfx.DrawTrianglesCommand],
  on_frame? : () -> Unit,
  width~ : Int,
  height~ : Int,
) -> Bool {
  let capture = match load_native_capture() {
    None => return false
    Some(value) => value
  }
  let request = capture.request.or({
    width,
    height,
    frames: 1,
    inputs: [],
    initial_state: None,
  })
  if request.initial_state != applied_initial_state.val {
    abort("Requested initial state was not applied by the game")
  }
  native_capture_context.val = "null"
  if capture.config.backend is Gpu {
    return run_native_gpu_capture(capture, request, update~, draw~, on_frame?)
  }
  let frame = render_headless_frame(
    update~,
    on_frame?,
    draw=ctx => {
      let commands = draw(ctx)
      let textures = (headless_texture_provider.val)()
      for command in commands {
        for id in command.src_image_ids {
          if id >= 0 && !textures.any(texture => texture.id == id) {
            abort("Native capture is missing source texture: " + id.to_string())
          }
        }
      }
      commands
    },
    width=request.width,
    height=request.height,
    frames=request.frames,
    input_at=tick => request.input_at(tick),
    textures_at=() => (headless_texture_provider.val)(),
  )
  if frame.skipped_commands > 0 {
    abort("Native CPU capture cannot render 3D commands")
  }
  if capture.config.binarize {
    @capture.binarize_rgba8(frame.pixels)
  }
  let png = headless_frame_png(frame).unwrap_or_else(() => {
    abort("Unable to encode capture PNG")
  })
  @capture.write_native_capture_bytes(capture.config.screenshot_path, png)
  @capture.write_native_capture_text(
    capture.config.context_path,
    native_capture_context.val,
  )
  let initial_state = match applied_initial_state.val {
    Some(name) => "\"" + name + "\""
    None => "null"
  }
  @capture.write_native_capture_text(
    capture.config.summary_path,
    "{\"initial_state\":\{initial_state},\"backend\":\"native-cpu\",\"width\":\{frame.width},\"height\":\{frame.height},\"frames\":\{frame.frames},\"skipped_commands\":\{frame.skipped_commands},\"drawn_triangles\":\{frame.drawn_triangles},\"draw_commands\":\{frame.draw_commands}}",
  )
  true
}

///|
fn draw_command_triangles(cmds : Array[@gfx.DrawTrianglesCommand]) -> Int {
  let mut n = 0
  for cmd in cmds {
    n = n + cmd.indices.length() / 3
  }
  n
}

///|
fn write_native_capture_png(
  capture : NativeCapture,
  pixels : Array[Int],
  width : Int,
  height : Int,
  frames : Int,
  skipped_commands : Int,
  drawn_triangles : Int,
  draw_commands : Int,
  backend : String,
) -> Unit {
  if capture.config.binarize {
    @capture.binarize_rgba8(pixels)
  }
  let png = @capture.encode_rgba8_png(width, height, pixels).unwrap_or_else(() => {
    abort("Unable to encode capture PNG")
  })
  @capture.write_native_capture_bytes(capture.config.screenshot_path, png)
  let context = if native_capture_context.val == "null" {
    "{\"screen\":{\"width\":\{width},\"height\":\{height},\"dpr\":1},\"nodes\":[]}"
  } else {
    native_capture_context.val
  }
  @capture.write_native_capture_text(capture.config.context_path, context)
  let initial_state = match applied_initial_state.val {
    Some(name) => "\"" + name + "\""
    None => "null"
  }
  @capture.write_native_capture_text(
    capture.config.summary_path,
    "{\"initial_state\":\{initial_state},\"backend\":\"\{backend}\",\"width\":\{width},\"height\":\{height},\"frames\":\{frames},\"skipped_commands\":\{skipped_commands},\"drawn_triangles\":\{drawn_triangles},\"draw_commands\":\{draw_commands}}",
  )
}

///|
/// Drive the real wgpu pipeline: 3D commands the CPU rasterizer skips actually
/// land in the framebuffer. Offscreen, no window. Readback goes through
/// `GraphicsDriver.read_pixels`, which native hooks resolve onto the last
/// offscreen target when there is no swapchain.
fn run_native_gpu_capture(
  capture : NativeCapture,
  request : CaptureRequest,
  update~ : (@core.InputSnapshot) -> Unit,
  draw~ : (EngineContext) -> Array[@gfx.DrawTrianglesCommand],
  on_frame? : () -> Unit,
) -> Bool {
  invoke_on_start("", "kagura-capture")
  let surface = @gfx.create_offscreen_surface_token(
    request.width,
    request.height,
  )
  let graphics = @gfx.create_wgpu_native_graphics(
    surface,
    @gfx.default_graphics_backend_options(),
  )
  graphics.initialize() catch {
    err => abort("Native GPU capture failed to initialize: " + err.to_string())
  }
  let dst = graphics.new_image(request.width, request.height) catch {
    err =>
      abort(
        "Native GPU capture failed to allocate the frame: " + err.to_string(),
      )
  }
  let shader = graphics.new_shader(@gfx.default_builtin_shader_source()) catch {
    err =>
      abort(
        "Native GPU capture failed to compile the shader: " + err.to_string(),
      )
  }
  let ctx : EngineContext = {
    dst,
    shader,
    screen_w: request.width,
    screen_h: request.height,
  }
  for tick in 0..<request.frames {
    update(request.input_at(tick))
    match on_frame {
      Some(f) => f()
      None => ()
    }
  }
  let cmds = draw(ctx)
  let scene_cmds : Array[@gfx.DrawTrianglesCommand] = []
  let overlay_cmds : Array[@gfx.DrawTrianglesCommand] = []
  for cmd in cmds {
    if cmd.vertex_stride_hint >= 8 {
      scene_cmds.push(cmd)
    } else {
      overlay_cmds.push(cmd)
    }
  }
  let mut rgba : Array[Int]? = None
  for _ in 0..<2 {
    if scene_cmds.length() > 0 {
      render_commands(graphics, scene_cmds) catch {
        err => abort("Native GPU capture failed to render: " + err.to_string())
      }
      if overlay_cmds.length() > 0 {
        render_commands(graphics, overlay_cmds, clear_enabled=false) catch {
          err =>
            abort(
              "Native GPU capture failed to render overlay: " + err.to_string(),
            )
        }
      }
    } else {
      render_commands(graphics, overlay_cmds) catch {
        err => abort("Native GPU capture failed to render: " + err.to_string())
      }
    }
    rgba = graphics.read_pixels(0, 0, request.width, request.height) catch {
      err => abort("Native GPU capture readback failed: " + err.to_string())
    }
    if rgba is Some(_) {
      break
    }
  }
  let rgba = match rgba {
    None =>
      abort(
        "Native GPU capture readback returned no pixels. Import mizchi/native_runtime_hooks so wgpu hooks are installed.",
      )
    Some(value) => value
  }
  if rgba.length() != request.width * request.height * 4 {
    abort("Native GPU capture readback size mismatch")
  }
  write_native_capture_png(
    capture,
    rgba,
    request.width,
    request.height,
    request.frames,
    0,
    draw_command_triangles(cmds),
    cmds.length(),
    "native-gpu",
  )
  invoke_on_stop()
  true
}

///|
fn requested_initial_state() -> String? {
  match load_native_capture() {
    Some({ request: Some(request), .. }) => request.initial_state
    _ => None
  }
}

///|
fn record_initial_state_failure(_message : String) -> Unit {

}
