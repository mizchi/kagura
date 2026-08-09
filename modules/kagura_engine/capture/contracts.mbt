// ============================================================
// Native frame capture
// ============================================================
//
// The plumbing a headless capture needs, independent of what is being drawn:
// read where the artifacts go, turn a readback buffer into a PNG, and write the
// three files the review tooling expects.
//
// This was previously private to the 3D authoring example. Generalising it is
// what lets a 2D UI example capture frames too, which is the missing input for
// the deterministic UI gates (`scripts/ui-integrity-gate.mjs`) and for
// `vlmkit diff png` — the web canvas capture and the Linux Dawn readback are
// both unusable, so native capture is the portable path.
//
// Everything here is target-agnostic; reading and writing files lives in the
// `native` sub-package, which is native-only.

///|
/// Config file a capture driver stages next to the example before running it.
/// See `tools/modeling3d/scripts/model-authoring-native-capture-utils.mjs`.
pub let capture_config_filename : String = "kagura_native_capture_config.txt"

///|
pub(all) struct CaptureConfig {
  /// Where the frame PNG goes.
  screenshot_path : String
  /// Where the machine-readable context (UI snapshot, model document) goes.
  context_path : String
  /// Where the human-readable one-liner summary goes.
  summary_path : String
  /// Reduce the frame to black and white. Silhouette review reads shape more
  /// reliably without colour.
  binarize : Bool
} derive(Debug)

///|
pub impl Show for CaptureConfig with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// Decode config bytes as ASCII.
///
/// The config is written by the capture driver and only ever holds paths and
/// flags, so a byte-per-char read is sufficient and avoids pulling a UTF-8
/// decoder into the native build.
pub fn capture_bytes_to_string(data : Bytes) -> String {
  let chars : Array[Char] = []
  for i in 0..<data.length() {
    chars.push(data[i].to_int().unsafe_to_char())
  }
  String::from_array(chars)
}

///|
fn parse_config_entries(text : String) -> Map[String, String] {
  let entries : Map[String, String] = Map([])
  let mut line = StringBuilder::new()
  let commit = fn() {
    let trimmed = line.to_string().trim().to_owned()
    line = StringBuilder::new()
    if trimmed.is_empty() {
      return
    }
    let chars = trimmed.to_array()
    let mut split_index = -1
    for i in 0..<chars.length() {
      if chars[i] == '=' {
        split_index = i
        break
      }
    }
    // No `=`, or an empty key: not an assignment, so skip rather than guess.
    if split_index <= 0 {
      return
    }
    let key_chars : Array[Char] = []
    let value_chars : Array[Char] = []
    for i in 0..<split_index {
      key_chars.push(chars[i])
    }
    for i in (split_index + 1)..<chars.length() {
      value_chars.push(chars[i])
    }
    let key = String::from_array(key_chars).trim().to_owned()
    let value = String::from_array(value_chars).trim().to_owned()
    if !key.is_empty() {
      entries[key] = value
    }
  }
  for ch in text {
    if ch == '\n' || ch == '\r' {
      commit()
    } else {
      line.write_char(ch)
    }
  }
  commit()
  entries
}

///|
fn config_bool(entries : Map[String, String], key : String) -> Bool {
  match entries.get(key) {
    Some("1") => true
    Some("true") => true
    Some("TRUE") => true
    _ => false
  }
}

///|
/// Parse a staged capture config.
///
/// Returns `None` when a required path is missing, rather than aborting: a
/// driver that mis-stages the file gets to say so, which is a great deal easier
/// to diagnose than a bare panic from inside a headless run.
pub fn parse_capture_config(text : String) -> CaptureConfig? {
  let entries = parse_config_entries(text)
  match
    (
      entries.get("screenshot_path"),
      entries.get("context_path"),
      entries.get("summary_path"),
    ) {
    (Some(screenshot_path), Some(context_path), Some(summary_path)) =>
      if screenshot_path.is_empty() ||
        context_path.is_empty() ||
        summary_path.is_empty() {
        None
      } else {
        Some({
          screenshot_path,
          context_path,
          summary_path,
          binarize: config_bool(entries, "binarize"),
        })
      }
    _ => None
  }
}

///|
/// Rec. 601 luma threshold at mid-grey, in integer arithmetic.
pub fn binarize_luma(r : Int, g : Int, b : Int) -> Int {
  if r * 30 + g * 59 + b * 11 >= 12800 {
    255
  } else {
    0
  }
}

///|
/// Reduce an RGBA8 buffer to black and white in place, leaving alpha alone.
pub fn binarize_rgba8(pixels : Array[Int]) -> Unit {
  let mut i = 0
  while i + 3 < pixels.length() {
    let v = binarize_luma(pixels[i], pixels[i + 1], pixels[i + 2])
    pixels[i] = v
    pixels[i + 1] = v
    pixels[i + 2] = v
    i = i + 4
  }
}

///|
/// Encode an RGBA8 buffer as PNG, or `None` when the encoder rejects it.
pub fn encode_rgba8_png(
  width : Int,
  height : Int,
  pixels : Array[Int],
) -> Bytes? {
  Some(
    @atlas.encode_png_image_spec(
      @atlas.image_spec_with_rgba8(width, height, pixels),
    ),
  ) catch {
    _ => None
  }
}
