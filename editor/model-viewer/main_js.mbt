///|
extern "js" fn register(
  load : (String, String, Array[Bytes], String) -> String,
  reset : () -> Unit,
) -> Unit =
  #| (load, reset) => { globalThis.kaguraModel = Object.freeze({apiVersion: 1, load: (...args) => JSON.parse(load(...args)), reset}); }

///|
fn main {
  @web_hooks.install("#app")
  let initial = Ref(@camera3d.OrbitCamera::default())
  let camera = Ref(initial.val)
  register(
    fn(format, json, buffers, text) {
      try {
        let graph = model_graph(format, json, buffers, text)
        let bounds = model_bounds(graph)
        if bounds.triangles == 0 {
          fail("Model contains no triangles")
        }
        initial.val = fitted_camera(bounds, 4.0 / 3.0)
        camera.val = initial.val
        let shader = @gfx.new_shader_handle(
          100,
          @draw3d.shader3d_lit_untextured_wgsl(),
        )
        let pbr = @gfx.new_shader_handle(
          101,
          @draw3d.shader3d_pbr_untextured_wgsl(),
        )
        let lighting = @light3d.LightingEnvironment::new(
          @light3d.DirectionalLight::new(
            @math3d.Vec3::new(-0.5, 1.0, 0.8),
            @math3d.Vec3::new(1.0, 1.0, 1.0),
            0.8,
          ),
          @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.3),
        )
        let prev_x = Ref(0.0)
        let prev_y = Ref(0.0)
        let dragging = Ref(false)
        @engine.run(
          update=fn(input : @core.InputSnapshot) {
            let left = input.pressed_mouse_buttons.contains(0)
            let right = input.pressed_mouse_buttons.contains(2)
            if dragging.val {
              let dx = input.cursor_x - prev_x.val
              let dy = input.cursor_y - prev_y.val
              if left {
                camera.val = camera.val.orbit(dx * -0.005, dy * -0.005)
              }
              if right {
                camera.val = camera.val.pan(
                  -dx * camera.val.distance / 640.0,
                  dy * camera.val.distance / 480.0,
                )
              }
            }
            dragging.val = left || right
            prev_x.val = input.cursor_x
            prev_y.val = input.cursor_y
            if input.wheel_y != 0.0 {
              camera.val = camera.val.with_distance(
                @cmp.maximum(
                  initial.val.near * 10.0,
                  @cmp.minimum(
                    initial.val.far / 2.0,
                    camera.val.distance * @math.exp(input.wheel_y * 0.001),
                  ),
                ),
              )
            }
          },
          draw=fn(ctx) {
            @renderer3d.render_scene3d_graph_to_dst(
              graph,
              camera.val.to_camera3d(),
              lighting~,
              ctx.dst,
              shader,
              ctx.screen_w,
              ctx.screen_h,
              shader3d_pbr=Some(pbr),
            )
          },
          width=640,
          height=480,
          title="Model preview",
          canvas="#app",
        )
        (
          {
            "ok": true,
            "nodes": graph.nodes.length(),
            "triangles": bounds.triangles,
          } : Json).stringify()
      } catch {
        error =>
          ({ "ok": false, "message": error.to_string() } : Json).stringify()
      }
    },
    fn() { camera.val = initial.val },
  )
}
