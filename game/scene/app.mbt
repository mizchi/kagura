///|
pub fn run(
  view~ : () -> SceneNode,
  update~ : (@core.InputSnapshot) -> Unit,
  on_frame? : (
    Array[@gfx.DrawTrianglesCommand],
    @gfx.ImageHandle,
    @gfx.ShaderHandle,
    Double,
    Double,
  ) -> Unit,
  snapshot_state? : () -> String,
  apply_viewport? : (Int, Int) -> Unit,
  audio_ctx? : @audio.MixerAudioContext,
  width? : Int = 320,
  height? : Int = 240,
  title? : String = "kagura",
  canvas? : String = "#app",
) -> Unit {
  let (width, height) = @engine.capture_viewport(width, height)
  match apply_viewport {
    Some(apply) => apply(width, height)
    None => ()
  }
  // Use the game's logical size for scene coordinate space,
  // not the canvas backing size (which may be scaled by DPR).
  let logical_w = width.to_double()
  let logical_h = height.to_double()
  @engine.run(
    update~,
    draw=fn(ctx) {
      let tree = view()
      let state = match snapshot_state {
        Some(name) => name()
        None => "scene"
      }
      publish_scene_snapshot(
        ui_snapshot_from_scene(
          tree,
          screen_width=logical_w,
          screen_height=logical_h,
          state~,
        ),
      )
      let cmds = render_scene(tree, ctx.dst, ctx.shader, logical_w, logical_h)
      match on_frame {
        Some(f) => f(cmds, ctx.dst, ctx.shader, logical_w, logical_h)
        None => ()
      }
      cmds
    },
    audio_ctx?,
    width~,
    height~,
    title~,
    canvas~,
  )
}
