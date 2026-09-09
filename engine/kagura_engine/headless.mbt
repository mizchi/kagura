///|
/// Headless frame rendering: run a game's `update` / `draw` for N ticks and
/// rasterize the last frame on the CPU.
///
/// This is the browser-free, GPU-free capture path. `@raster.RasterTarget` is
/// an ordinary `@gfx.GraphicsDriver`, so the game sees exactly the command
/// stream it would send to WebGPU and no example needs a second code path.
///
/// Target-agnostic on purpose: the JS entry point (`run_js.mbt`) and the
/// native capture can both drive it.

///|
/// One synthesized input tick. Cursor position and held keys are enough to
/// reach the states a UI actually breaks in -- hover, focus, a held direction
/// -- without pretending to be a full input recording.
pub(all) struct HeadlessInput {
  cursor_x : Double
  cursor_y : Double
  pressed_keys : Array[Int]
}

///|
pub fn default_headless_input() -> HeadlessInput {
  { cursor_x: -1.0, cursor_y: -1.0, pressed_keys: [], }
}

///|
/// A rendered frame plus what the rasterizer had to say about the command
/// stream that produced it.
pub(all) struct HeadlessFrame {
  width : Int
  height : Int
  /// How many update ticks ran before the captured draw.
  frames : Int
  /// RGBA8, `width * height * 4` entries.
  pixels : Array[Int]
  /// Draw commands the CPU rasterizer declined (3D geometry). A non-zero
  /// count means the PNG is missing part of the scene, so callers must
  /// surface it rather than treat the frame as complete.
  skipped_commands : Int
  drawn_triangles : Int
}

///|
/// Drive `update` for `frames` ticks, then rasterize one `draw` into an RGBA
/// buffer. `frames` of 0 draws the initial state without ever updating.
pub fn render_headless_frame(
  update~ : (@core.InputSnapshot) -> Unit,
  draw~ : (EngineContext) -> Array[@gfx.DrawTrianglesCommand],
  width~ : Int,
  height~ : Int,
  frames~ : Int,
  input? : HeadlessInput,
  on_frame? : () -> Unit,
  clear_color? : @gfx.Color,
) -> HeadlessFrame {
  let target = @raster.RasterTarget::new(width, height)
  let ctx : EngineContext = {
    dst: @gfx.new_image_handle(1, width, height),
    shader: @gfx.new_shader_handle(1, @gfx.default_builtin_shader_source()),
    screen_w: width,
    screen_h: height,
  }
  let snapshot = headless_input_snapshot(
    match input {
      Some(value) => value
      None => default_headless_input()
    },
  )
  for _ in 0..<frames {
    update(snapshot)
    match on_frame {
      Some(f) => f()
      None => ()
    }
  }
  let cmds = draw(ctx)
  let color = match clear_color {
    Some(c) => c
    None => @gfx.new_color(0.0, 0.0, 0.0, 1.0)
  }
  target.clear(color)
  for cmd in cmds {
    let _ = target.draw_command(cmd)
  }
  {
    width: target.width,
    height: target.height,
    frames,
    pixels: target.pixels,
    skipped_commands: target.skipped_commands,
    drawn_triangles: target.drawn_triangles,
  }
}

///|
fn headless_input_snapshot(input : HeadlessInput) -> @core.InputSnapshot {
  @core.new_input_snapshot(
    input.cursor_x,
    input.cursor_y,
    0.0,
    0.0,
    input.pressed_keys,
  )
}

///|
/// Parse the comma-separated key-code list the headless request carries
/// (`"9,32"`). Anything that is not an integer is skipped rather than
/// aborting the render -- a malformed key list should not cost the frame.
pub fn parse_headless_keys(text : String) -> Array[Int] {
  let keys : Array[Int] = []
  let mut value = 0
  let mut digits = 0
  let mut negative = false
  fn flush() -> Unit {
    if digits > 0 {
      keys.push(if negative { -value } else { value })
    }
    value = 0
    digits = 0
    negative = false
  }

  for ch in text {
    let code = ch.to_int()
    if code >= 48 && code <= 57 {
      value = value * 10 + (code - 48)
      digits = digits + 1
    } else if code == 45 && digits == 0 {
      negative = true
    } else if code == 44 || code == 32 {
      flush()
    } else {
      // Unparseable character: drop the token being built.
      value = 0
      digits = 0
      negative = false
    }
  }
  flush()
  keys
}

///|
/// PNG bytes for a rendered frame, or `None` when the encoder rejects the
/// buffer.
pub fn headless_frame_png(frame : HeadlessFrame) -> Bytes? {
  @capture.encode_rgba8_png(frame.width, frame.height, frame.pixels)
}
