///|
/// `GraphicsDriver` trait and framebuffer-snapshot utilities used for VRT.
///
/// `GraphicsDriver` is the backend-facing API a renderer talks to;
/// `FramebufferSnapshot` + `compare_framebuffer_snapshots` are a small
/// pixel-diff harness for visual regression checks against `read_pixels`.

///|
/// The contract a graphics backend implements to render a frame.
///
/// One driver instance owns the device, the swapchain / surface, and
/// the per-frame command lifecycle. Renderers talk to a driver through
/// this trait and never reach for backend-specific APIs.
///
/// A typical frame:
///
/// ```ignore
/// driver.begin(pass)
/// for command in commands {
///   driver.draw_triangles(command)
/// }
/// driver.end(present)
/// ```
///
/// More commonly, drive it from a `CommandQueue` via `flush_commands`.
///
/// Implementors should be idempotent on `initialize` and should
/// de-duplicate identical `resize` calls.
pub(open) trait GraphicsDriver {
  /// Bind a device / swapchain. Called once before any other method.
  /// Ebiten ref: Graphics.Initialize.
  fn initialize(Self) -> Unit raise

  /// Open a render pass with the given clear color and present flag.
  /// Ebiten ref: Graphics.Begin.
  fn begin(Self, pass : RenderPassDesc) -> Unit raise

  /// Close the current render pass. `present=true` swaps buffers.
  /// Ebiten ref: Graphics.End.
  fn end(Self, present : Bool) -> Unit raise

  /// Reconfigure the surface to the new size. May be called outside a
  /// render pass and should de-duplicate identical sizes.
  /// Ebiten ref: surface resize / reconfigure paths.
  fn resize(Self, width : Int, height : Int) -> Unit raise

  /// Allocate a backend-owned image of the requested size and return a
  /// handle. The numeric id inside the handle is backend-defined; the
  /// caller treats it as opaque.
  /// Ebiten ref: Graphics.NewImage.
  fn new_image(Self, width : Int, height : Int) -> ImageHandle raise

  /// Compile a shader source string and return a handle.
  /// Ebiten ref: Graphics.NewShader.
  fn new_shader(Self, source : String) -> ShaderHandle raise

  /// Submit one `DrawTrianglesCommand` into the current render pass.
  /// Must be called between `begin` and `end`.
  /// Ebiten ref: Graphics.DrawTriangles.
  fn draw_triangles(Self, command : DrawTrianglesCommand) -> Unit raise

  /// Read back framebuffer pixels as a flat RGBA8 array of length
  /// `width * height * 4`. Returns None if readback is not supported by
  /// the backend (e.g. some headless paths). Used for VRT / golden
  /// image testing.
  fn read_pixels(Self, x : Int, y : Int, width : Int, height : Int) -> Array[
    Int,
  ]? raise
}

///|
pub struct FramebufferSnapshot {
  x : Int
  y : Int
  width : Int
  height : Int
  pixels : Array[Int]
} derive(Debug)

///|
pub impl Show for FramebufferSnapshot with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn create_framebuffer_snapshot(
  driver : &GraphicsDriver,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> FramebufferSnapshot? raise {
  match driver.read_pixels(x, y, width, height) {
    Some(pixels) => Some({ x, y, width, height, pixels })
    None => None
  }
}

///|
pub struct PixelDiffResult {
  total_pixels : Int
  diff_pixels : Int
  max_channel_diff : Int
} derive(Debug)

///|
pub impl Show for PixelDiffResult with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn compare_framebuffer_snapshots(
  a : FramebufferSnapshot,
  b : FramebufferSnapshot,
  threshold : Int,
) -> PixelDiffResult {
  let total = a.width * a.height
  if a.width != b.width || a.height != b.height {
    return { total_pixels: total, diff_pixels: total, max_channel_diff: 255 }
  }
  let pixel_count = a.width * a.height
  let mut diff_pixels = 0
  let mut max_diff = 0
  for i = 0; i < pixel_count; i = i + 1 {
    let base = i * 4
    if base + 3 < a.pixels.length() && base + 3 < b.pixels.length() {
      let dr = abs_int(a.pixels[base] - b.pixels[base])
      let dg = abs_int(a.pixels[base + 1] - b.pixels[base + 1])
      let db = abs_int(a.pixels[base + 2] - b.pixels[base + 2])
      let da = abs_int(a.pixels[base + 3] - b.pixels[base + 3])
      let channel_max = @cmp.maximum(@cmp.maximum(dr, dg), @cmp.maximum(db, da))
      if channel_max > max_diff {
        max_diff = channel_max
      }
      if channel_max > threshold {
        diff_pixels = diff_pixels + 1
      }
    }
  }
  { total_pixels: pixel_count, diff_pixels, max_channel_diff: max_diff }
}

///|
fn abs_int(x : Int) -> Int {
  if x < 0 {
    -x
  } else {
    x
  }
}

///|
pub fn pixel_diff_ratio(result : PixelDiffResult) -> Double {
  if result.total_pixels == 0 {
    return 0.0
  }
  result.diff_pixels.to_double() / result.total_pixels.to_double()
}
