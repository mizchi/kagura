///|
fn default_runtime_clock_now_ms() -> Double {
  @services.now_ms()
}

///|
let runtime_clock_provider : Ref[() -> Double] = Ref(
  default_runtime_clock_now_ms,
)

///|
pub fn set_runtime_clock_provider(clock : () -> Double) -> Unit {
  runtime_clock_provider.val = clock
}

///|
pub fn reset_runtime_clock_provider() -> Unit {
  runtime_clock_provider.val = default_runtime_clock_now_ms
}

///|
/// Read through the installed host clock, with an optional test override.
pub fn clock_now_ms() -> Double {
  (runtime_clock_provider.val)()
}
