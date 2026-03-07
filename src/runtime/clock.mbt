///|
#cfg(target="native")
extern "C" fn native_runtime_clock_now_ms() -> Double = "kagura_runtime_now_ms"

///|
#cfg(target="js")
extern "js" fn js_runtime_clock_now_ms() -> Double =
  #|() => (globalThis.performance?.now?.() ?? Date.now())

///|
#cfg(target="native")
fn default_runtime_clock_now_ms() -> Double {
  native_runtime_clock_now_ms()
}

///|
#cfg(target="js")
fn default_runtime_clock_now_ms() -> Double {
  js_runtime_clock_now_ms()
}

///|
#cfg(any(target="wasm", target="wasm-gc"))
fn default_runtime_clock_now_ms() -> Double {
  0.0
}

///|
let runtime_clock_provider : Ref[() -> Double] = Ref::new(
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
