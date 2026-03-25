///|
fn main {
  // Initialize headless context (hidden window, no display required)
  let ctx = @wgpu_native.init_headless_context(320, 240)

  // Render a single frame with red background
  @wgpu_native.render_triangle_frame_with_plan(
    ctx, 0.8, 0.2, 0.1, 1.0, // clear color: reddish
    1, // draw_calls: render the built-in triangle
  )

  // Save the rendered frame to a BMP file
  if @wgpu_native.save_screenshot("screenshot.bmp") {
    println("Saved screenshot.bmp (320x240)")
  } else {
    println("Failed to save screenshot")
  }

  @wgpu_native.shutdown_triangle_context(ctx)
}
