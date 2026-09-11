///|
struct CaptureRequest {
  width : Int
  height : Int
  frames : Int
  inputs : Array[HeadlessInputStep]
  initial_state : String?
} derive(FromJson)

///|
priv suberror InvalidCaptureRequest {
  InvalidCaptureRequest(String)
}

///|
fn parse_capture_request(text : String) -> CaptureRequest raise {
  let request : CaptureRequest = @json.from_json(@json.parse(text))
  if request.width < 1 ||
    request.height < 1 ||
    request.width > 4096 ||
    request.height > 4096 ||
    request.width * request.height > 4194304 ||
    request.frames < 1 ||
    request.frames > 600 ||
    request.inputs.length() > request.frames {
    raise InvalidCaptureRequest(
      "Invalid capture dimensions, frames or input length",
    )
  }
  if request.initial_state is Some(name) && !valid_initial_state_name(name) {
    raise InvalidCaptureRequest("Invalid initial state name")
  }
  request
}

///|
fn CaptureRequest::input_at(
  self : CaptureRequest,
  tick : Int,
) -> @core.InputSnapshot {
  if tick < 0 || tick >= self.inputs.length() {
    return headless_input_snapshot(default_headless_input())
  }
  self.inputs[tick].to_input()
}
