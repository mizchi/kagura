///|
pub fn capture_viewport(width : Int32, height : Int32) -> (Int32, Int32) {
  (width, height)
}

///|
pub fn is_native_gpu_capture() -> Bool {
  false
}

///|
pub fn set_gpu_capture_for_test(_enabled : Bool) -> Unit {

}

///|
fn requested_initial_state() -> String? {
  None
}

///|
fn record_initial_state_failure(_message : String) -> Unit {

}
