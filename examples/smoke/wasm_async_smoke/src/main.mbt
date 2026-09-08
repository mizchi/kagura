// Smoke test for running `moonbitlang/async` on the wasm1 target under a
// minimal JavaScript host (`lib/web/wasm-async-host.mjs`).
//
// It pins two things at once:
//
//   - async's own host contract: 48 imports, of which only a handful need a
//     real implementation for timers to work (see the host for the list);
//   - that kagura's `kagura_web` host namespace coexists with it, so a guest
//     can talk to both the async runtime and the engine's host ABI.

///|
/// Same namespace and function the engine's wasm frame loop imports, so this
/// test fails if the two host contracts ever stop composing.
extern "wasm" fn host_now_ms() -> Double = "kagura_web" "now_ms"

///|
async fn main {
  println("wasm_async_smoke: start")
  let before = host_now_ms()
  @async.with_task_group(g => {
    // A background task that outlives the foreground sleep proves the event
    // loop really multiplexes rather than running the timers in order.
    g.spawn_bg(() => {
      @async.sleep(30)
      println("wasm_async_smoke: background task woke")
    })
    @async.sleep(10)
    println("wasm_async_smoke: foreground task woke")
  })
  let after = host_now_ms()
  // The host clock has to advance across the sleeps; a stubbed-out `now_ms`
  // returning a constant would fail here.
  println("wasm_async_smoke: host clock advanced=\{after > before}")
  println("wasm_async_smoke: ok")
}
