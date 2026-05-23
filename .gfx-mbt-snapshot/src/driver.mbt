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
/// Wrap an already-captured RGBA8 pixel buffer into a snapshot. Useful
/// when the pixels come from a non-`GraphicsDriver` source (golden
/// fixtures on disk, a manual PNG decode, ...). The buffer must be
/// `width * height * 4` bytes; this is not checked here.
pub fn FramebufferSnapshot::from_pixels(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  pixels : Array[Int],
) -> FramebufferSnapshot {
  { x, y, width, height, pixels }
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
    Some(pixels) =>
      Some(FramebufferSnapshot::from_pixels(x, y, width, height, pixels))
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
/// Per-channel diff against another snapshot. Any channel whose
/// absolute difference exceeds `threshold` counts the pixel as
/// changed; mismatched dimensions report all pixels as different.
pub fn FramebufferSnapshot::compare_with(
  self : FramebufferSnapshot,
  other : FramebufferSnapshot,
  threshold : Int,
) -> PixelDiffResult {
  let total = self.width * self.height
  if self.width != other.width || self.height != other.height {
    return { total_pixels: total, diff_pixels: total, max_channel_diff: 255 }
  }
  let pixel_count = self.width * self.height
  let mut diff_pixels = 0
  let mut max_diff = 0
  for i = 0; i < pixel_count; i = i + 1 {
    let base = i * 4
    if base + 3 < self.pixels.length() && base + 3 < other.pixels.length() {
      let dr = abs_int(self.pixels[base] - other.pixels[base])
      let dg = abs_int(self.pixels[base + 1] - other.pixels[base + 1])
      let db = abs_int(self.pixels[base + 2] - other.pixels[base + 2])
      let da = abs_int(self.pixels[base + 3] - other.pixels[base + 3])
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
/// Fraction of pixels that exceeded the diff threshold, in [0.0, 1.0].
pub fn PixelDiffResult::diff_ratio(self : PixelDiffResult) -> Double {
  if self.total_pixels == 0 {
    return 0.0
  }
  self.diff_pixels.to_double() / self.total_pixels.to_double()
}
