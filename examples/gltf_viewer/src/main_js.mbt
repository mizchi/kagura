///|
extern "js" fn js_fetch_bytes(url : String, cb : (Bytes) -> Unit) -> Unit =
  #| (url, cb) => { fetch(url).then(r=>r.arrayBuffer()).then(b=>cb(new Uint8Array(b))); }

///|
fn main {
  @web_hooks.install("#app")
  js_fetch_bytes("./assets/test_scene.glb", fn(data) {
    let (json, buffers) = try {
      @gltf.parse_glb(data)
    } catch {
      _ => {
        println("Failed to parse GLB")
        return
      }
    }
    let graph = try {
      @gltf.scene_graph_from_gltf(json, buffers)
    } catch {
      _ => {
        println("Failed to build scene graph")
        return
      }
    }
    let state = ViewerState::new(graph)
    let prev_x : Ref[Double] = Ref::new(0.0)
    let prev_y : Ref[Double] = Ref::new(0.0)
    @engine.run(
      update=fn(input) { state.update(input, prev_x, prev_y) },
      draw=fn(ctx) { state.draw(ctx) },
      width=screen_w,
      height=screen_h,
      title="glTF Viewer",
      canvas="#app",
    )
  })
}
