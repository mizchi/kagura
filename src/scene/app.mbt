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
  @engine.run(
    update~,
    draw=fn(ctx) {
      let sw = ctx.screen_w.to_double()
      let sh = ctx.screen_h.to_double()
      let cmds = render_scene(view(), ctx.dst, ctx.shader, sw, sh)
      match on_frame {
        Some(f) => f(cmds, ctx.dst, ctx.shader, sw, sh)
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
