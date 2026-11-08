///|
suberror InjectedStartupFailure {
  InjectedStartupFailure
}

///|
struct StartupGraphics {
  fail : String
  stages : Array[String]
}

///|
impl @gfx.GraphicsDriver for StartupGraphics with fn initialize(self) {
  self.stages.push("graphics")
  if self.fail == "graphics" {
    raise InjectedStartupFailure
  }
}

///|
impl @gfx.GraphicsDriver for StartupGraphics with fn new_image(
  self,
  width,
  height,
) {
  self.stages.push("image")
  if self.fail == "image" {
    raise InjectedStartupFailure
  }
  @gfx.new_image_handle(42, width, height)
}

///|
impl @gfx.GraphicsDriver for StartupGraphics with fn new_shader(self, source) {
  self.stages.push("shader")
  if self.fail == "shader" {
    raise InjectedStartupFailure
  }
  @gfx.new_shader_handle(43, source)
}

///|
impl @gfx.GraphicsDriver for StartupGraphics with fn begin(_self, _pass) {
  ()
}

///|
impl @gfx.GraphicsDriver for StartupGraphics with fn end(_self, _present) {
  ()
}

///|
impl @gfx.GraphicsDriver for StartupGraphics with fn resize(
  _self,
  _width,
  _height,
) {
  ()
}

///|
impl @gfx.GraphicsDriver for StartupGraphics with fn draw_triangles(
  _self,
  _command,
) {
  ()
}

///|
impl @gfx.GraphicsDriver for StartupGraphics with fn read_pixels(
  _self,
  _x,
  _y,
  _width,
  _height,
) {
  None
}

///|
test "startup failure stops at each failing allocation and releases acquired backend" {
  for
    (stage, failure) in [
      (Surface, "surface"),
      (Graphics, "graphics"),
      (Image, "image"),
      (Shader, "shader"),
    ] {
    let errors : Array[RunFailure] = []
    let releases = Ref(0)
    let session = RunSession::new(on_error=fn(error) { errors.push(error) })
    session.own(fn() { releases.val += 1 })
    let stages : Array[String] = []
    let platform = @platform.create_web_canvas_platform("#fake")
    let result = initialize_session(
      session,
      platform,
      () => {
        stages.push("surface")
        if failure == "surface" {
          raise InjectedStartupFailure
        }
        @gfx.create_offscreen_surface_token(32, 24)
      },
      fn(_surface) { StartupGraphics::{ fail: failure, stages, } },
      32,
      24,
      "test",
    )
    assert_true(result is None)
    assert_eq(errors.length(), 1)
    assert_eq(errors[0].stage, stage)
    assert_eq(stages[stages.length() - 1], failure)
    assert_eq(releases.val, 1)
    session.step()
    assert_eq(releases.val, 1)
  }
}

///|
test "pending GPU startup never calls game callbacks and failed GPU reports once" {
  let errors : Array[RunFailure] = []
  let session = RunSession::new(on_error=fn(error) { errors.push(error) })
  let probe : Ref[StartupReadiness] = Ref(Pending)
  let calls = Ref(0)
  let platform = @platform.create_web_canvas_platform("#fake")
  let graphics = StartupGraphics::{ fail: "", stages: [], }
  let ctx : EngineContext = {
    dst: @gfx.new_image_handle(42, 320, 240),
    shader: @gfx.new_shader_handle(43, ""),
    screen_w: 320,
    screen_h: 240,
  }
  configure_session(
    session,
    platform,
    graphics,
    ctx,
    fn() { probe.val },
    fn(_) { calls.val += 1 },
    fn(_) {
      calls.val += 10
      []
    },
    None,
    None,
    None,
    735,
  )
  session.step()
  assert_eq(calls.val, 0)
  probe.val = Unavailable("adapter rejected")
  session.step()
  session.step()
  assert_eq(calls.val, 0)
  assert_eq(errors.length(), 1)
  assert_eq(errors[0].stage, Graphics)
}

///|
test "startup owns the captured lifecycle even if the registration is later replaced" {
  let a = Ref(0)
  let b = Ref(0)
  set_lifecycle_hooks({
    on_start: fn(_, _) { () },
    on_stop: fn() { a.val += 1 },
  })
  let session = RunSession::new()
  assert_true(begin_session(session, "#fake", "test") is Some(_))
  set_lifecycle_hooks({
    on_start: fn(_, _) { () },
    on_stop: fn() { b.val += 1 },
  })
  session.stop()
  assert_eq(a.val, 1)
  assert_eq(b.val, 0)
  reset_lifecycle_hooks()
}

///|
test "session closes audio output only when it acquired it" {
  for acquired in [true, false] {
    let closes = Ref(0)
    @audio.set_audio_output_hooks(
      @audio.new_audio_output_hooks(
        fn(_) { acquired },
        fn(_, frames) { frames },
        fn() { () },
        fn() { () },
        fn() { closes.val += 1 },
      ),
    )
    let session = RunSession::new()
    let platform = @platform.create_web_canvas_platform("#fake")
    let graphics = StartupGraphics::{ fail: "", stages: [], }
    let ctx : EngineContext = {
      dst: @gfx.new_image_handle(42, 320, 240),
      shader: @gfx.new_shader_handle(43, ""),
      screen_w: 320,
      screen_h: 240,
    }
    configure_session(
      session,
      platform,
      graphics,
      ctx,
      fn() { Ready },
      fn(_) { () },
      fn(_) { [] },
      None,
      None,
      Some(@audio.MixerAudioContext::new(44100)),
      735,
    )
    session.step()
    session.stop()
    session.stop()
    assert_eq(closes.val, if acquired { 1 } else { 0 })
    @audio.reset_audio_output_hooks()
  }
}
