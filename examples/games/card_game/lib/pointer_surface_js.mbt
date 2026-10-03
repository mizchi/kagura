///|
extern "js" fn surface_width(fallback : Double) -> Double =
  #| fallback => globalThis.document?.querySelector('#app')?.getBoundingClientRect().width || fallback

///|
extern "js" fn surface_height(fallback : Double) -> Double =
  #| fallback => globalThis.document?.querySelector('#app')?.getBoundingClientRect().height || fallback

///|
extern "js" fn host_presentation_clock_ms() -> Double =
  #| () => globalThis.__kaguraHeadless ? -1 : (globalThis.performance?.now() ?? -1)

///|
fn presentation_clock_ms() -> Double? {
  let now = host_presentation_clock_ms()
  if now < 0.0 {
    None
  } else {
    Some(now)
  }
}

///|
extern "js" fn host_reduced_motion() -> Int =
  #| () => globalThis.matchMedia ? (globalThis.matchMedia('(prefers-reduced-motion: reduce)').matches ? 1 : 0) : -1

///|
fn prefers_reduced_motion() -> Bool? {
  let preference = host_reduced_motion()
  if preference < 0 {
    None
  } else {
    Some(preference == 1)
  }
}

///|
fn Game::surface_input(
  self : Game,
  input : @core.InputSnapshot,
) -> @core.InputSnapshot {
  if surface_cancelled() {
    self.cancel_card()
    self.combat_focus = None
    self.hint = "CANCELLED"
    return @core.new_input_snapshot_full(-1.0, -1.0, 0.0, 0.0, [], [], [], [])
  }
  // Headless inputs are already expressed in logical coordinates.
  scale_pointer_input(
    input,
    self.layout.w,
    self.layout.h,
    surface_width(self.layout.w),
    surface_height(self.layout.h),
  )
}

///|
extern "js" fn surface_cancelled() -> Bool =
  #| () => {
  #|   let tracker = globalThis.__emberSurfaceCancel;
  #|   if (!tracker) {
  #|     tracker = globalThis.__emberSurfaceCancel = { cancelled: false };
  #|     const cancel = () => { tracker.cancelled = true; };
  #|     globalThis.addEventListener?.('blur', cancel);
  #|     globalThis.document?.addEventListener('visibilitychange', () => {
  #|       if (document.hidden) cancel();
  #|     });
  #|     const canvas = globalThis.document?.querySelector('#app');
  #|     canvas?.addEventListener('keydown', event => {
  #|       // Canvas modal focus is logical; keep the browser focus on its surface.
  #|       const modal = globalThis.__kaguraUISnapshot?.parsed?.nodes?.some(node => node.role === 'dialog');
  #|       if (event.code === 'Tab' && modal) event.preventDefault();
  #|     });
  #|     canvas?.addEventListener('pointercancel', cancel);
  #|     canvas?.addEventListener('touchcancel', cancel);
  #|   }
  #|   const cancelled = tracker.cancelled;
  #|   tracker.cancelled = false;
  #|   return cancelled;
  #| }
