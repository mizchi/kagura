///|
fn[P : @platform.PlatformDriver, G : @gfx.GraphicsDriver] initialize_session(
  session : RunSession,
  platform : P,
  get_surface : () -> @gfx.SurfaceToken raise,
  create_graphics : (@gfx.SurfaceToken) -> G,
  width : Int32,
  height : Int32,
  title : String,
) -> (G, EngineContext)? {
  let mut stage = Options
  try {
    if width <= 0 || height <= 0 {
      session.fail(stage, "Viewport dimensions must be positive")
      return None
    }
    stage = Platform
    platform.initialize(
      @platform.new_window_options(title, width, height, false, true),
    )
    stage = Surface
    let surface = get_surface()
    let graphics = create_graphics(surface)
    stage = Graphics
    graphics.initialize()
    stage = Image
    let dst = graphics.new_image(width, height)
    stage = Shader
    let shader = graphics.new_shader(@gfx.default_builtin_shader_source())
    Some((graphics, { dst, shader, screen_w: width, screen_h: height, }))
  } catch {
    error => {
      session.fail(stage, error.to_string())
      None
    }
  }
}

///|
fn[P : @platform.PlatformDriver, G : @gfx.GraphicsDriver] configure_session(
  session : RunSession,
  platform : P,
  graphics : G,
  ctx : EngineContext,
  readiness : () -> StartupReadiness,
  update : (@core.InputSnapshot) -> Unit,
  draw : (EngineContext) -> Array[@gfx.DrawTrianglesCommand],
  on_frame : (() -> Unit)?,
  after_render : ((Double, Double) -> Unit)?,
  audio_ctx : @audio.MixerAudioContext?,
  audio_frames_per_tick : Int32,
) -> Unit {
  if audio_frames_per_tick <= 0 {
    session.fail(Audio, "audio_frames_per_tick must be positive")
    return
  }
  let tick = Ref(0)
  let audio_tick_ms = audio_frames_per_tick.to_double() / 44100.0 * 1000.0
  let accumulated = Ref(0.0)
  let previous = Ref(session.now_ms())
  let host = @services.capture_frame_host()
  session.set_frame(fn() {
    let mut stage = Graphics
    try {
      match readiness() {
        Pending => return
        Unavailable(message) => {
          session.fail(Graphics, message)
          return
        }
        Ready =>
          if session.state is Starting {
            session.ready()
            previous.val = session.now_ms()
            stage = Audio
            match audio_ctx {
              Some(_) =>
                if @audio.audio_try_initialize(@audio.default_audio_format()) {
                  session.own(fn() { @audio.audio_close() })
                }
              None => ()
            }
          }
      }
      stage = Input
      if platform.should_close() {
        session.stop()
        return
      }
      platform.poll_events()
      stage = Resize
      let outside = platform.outside_size()
      let width = outside.width.to_int()
      let height = outside.height.to_int()
      if width > 0 &&
        height > 0 &&
        (width != ctx.screen_w || height != ctx.screen_h) {
        graphics.resize(width, height)
        let image = graphics.new_image(width, height)
        ctx.dst = image
        ctx.screen_w = width
        ctx.screen_h = height
      }
      stage = Update
      let input = platform.capture_input(tick.val)
      tick.val += 1
      let update_start = session.now_ms()
      update(input)
      if !session.is_active() {
        return
      }
      match on_frame {
        Some(callback) => callback()
        None => ()
      }
      if !session.is_active() {
        return
      }
      stage = Draw
      let draw_start = session.now_ms()
      let commands = draw(ctx)
      if !session.is_active() {
        return
      }
      let draw_end = session.now_ms()
      stage = Render
      render_commands(graphics, commands)
      let render_end = session.now_ms()
      match host {
        Some(host) =>
          (host.publish_phases)(
            draw_start - update_start,
            draw_end - draw_start,
            render_end - draw_end,
          )
        None => ()
      }
      match after_render {
        Some(callback) => callback(draw_end - draw_start, render_end - draw_end)
        None => ()
      }
      if !session.is_active() {
        return
      }
      stage = Audio
      let now = session.now_ms()
      let elapsed = (now - previous.val).max(0.0)
      previous.val = now
      match audio_ctx {
        Some(audio) => {
          @audio.audio_resume()
          accumulated.val += elapsed
          while accumulated.val >= audio_tick_ms {
            let _ = @audio.audio_render_and_write(audio, audio_frames_per_tick)
            audio.tick_bgm(audio_frames_per_tick)
            accumulated.val -= audio_tick_ms
          }
        }
        None => ()
      }
    } catch {
      error => session.fail(stage, error.to_string())
    }
  })
}
