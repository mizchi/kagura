///|
/// `GraphicsDriver` trait and framebuffer-snapshot utilities used for VRT.
///
/// `GraphicsDriver` is the backend-facing API a renderer talks to;
/// `FramebufferSnapshot` + `compare_framebuffer_snapshots` are a small
/// pixel-diff harness for visual regression checks against `read_pixels`.

///|
pub trait GraphicsDriver {
  /// Ebiten ref: Graphics.Initialize/Begin/End
  initialize(Self) -> Unit raise
  begin(Self, pass : RenderPassDesc) -> Unit raise
  end(Self, present : Bool) -> Unit raise
  /// Ebiten ref: surface resize / reconfigure paths
  resize(Self, width : Int, height : Int) -> Unit raise

  /// Ebiten ref: Graphics.NewImage/NewShader
  new_image(Self, width : Int, height : Int) -> ImageHandle raise
  new_shader(Self, source : String) -> ShaderHandle raise

  /// Ebiten ref: Graphics.DrawTriangles
  draw_triangles(Self, command : DrawTrianglesCommand) -> Unit raise

  /// Read back framebuffer pixels as flat RGBA8 array.
  /// Returns None if readback is not supported by the backend.
  read_pixels(Self, x : Int, y : Int, width : Int, height : Int) -> Array[Int]? raise
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
pub impl Show for FramebufferSnapshot with output(self, logger) {
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
pub impl Show for PixelDiffResult with output(self, logger) {
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
