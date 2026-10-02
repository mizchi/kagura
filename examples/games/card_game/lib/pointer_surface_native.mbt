///|
let presentation_capture : Ref[Bool?] = Ref(None)

///|
fn presentation_clock_ms() -> Double? {
  if presentation_capture.val is None {
    presentation_capture.val = Some(
      @capture.read_native_capture_text(
        @capture.capture_config_filename,
        config=true,
      )
      is Some(_),
    )
  }
  if presentation_capture.val == Some(true) {
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
  scale_pointer_input(
    input,
    self.layout.w,
    self.layout.h,
    self.layout.w,
    self.layout.h,
  )
}
