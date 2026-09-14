///|
extern "js" fn js_request_animation_frame(f : () -> Unit) -> Unit =
  #| (f) => { requestAnimationFrame(() => f()); }

///|
extern "js" fn js_on_beforeunload(f : () -> Unit) -> Unit =
  #| (f) => { window.addEventListener("beforeunload", () => f()); }

///|
extern "js" fn js_performance_now() -> Double =
  #| () => (globalThis.performance?.now?.() ?? Date.now())

///|
extern "js" fn js_publish_frame_phases(
  update_ms : Double,
  draw_ms : Double,
  render_ms : Double,
) -> Unit =
  #| (updateMs, drawCallbackMs, renderCommandsMs) => {
  #|   const runtime = globalThis.__kaguraWebRuntime;
  #|   if (!runtime) return;
  #|   const profile = runtime.frameProfile ??= {};
  #|   profile.updateMs = updateMs;
  #|   profile.drawCallbackMs = drawCallbackMs;
  #|   profile.renderCommandsMs = renderCommandsMs;
  #| }

///|
pub fn install() -> Unit {
  @fetch_contract.set_bytes_loader(@web_fetch.fetch_bytes)
  @host.set_clock(js_performance_now)
  @host.set_frame_host({
    request_frame: js_request_animation_frame,
    on_exit: js_on_beforeunload,
    publish_phases: js_publish_frame_phases,
  })
}
