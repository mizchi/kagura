///|
let vrt_width : Int = 320

///|
let vrt_height : Int = 240

///|
let max_diff_ratio : Double = 0.01

///|
struct VrtResult {
  name : String
  passed : Bool
  diff_ratio : Double
  message : String
}

///|
/// Read the full readback framebuffer as an Array[Int] (RGBA).
fn read_full_framebuffer() -> Array[Int]? {
  @wgpu_native.runtime_read_pixels(0, 0, vrt_width, vrt_height)
}

///|
/// Load a baseline BMP from the baselines/ directory.
fn load_baseline(name : String) -> @image.ImageData? {
  let path = "baselines/" + name + ".bmp"
  let bytes = @wgpu_native.read_file_bytes(path)
  match bytes {
    None => None
    Some(data) =>
      try {
        Some(@image.decode_bmp(data))
      } catch {
        _ => None
      }
  }
}

///|
/// Save current readback to baselines/ directory as BMP.
fn save_baseline(name : String) -> Bool {
  let path = "baselines/" + name + ".bmp"
  @wgpu_native.write_readback_bmp(path)
}

///|
/// Compare rendered framebuffer against baseline.
fn compare_snapshot(name : String, pixels : Array[Int]) -> VrtResult {
  let baseline = load_baseline(name)
  match baseline {
    None =>
      {
        name,
        passed: false,
        diff_ratio: 1.0,
        message: "baseline not found: baselines/" + name + ".bmp",
      }
    Some(img) => {
      if img.width != vrt_width || img.height != vrt_height {
        return {
          name,
          passed: false,
          diff_ratio: 1.0,
          message: "baseline size mismatch: expected " +
            vrt_width.to_string() +
            "x" +
            vrt_height.to_string() +
            ", got " +
            img.width.to_string() +
            "x" +
            img.height.to_string(),
        }
      }
      let baseline_pixels : Array[Int] = Array::make(
        img.width * img.height * 4,
        0,
      )
      for i in 0..<baseline_pixels.length() {
        baseline_pixels[i] = img.data[i].to_int()
      }
      let img1 : @pixelmatch.Image = {
        width: vrt_width,
        height: vrt_height,
        data: pixels,
      }
      let img2 : @pixelmatch.Image = {
        width: vrt_width,
        height: vrt_height,
        data: baseline_pixels,
      }
      let opts = @pixelmatch.Options::default()
      let ratio = @pixelmatch.match_ratio(img1, img2, opts)
      let diff_ratio = 1.0 - ratio
      if diff_ratio <= max_diff_ratio {
        { name, passed: true, diff_ratio, message: "OK" }
      } else {
        let report = @pixelmatch.diff_report(img1, img2, opts)
        {
          name,
          passed: false,
          diff_ratio,
          message: "diff " +
            (diff_ratio * 100.0).to_string() +
            "% exceeds threshold\n" +
            report.to_compact(),
        }
      }
    }
  }
}

///|
fn test_clear_color() -> VrtResult {
  let name = "clear_red"
  let _ = @wgpu_native.runtime_render_frame_with_plan(0.8, 0.2, 0.1, 1.0, 0)
  match read_full_framebuffer() {
    None =>
      { name, passed: false, diff_ratio: 1.0, message: "readback failed" }
    Some(pixels) => compare_snapshot(name, pixels)
  }
}

///|
fn test_triangle() -> VrtResult {
  let name = "triangle"
  let _ = @wgpu_native.runtime_render_frame_with_plan(0.0, 0.0, 0.0, 1.0, 1)
  match read_full_framebuffer() {
    None =>
      { name, passed: false, diff_ratio: 1.0, message: "readback failed" }
    Some(pixels) => compare_snapshot(name, pixels)
  }
}

///|
fn main {
  // Check for update mode: touch .update_baselines to regenerate
  let update = @wgpu_native.read_file_bytes(".update_baselines") != None
  if !@native_hooks.initialize_headless_context(vrt_width, vrt_height) {
    println("FAIL: headless context initialization failed")
    return
  }
  let tests : Array[() -> VrtResult] = [test_clear_color, test_triangle]
  if update {
    println("Updating baselines...")
    for test_fn in tests {
      let result = test_fn()
      if save_baseline(result.name) {
        println("  updated: " + result.name + ".bmp")
      } else {
        println("  FAIL: could not save " + result.name + ".bmp")
      }
    }
    println("Done. Remove .update_baselines to run tests.")
  } else {
    let mut passed = 0
    let mut failed = 0
    let results : Array[VrtResult] = []
    for test_fn in tests {
      let result = test_fn()
      results.push(result)
      if result.passed {
        passed += 1
      } else {
        failed += 1
      }
    }
    println("")
    for result in results {
      if result.passed {
        println(
          "  PASS: " +
          result.name +
          " (diff=" +
          (result.diff_ratio * 100.0).to_string() +
          "%)",
        )
      } else {
        println("  FAIL: " + result.name + " - " + result.message)
      }
    }
    println("")
    println(
      "Results: " +
      passed.to_string() +
      " passed, " +
      failed.to_string() +
      " failed",
    )
  }
  @native_hooks.shutdown_context()
}
