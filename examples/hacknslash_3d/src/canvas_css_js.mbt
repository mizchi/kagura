///|
extern "js" fn js_canvas_css_width() -> Double =
  #| () => {
  #|   const state = globalThis.__kaguraWebRuntime;
  #|   if (state == null || state.canvas == null) return 640;
  #|   const rect = state.canvas.getBoundingClientRect();
  #|   return rect.width > 0 ? rect.width : 640;
  #| }

///|
extern "js" fn js_canvas_css_height() -> Double =
  #| () => {
  #|   const state = globalThis.__kaguraWebRuntime;
  #|   if (state == null || state.canvas == null) return 480;
  #|   const rect = state.canvas.getBoundingClientRect();
  #|   return rect.height > 0 ? rect.height : 480;
  #| }

///|
fn canvas_css_width() -> Double {
  js_canvas_css_width()
}

///|
fn canvas_css_height() -> Double {
  js_canvas_css_height()
}
