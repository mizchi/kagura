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
  let request = capture.request.or({ width, height, frames: 1, inputs: [], })
  native_capture_context.val = "null"
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
  @capture.write_native_capture_text(
    capture.config.summary_path,
    "{\"backend\":\"native-cpu\",\"width\":\{frame.width},\"height\":\{frame.height},\"frames\":\{frame.frames},\"skipped_commands\":\{frame.skipped_commands},\"drawn_triangles\":\{frame.drawn_triangles},\"draw_commands\":\{frame.draw_commands}}",
  )
  true
}
