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
extern "js" fn hunter_web_camera_command() -> Array[Double] =
  #| () => globalThis.__ashenCamera?.consumeCommand() ?? []

///|
extern "js" fn hunter_web_terrain_command() -> Array[Double] =
  #| () => globalThis.__ashenTerrain?.consume() ?? []

///|
extern "js" fn hunter_terrain_clock() -> Double =
  #| () => globalThis.performance?.now() ?? Date.now()

///|
extern "js" fn hunter_save_terrain_preferences(value : String) -> Unit =
  #| value => { try { localStorage.setItem('ashen-hunt-terrain-v1',value); } catch {} }

///|
extern "js" fn hunter_load_terrain_preferences() -> String =
  #| () => { try { return localStorage.getItem('ashen-hunt-terrain-v1') ?? ''; } catch { return ''; } }

///|
extern "js" fn hunter_initial_terrain() -> Array[Double] =
  #| () => {
  #|   const q=new URLSearchParams(globalThis.location?.search??'');
  #|   const pattern=['flat','perlin','diamond','voronoi','hybrid'].indexOf(q.get('terrain'));
  #|   return pattern<0?[]:[pattern,Number(q.get('terrain_seed')??q.get('seed')??42),Number(q.get('relief')??4),Number(q.get('terrain_scale')??18),Number(q.get('roughness')??.5)];
  #| }

///|
extern "js" fn hunter_web_camera_look() -> Array[Double] =
  #| () => globalThis.__ashenCamera?.consumeLook() ?? []

///|
extern "js" fn hunter_load_camera_preferences() -> String =
  #| () => { try { return localStorage.getItem('ashen-hunt-camera-v1') ?? ''; } catch { return ''; } }

///|
extern "js" fn hunter_save_camera_preferences(value : String) -> Unit =
  #| value => globalThis.__ashenCamera?.save(value)

///|
fn canvas_css_height() -> Double {
  js_canvas_css_height()
}

///|
extern "js" fn hunter_web_enabled() -> Bool =
  #| () => globalThis.__ashenControls?.version === 1

///|
extern "js" fn hunter_web_key() -> Int =
  #| () => { globalThis.__ashenGamepad?.poll(); return globalThis.__ashenControls?.consumeKey() ?? 0; }

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

///|
extern "js" fn hunter_web_inventory_move() -> Array[Int] =
  #| () => {
  #|   const move=globalThis.__ashenControls?.inventoryMove();
  #|   return move ? [move.source, move.target, move.x, move.y, move.rotated ? 1 : 0] : [];
  #| }

///|
extern "js" fn hunter_web_whirlwind_pressed() -> Bool =
  #| () => globalThis.__ashenControls?.consumeWhirlwindPress() ?? false

///|
extern "js" fn hunter_web_whirling() -> Bool =
  #| () => globalThis.__ashenControls?.snapshot().whirlwind ?? false

///|
extern "js" fn hunter_web_guarding() -> Bool =
  #| () => globalThis.__ashenControls?.snapshot().guard ?? false

///|
extern "js" fn hunter_web_target_x() -> Double =
  #| () => globalThis.__ashenControls?.targetPoint()?.x ?? -1

///|
extern "js" fn hunter_web_target_y() -> Double =
  #| () => globalThis.__ashenControls?.targetPoint()?.y ?? -1

///|
extern "js" fn hunter_web_target_confirmed() -> Bool =
  #| () => globalThis.__ashenControls?.targetConfirmed() ?? false

///|
extern "js" fn hunter_web_pointer_x() -> Double =
  #| () => globalThis.__ashenControls?.pointerAim()?.x ?? -1

///|
extern "js" fn hunter_web_pointer_y() -> Double =
  #| () => globalThis.__ashenControls?.pointerAim()?.y ?? -1

///|
extern "js" fn hunter_web_stick_aim() -> Array[Double] =
  #| () => { const p=globalThis.__ashenControls?.stickAim(); return p?[p.x,p.y]:[]; }

///|
extern "js" fn hunter_web_ground_stick() -> Array[Double] =
  #| () => { const p=globalThis.__ashenControls?.groundStick(); return p?[p.x,p.y]:[]; }
