// The web runtime reports cursor coords in canvas CSS pixels, which differ from
// the logical (screen_w x screen_h) layout space when the canvas is displayed at
// a smaller CSS size than its internal resolution. Expose the canvas CSS size so
// the update loop can scale clicks back into logical coordinates. The native
// build (viewport_native.mbt) reports the logical size, so the scale is a no-op.

///|
extern "js" fn js_canvas_css_w() -> Double =
  #| () => { const c = document.querySelector("canvas"); return c ? c.getBoundingClientRect().width : 0; }

///|
extern "js" fn js_canvas_css_h() -> Double =
  #| () => { const c = document.querySelector("canvas"); return c ? c.getBoundingClientRect().height : 0; }

///|
fn canvas_css_w() -> Double {
  js_canvas_css_w()
}

///|
fn canvas_css_h() -> Double {
  js_canvas_css_h()
}
