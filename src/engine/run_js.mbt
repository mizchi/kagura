///|
extern "js" fn js_request_animation_frame(f : () -> Unit) -> Unit =
  #| (f) => { requestAnimationFrame(() => f()); }

///|
extern "js" fn js_on_beforeunload(f : () -> Unit) -> Unit =
  #| (f) => { window.addEventListener("beforeunload", () => f()); }

///|
extern "js" fn js_performance_now() -> Double =
  #| () => (globalThis.performance?.now?.() ?? Date.now())

///|
pub fn run(
  update~ : (@core.InputSnapshot) -> Unit,
  draw~ : (EngineContext) -> Array[@gfx.DrawTrianglesCommand],
  on_frame? : () -> Unit,
  after_render? : (Double, Double) -> Unit,
  audio_ctx? : @audio.MixerAudioContext,
  audio_frames_per_tick? : Int = 735,
  width? : Int = 320,
  height? : Int = 240,
  title? : String = "kagura",
  canvas? : String = "#app",
) -> Unit {
  invoke_on_start(canvas, title)
  let platform = @platform.create_web_canvas_platform(canvas)
  let surface = platform.current_surface() catch {
    _ => @platform.create_offscreen_surface_token(width, height)
  }
  let graphics = @gfx.create_webgpu_graphics(
    surface,
    @gfx.default_graphics_backend_options(),
  )
  platform.initialize(
    @platform.new_window_options(title, width, height, false, true),
  ) catch {
    e => println("[engine] platform.initialize failed: \{e}")
  }
  graphics.initialize() catch {
    e => println("[engine] graphics.initialize failed: \{e}")
  }
  let shader_source = @gfx.default_builtin_shader_source()
  let dst = graphics.new_image(width, height) catch {
    e => {
      println("[engine] graphics.new_image failed: \{e}")
      @gfx.new_image_handle(1, width, height)
    }
  }
  let shader = graphics.new_shader(shader_source) catch {
    e => {
      println("[engine] graphics.new_shader failed: \{e}")
      @gfx.new_shader_handle(1, shader_source)
    }
  }
  let ctx : EngineContext = { dst, shader, screen_w: width, screen_h: height }
  let tick : Ref[Int] = Ref::new(0)
  match audio_ctx {
    Some(_) => {
      let _ = @audio.audio_try_initialize(@audio.default_audio_format())
    }
    None => ()
  }
  // Audio accumulator: tick audio at fixed intervals independent of frame rate
  let audio_tick_ms = audio_frames_per_tick.to_double() / 44100.0 * 1000.0
  let audio_accum : Ref[Double] = Ref::new(0.0)
  let prev_time : Ref[Double] = Ref::new(js_performance_now())
  fn frame() {
    platform.poll_events()
    // Resize tracking
    let outside = platform.outside_size()
    let new_w = outside.width.to_int()
    let new_h = outside.height.to_int()
    if new_w > 0 &&
      new_h > 0 &&
      (new_w != ctx.screen_w || new_h != ctx.screen_h) {
      graphics.resize(new_w, new_h) catch {
        e => println("[engine] graphics.resize failed: \{e}")
      }
      ctx.screen_w = new_w
      ctx.screen_h = new_h
      ctx.dst = graphics.new_image(new_w, new_h) catch {
        e => {
          println("[engine] graphics.new_image (resize) failed: \{e}")
          @gfx.new_image_handle(ctx.dst.id, new_w, new_h)
        }
      }
    }
    let input = platform.capture_input(tick.val)
    tick.val = tick.val + 1
    update(input)
    match on_frame {
      Some(f) => f()
      None => ()
    }
    let draw_callback_start = js_performance_now()
    let cmds = draw(ctx)
    let draw_callback_end = js_performance_now()
    let render_start = js_performance_now()
    @debugutil.render_commands(graphics, cmds) catch {
      e => println("[engine] render_commands failed: \{e}")
    }
    let render_end = js_performance_now()
    match after_render {
      Some(f) =>
        f(draw_callback_end - draw_callback_start, render_end - render_start)
      None => ()
    }
    // Time-based audio ticking
    let now = js_performance_now()
    let elapsed = now - prev_time.val
    prev_time.val = now
    match audio_ctx {
      Some(actx) => {
        @audio.audio_resume()
        audio_accum.val = audio_accum.val + elapsed
        while audio_accum.val >= audio_tick_ms {
          let _ = @audio.audio_render_and_write(actx, audio_frames_per_tick)
          actx.tick_bgm(audio_frames_per_tick)
          audio_accum.val = audio_accum.val - audio_tick_ms
        }
      }
      None => ()
    }
    js_request_animation_frame(frame)
  }
  js_on_beforeunload(fn() { invoke_on_stop() })
  js_request_animation_frame(frame)
}
