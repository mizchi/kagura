// The web runtime reports cursor coords in canvas CSS pixels, which differ from
// the logical (screen_w x screen_h) layout space when the canvas is displayed at
// a smaller CSS size than its internal resolution. Expose the canvas CSS size so
// the update loop can scale clicks back into logical coordinates. The native
// build (viewport_native.mbt) reports the logical size, so the scale is a no-op.

///|
extern "js" fn js_canvas_css_w() -> Double =
  #| () => { const c = globalThis.document?.querySelector("canvas"); return c ? c.getBoundingClientRect().width : 0; }

///|
extern "js" fn js_canvas_css_h() -> Double =
  #| () => { const c = globalThis.document?.querySelector("canvas"); return c ? c.getBoundingClientRect().height : 0; }

///|
fn canvas_css_w() -> Double {
  js_canvas_css_w()
}

///|
fn canvas_css_h() -> Double {
  js_canvas_css_h()
}

///|
extern "js" fn requested_capture_dimension(key : String, fallback : Int) -> Int =
  #| (key, fallback) => {
  #|   const value = globalThis.__kaguraHeadless?.[key];
  #|   return Number.isFinite(value) && value > 0 ? Math.floor(value) : fallback;
  #| }

///|
fn initial_screen_w() -> Int {
  requested_capture_dimension("width", screen_w)
}

///|
fn initial_screen_h() -> Int {
  requested_capture_dimension("height", screen_h)
}
