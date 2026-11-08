///|
let wasm_session : Ref[RunSession?] = Ref(None)

///|
pub fn kagura_frame() -> Unit {
  match wasm_session.val {
    Some(session) => session.step()
    None => ()
  }
}

///|
pub fn kagura_stop() -> Unit {
  let current = wasm_session.val
  match current {
    Some(session) => session.stop()
    None => ()
  }
}

///|
/// Raw host state: 0 starting, 1 running, 2 stopped, 3 failed.
pub fn kagura_session_status() -> Int32 {
  match wasm_session.val {
    None => 2
    Some(session) =>
      match session.status() {
        Starting => 0
        Running => 1
        Stopped => 2
        Failed(_) => 3
      }
  }
}

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
  canvas~ : String = "#app",
  on_error~ : (RunFailure) -> Unit = default_run_error,
) -> RunSession {
  let session = RunSession::new(on_error~)
  match wasm_session.val {
    None => wasm_session.val = Some(session)
    Some(current) =>
      if !current.is_active() {
        wasm_session.val = Some(session)
      }
  }
  let probe = match begin_session(session, canvas, title) {
    Some(probe) => probe
    None => return session
  }
  let platform = @platform.create_web_canvas_platform(canvas)
  match
    initialize_session(
      session,
      platform,
      () => platform.current_surface(),
      fn(surface) {
        @gfx.create_webgpu_graphics(
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
  if session.is_active() {
    wasm_session.val = Some(session)
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
  canvas~ : String = "#app",
  on_error~ : (RunFailure) -> Unit = default_run_error,
) -> Unit {
  let _ = start(
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
}
