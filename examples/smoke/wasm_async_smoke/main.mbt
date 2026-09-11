// Smoke test for running `moonbitlang/async` on the wasm1 target under a
// minimal JavaScript host (`assets/web/wasm-async-host.mjs`).
//
// It pins three things:
//
//   - async's own host contract: 48 imports, of which only a handful need a
//     real implementation for timers to work (see the host for the list);
//   - that kagura's `kagura_web` host namespace coexists with it, so a guest
//     can talk to both the async runtime and the engine's host ABI;
//   - that a frame source on the other side of `event_bus/wait` reaches the
//     guest -- which is what makes the Worker split in
//     `assets/web/wasm-async-driver.mjs` work.

///|
/// Same namespace and function the engine's wasm frame loop imports, so this
/// test fails if the two host contracts ever stop composing.
extern "wasm" fn host_now_ms() -> Double = "kagura_web" "now_ms"

///|
/// Frames the host has driven so far. Zero when nothing is driving the guest.
extern "wasm" fn host_frame_number() -> Int = "kagura_web" "frame_number"

///|
/// Waits for the host to drive `target` frames, giving up after `budget_ms`.
///
/// The budget is what lets one binary serve both callers: run under the plain
/// host and nothing ever advances the counter, so this spends the budget in
/// sleeps and reports 0; run under the worker driver and it returns as soon as
/// the main thread has ticked enough times.
async fn observe_frames(target : Int, budget_ms : Int) -> Int {
  let start = host_frame_number()
  let deadline = host_now_ms() + budget_ms.to_double()
  while host_now_ms() < deadline {
    let seen = host_frame_number() - start
    if seen >= target {
      return seen
    }
    // Sleeping is the point: each sleep parks the loop in `event_bus/wait`,
    // which is where the host gets to wake us on a frame.
    @async.sleep(4)
  }
  host_frame_number() - start
}

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
  let frames = observe_frames(5, 500)
  println("wasm_async_smoke: frames observed=\{frames}")
  println("wasm_async_smoke: ok")
}
