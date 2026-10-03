///|
let presentation_capture : Ref[Bool?] = Ref(None)

///|
fn native_capture_enabled() -> Bool {
  if presentation_capture.val is None {
    presentation_capture.val = Some(
      @capture.read_native_capture_text(
        @capture.capture_config_filename,
        config=true,
      )
      is Some(_),
    )
  }
  presentation_capture.val == Some(true)
}

///|
fn presentation_clock_ms() -> Double? {
  if native_capture_enabled() {
    None
  } else {
    Some(@runtime.clock_now_ms())
  }
}

///|
fn prefers_reduced_motion() -> Bool? {
  None
}

///|
fn Game::surface_input(
  self : Game,
  input : @core.InputSnapshot,
) -> @core.InputSnapshot {
  let normalized = if native_capture_enabled() {
    input
  } else {
    @ui.navigation_input_from_glfw(input)
  }
  scale_pointer_input(
    normalized,
    self.layout.w,
    self.layout.h,
    self.layout.w,
    self.layout.h,
  )
}
