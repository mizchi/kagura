///|
/// Start an owned session. Inspect status() or on_error for startup failures.
pub fn start(
  update~ : (@core.InputSnapshot) -> Unit,
  draw~ : (EngineContext) -> Array[@gfx.DrawTrianglesCommand],
  on_frame? : () -> Unit,
  after_render? : (Double, Double) -> Unit,
  audio_ctx? : @audio.MixerAudioContext,
  audio_frames_per_tick~ : Int32 = 735,
  width~ : Int32 = 320,
  height~ : Int32 = 240,
  title~ : String = "kagura",
  canvas~ : String = "",
  on_error~ : (RunFailure) -> Unit = default_run_error,
) -> RunSession {
  let session = RunSession::new(on_error~)
  if try_run_native_capture(update~, draw~, on_frame?, width~, height~) {
    session.stop()
    return session
  }
  let probe = match begin_session(session, canvas, title) {
    Some(probe) => probe
    None => return session
  }
  let platform = @platform.create_desktop_glfw_platform()
  match
    initialize_session(
      session,
      platform,
      () => platform.current_surface(),
      fn(surface) {
        @gfx.create_wgpu_native_graphics(
          surface,
          @gfx.default_graphics_backend_options(),
        )
      },
      width,
      height,
      title,
    ) {
    Some((graphics, ctx)) =>
      configure_session(
        session, platform, graphics, ctx, probe, update, draw, on_frame, after_render,
        audio_ctx, audio_frames_per_tick,
      )
    None => return session
  }
  session
}

///|
pub fn run(
  update~ : (@core.InputSnapshot) -> Unit,
  draw~ : (EngineContext) -> Array[@gfx.DrawTrianglesCommand],
  on_frame? : () -> Unit,
  after_render? : (Double, Double) -> Unit,
  audio_ctx? : @audio.MixerAudioContext,
  audio_frames_per_tick~ : Int32 = 735,
  width~ : Int32 = 320,
  height~ : Int32 = 240,
  title~ : String = "kagura",
  canvas~ : String = "",
  on_error~ : (RunFailure) -> Unit = default_run_error,
) -> Unit {
  let session = start(
    update~,
    draw~,
    on_frame?,
    after_render?,
    audio_ctx?,
    audio_frames_per_tick~,
    width~,
    height~,
    title~,
    canvas~,
    on_error~,
  )
  while session.is_active() {
    session.step()
  }
}
