// ============================================================
// Capture file IO (native)
// ============================================================
//
// Its own package because mizchi/kagura_engine/gfx_wgpu_native declares
// supported_targets = native; keeping the IO here leaves the config parsing and
// PNG encoding in the parent package usable on every target.

///|
/// Read and parse the capture config a driver staged in the working directory.
///
/// `None` covers both "no config staged" and "config missing a required path";
/// the caller reports which, since only it knows what it was trying to capture.
pub fn read_capture_config(
  filename? : String = @capture.capture_config_filename,
) -> @capture.CaptureConfig? {
  match @wgpu_native.read_file_bytes(filename) {
    Some(data) =>
      @capture.parse_capture_config(@capture.capture_bytes_to_string(data))
    None => None
  }
}

///|
/// Write the frame, the machine-readable context and the summary.
///
/// Returns the path that could not be written, so a failed capture names the
/// file instead of reporting a bare false.
pub fn write_capture_artifacts(
  config : @capture.CaptureConfig,
  png : Bytes,
  context : String,
  summary : String,
) -> String? {
  if !@wgpu_native.write_file_bytes(config.screenshot_path, png) {
    return Some(config.screenshot_path)
  }
  if !@wgpu_native.write_file_text(config.context_path, context) {
    return Some(config.context_path)
  }
  if !@wgpu_native.write_file_text(config.summary_path, summary) {
    return Some(config.summary_path)
  }
  None
}
