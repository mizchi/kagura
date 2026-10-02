///|
extern "js" fn surface_width(fallback : Double) -> Double =
  #| fallback => globalThis.document?.querySelector('#app')?.getBoundingClientRect().width || fallback

///|
extern "js" fn surface_height(fallback : Double) -> Double =
  #| fallback => globalThis.document?.querySelector('#app')?.getBoundingClientRect().height || fallback

///|
fn Game::surface_input(
  self : Game,
  input : @core.InputSnapshot,
) -> @core.InputSnapshot {
  if surface_cancelled() {
    return @core.new_input_snapshot_full(-1.0, -1.0, 0.0, 0.0, [27], [], [], [])
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
  #|     canvas?.addEventListener('pointercancel', cancel);
  #|     canvas?.addEventListener('touchcancel', cancel);
  #|   }
  #|   const cancelled = tracker.cancelled;
  #|   tracker.cancelled = false;
  #|   return cancelled;
  #| }
