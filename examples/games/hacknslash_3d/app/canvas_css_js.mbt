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

///|
extern "js" fn hunter_web_enabled() -> Bool =
  #| () => globalThis.__ashenControls?.version === 1

///|
extern "js" fn hunter_web_key() -> Int =
  #| () => globalThis.__ashenControls?.consumeKey() ?? 0

///|
extern "js" fn hunter_web_move_x() -> Double =
  #| () => globalThis.__ashenControls?.snapshot().x ?? 0

///|
extern "js" fn hunter_web_move_y() -> Double =
  #| () => globalThis.__ashenControls?.snapshot().y ?? 0

///|
extern "js" fn hunter_web_attacking() -> Bool =
  #| () => globalThis.__ashenControls?.snapshot().attack ?? false

///|
extern "js" fn hunter_web_selection() -> Int =
  #| () => globalThis.__ashenControls?.selection() ?? -1

///|
extern "js" fn hunter_publish_hud_json(value : String) -> Unit =
  #| value => {
  #|   const hud=JSON.parse(value);
  #|   globalThis.__ashenHud=hud;
  #|   globalThis.__ashenUI?.render(hud);
  #| }

///|
fn GameState::publish_hunter_hud(self : GameState) -> Unit {
  hunter_publish_hud_json(self.hunter_hud_view().to_json().stringify())
}
