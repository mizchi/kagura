///|
extern "js" fn js_fetch_bytes(url : String, cb : (Bytes) -> Unit) -> Unit =
  #| (url, cb) => { fetch(url).then(r=>r.arrayBuffer()).then(b=>cb(new Uint8Array(b))); }

///|
extern "js" fn js_get_query_param(key : String) -> String =
  #| (key) => new URLSearchParams(location.search).get(key) ?? ""

///|
extern "js" fn js_get_query_param_bool(
  key : String,
  default_val : Bool,
) -> Bool =
  #| (key, defaultVal) => {
  #|   const v = new URLSearchParams(location.search).get(key)
  #|   if (v == null) return defaultVal
  #|   return v === "1" || v === "true" || v === "on"
  #| }

///|
fn get_initial_asset_query() -> String {
  js_get_query_param("asset")
}

///|
fn get_initial_hud_enabled() -> Bool {
  js_get_query_param_bool("hud", true)
}

///|
fn start_viewer(graph : @scene3d.SceneGraph, show_hud : Bool) -> Unit {
  let state = ViewerState::new(graph, show_hud~)
  let prev_x : Ref[Double] = Ref::new(0.0)
  let prev_y : Ref[Double] = Ref::new(0.0)
  @engine.run(
    update=fn(input) { state.update(input, prev_x, prev_y) },
    draw=fn(ctx) { state.draw(ctx) },
    width=screen_w,
    height=screen_h,
    title="Fal Trellis Demo",
    canvas="#app",
  )
}

///|
fn main {
  @web_hooks.install("#app")
  let show_hud = get_initial_hud_enabled()
  match sample_asset_source_from_query_param(get_initial_asset_query()) {
    DefaultGlb(path) =>
      js_fetch_bytes(path, fn(data) {
        let (json, buffers) = @gltf.parse_glb(data) catch {
          _ => {
            println("Failed to parse GLB")
            return
          }
        }
        let graph = @gltf.scene_graph_from_gltf(json, buffers) catch {
          _ => {
            println("Failed to build scene graph")
            return
          }
        }
        start_viewer(graph, show_hud)
      })
  }
}
