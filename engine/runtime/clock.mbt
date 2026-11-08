///|
let runtime_clock_provider : Ref[(() -> Double)?] = Ref(None)

///|
pub fn set_runtime_clock_provider(clock : () -> Double) -> Unit {
  runtime_clock_provider.val = Some(clock)
}

///|
pub fn reset_runtime_clock_provider() -> Unit {
  runtime_clock_provider.val = None
}

///|
/// Read through the installed host clock, with an optional test override.
pub fn clock_now_ms() -> Double {
  capture_clock()()
}

///|
pub fn capture_clock() -> () -> Double {
  match runtime_clock_provider.val {
    Some(clock) => clock
    None => @services.capture_clock()
  }
}
