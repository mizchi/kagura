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
  audio_ctx? : @audio.MixerAudioContext,
  width? : Int = 320,
  height? : Int = 240,
  title? : String = "kagura",
  canvas? : String = "#app",
) -> Unit {
  // Use the game's logical size for scene coordinate space,
  // not the canvas backing size (which may be scaled by DPR).
  let logical_w = width.to_double()
  let logical_h = height.to_double()
  @engine.run(
    update~,
    draw=fn(ctx) {
      let cmds = render_scene(view(), ctx.dst, ctx.shader, logical_w, logical_h)
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
