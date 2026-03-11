///|
extern "js" fn js_now() -> Double =
  #| () => (globalThis.performance?.now?.() ?? Date.now())

///|
extern "js" fn js_consume_gpu_frame_ms() -> Double =
  #| () => (globalThis.__kaguraGfx?.consumeGpuFrameMs?.() ?? -1.0)

///|
extern "js" fn js_configure_detailed_render_timing(enabled : Bool) -> Unit =
  #| (enabled) => { globalThis.__kaguraGfx?.configureDetailedCpuTiming?.(enabled === true) }

///|
extern "js" fn js_last_render_encode_cpu_ms() -> Double =
  #| () => (globalThis.__kaguraGfx?.lastRenderEncodeCpuMs?.() ?? 0.0)

///|
extern "js" fn js_last_render_upload_cpu_ms() -> Double =
  #| () => (globalThis.__kaguraGfx?.lastRenderUploadCpuMs?.() ?? 0.0)

///|
extern "js" fn js_last_render_bind_group_cpu_ms() -> Double =
  #| () => (globalThis.__kaguraGfx?.lastRenderBindGroupCpuMs?.() ?? 0.0)

///|
extern "js" fn js_last_render_pass_encode_cpu_ms() -> Double =
  #| () => (globalThis.__kaguraGfx?.lastRenderPassEncodeCpuMs?.() ?? 0.0)

///|
extern "js" fn js_last_render_acquire_cpu_ms() -> Double =
  #| () => (globalThis.__kaguraGfx?.lastRenderAcquireCpuMs?.() ?? 0.0)

///|
extern "js" fn js_last_render_pass_setup_cpu_ms() -> Double =
  #| () => (globalThis.__kaguraGfx?.lastRenderPassSetupCpuMs?.() ?? 0.0)

///|
extern "js" fn js_last_render_draw_encode_cpu_ms() -> Double =
  #| () => (globalThis.__kaguraGfx?.lastRenderDrawEncodeCpuMs?.() ?? 0.0)

///|
extern "js" fn js_last_render_cleanup_cpu_ms() -> Double =
  #| () => (globalThis.__kaguraGfx?.lastRenderCleanupCpuMs?.() ?? 0.0)

///|
extern "js" fn js_last_render_submit_cpu_ms() -> Double =
  #| () => (globalThis.__kaguraGfx?.lastRenderSubmitCpuMs?.() ?? 0.0)

///|
extern "js" fn js_install_longtask_observer() -> Unit =
  #| () => {
  #|   const state = globalThis.__hacknslash3dLongTaskState ??= {
  #|     installed: false,
  #|     totalCount: 0,
  #|     totalDuration: 0,
  #|     lastPublishedCount: 0,
  #|     lastPublishedDuration: 0,
  #|   }
  #|   if (state.installed) return
  #|   state.installed = true
  #|   if (typeof globalThis.PerformanceObserver !== "function") return
  #|   try {
  #|     const observer = new PerformanceObserver((list) => {
  #|       for (const entry of list.getEntries()) {
  #|         state.totalCount += 1
  #|         state.totalDuration += entry.duration ?? 0
  #|       }
  #|     })
  #|     observer.observe({ type: "longtask", buffered: true })
  #|     state.observer = observer
  #|   } catch (_) {}
  #| }

///|
extern "js" fn js_publish_profiler_state(
  fps : Double,
  frame_time_ms : Double,
  update_ms : Double,
  draw_ms : Double,
  draw_callback_ms : Double,
  render_commands_ms : Double,
  render_upload_cpu_ms : Double,
  render_bind_group_cpu_ms : Double,
  render_pass_encode_cpu_ms : Double,
  render_acquire_cpu_ms : Double,
  render_pass_setup_cpu_ms : Double,
  render_draw_encode_cpu_ms : Double,
  render_cleanup_cpu_ms : Double,
  render_encode_cpu_ms : Double,
  render_submit_cpu_ms : Double,
  gpu_frame_ms : Double,
  draw_calls : Int,
  vertex_count : Int,
  asset_inflight : Int,
  world_frame : Int,
  fxaa_enabled : Bool,
  shadows_enabled : Bool,
  ssao_enabled : Bool,
) -> Unit =
  #| (
  #|   fps,
  #|   frameTimeMs,
  #|   updateMs,
  #|   drawMs,
  #|   drawCallbackMs,
  #|   renderCommandsMs,
  #|   renderUploadCpuMs,
  #|   renderBindGroupCpuMs,
  #|   renderPassEncodeCpuMs,
  #|   renderAcquireCpuMs,
  #|   renderPassSetupCpuMs,
  #|   renderDrawEncodeCpuMs,
  #|   renderCleanupCpuMs,
  #|   renderEncodeCpuMs,
  #|   renderSubmitCpuMs,
  #|   gpuFrameMs,
  #|   drawCalls,
  #|   vertexCount,
  #|   assetInflight,
  #|   worldFrame,
  #|   fxaaEnabled,
  #|   shadowsEnabled,
  #|   ssaoEnabled,
  #| ) => {
  #|   const profile = globalThis.__hacknslash3dProfile ?? {}
  #|   const longTaskState = globalThis.__hacknslash3dLongTaskState
  #|   const totalLongTaskCount = longTaskState?.totalCount ?? 0
  #|   const totalLongTaskDuration = longTaskState?.totalDuration ?? 0
  #|   const longTaskCount = totalLongTaskCount - (longTaskState?.lastPublishedCount ?? 0)
  #|   const longTaskMs = totalLongTaskDuration - (longTaskState?.lastPublishedDuration ?? 0)
  #|   if (longTaskState != null) {
  #|     longTaskState.lastPublishedCount = totalLongTaskCount
  #|     longTaskState.lastPublishedDuration = totalLongTaskDuration
  #|   }
  #|   profile.fps = fps
  #|   profile.frameTimeMs = frameTimeMs
  #|   profile.updateMs = updateMs
  #|   profile.drawMs = drawMs
  #|   profile.drawCallbackMs = drawCallbackMs
  #|   profile.renderCommandsMs = renderCommandsMs
  #|   profile.renderUploadCpuMs = renderUploadCpuMs
  #|   profile.renderBindGroupCpuMs = renderBindGroupCpuMs
  #|   profile.renderPassEncodeCpuMs = renderPassEncodeCpuMs
  #|   profile.renderAcquireCpuMs = renderAcquireCpuMs
  #|   profile.renderPassSetupCpuMs = renderPassSetupCpuMs
  #|   profile.renderDrawEncodeCpuMs = renderDrawEncodeCpuMs
  #|   profile.renderCleanupCpuMs = renderCleanupCpuMs
  #|   profile.renderEncodeCpuMs = renderEncodeCpuMs
  #|   profile.renderSubmitCpuMs = renderSubmitCpuMs
  #|   profile.gpuFrameMs = gpuFrameMs
  #|   profile.longTaskCount = longTaskCount
  #|   profile.longTaskMs = longTaskMs
  #|   profile.gpuTimingMethod = globalThis.__kaguraGfx?.gpuTimingMethod?.() ?? "queue-completion"
  #|   profile.gpuTimestampRawNs = globalThis.__kaguraGfx?.lastTimestampRawDeltaNs?.() ?? "0"
  #|   profile.drawCalls = drawCalls
  #|   profile.vertexCount = vertexCount
  #|   profile.assetInflight = assetInflight
  #|   profile.worldFrame = worldFrame
  #|   profile.fxaaEnabled = fxaaEnabled
  #|   profile.shadowsEnabled = shadowsEnabled
  #|   profile.ssaoEnabled = ssaoEnabled
  #|   globalThis.__hacknslash3dProfile = profile
  #| }

///|
fn main {
  let state = if get_initial_ssao_enabled() {
    GameState::new_with_ssao(seed=42, SSAOConfig::enabled_default())
  } else {
    GameState::new(seed=42)
  }
  let perf_capture_enabled = get_initial_perf_capture_enabled()
  state.show_profiler = get_initial_profiler_enabled()
  state.fxaa_enabled = get_initial_fxaa_enabled()
  state.shadows_enabled = get_initial_shadows_enabled()
  let stress_enemy_count = get_initial_stress_enemy_count()
  if stress_enemy_count > 0 {
    apply_enemy_stress_scenario(state.world, stress_enemy_count)
  }
  let snapshot_mode = get_snapshot_mode()
  if snapshot_mode == "playing" {
    state.world.mode = @game.Playing
    let frames = get_snapshot_frames()
    for i = 0; i < frames; i = i + 1 {
      state.update(@core.empty_input_snapshot())
    }
  } else if snapshot_mode == "gameover" {
    state.world.mode = @game.GameOver
  }
  let snapshot_tick = get_snapshot_tick()
  let rendered_frames : Ref[Int] = Ref::new(0)
  // Fixed 60fps timestep accumulator
  let fixed_dt : Double = 1000.0 / 60.0 // 16.667ms
  let accum : Ref[Double] = Ref::new(0.0)
  let prev_time : Ref[Double] = Ref::new(js_now())
  let last_input : Ref[@core.InputSnapshot] = Ref::new(
    @core.empty_input_snapshot(),
  )
  js_configure_detailed_render_timing(
    state.show_profiler || perf_capture_enabled,
  )
  if perf_capture_enabled {
    js_install_longtask_observer()
  }
  @engine.run(
    update=fn(input) {
      last_input.val = input
      let frame_start = js_now()
      let elapsed = frame_start - prev_time.val
      prev_time.val = frame_start
      // Cap accumulated time to avoid spiral of death (max 3 updates)
      accum.val = accum.val + @cmp.minimum(elapsed, fixed_dt * 3.0)
      while accum.val >= fixed_dt {
        state.update(input)
        accum.val = accum.val - fixed_dt
      }
      let update_end = js_now()
      let frame_time_ms = @cmp.maximum(elapsed, 0.0)
      let fps = if frame_time_ms > 0.0 { 1000.0 / frame_time_ms } else { 0.0 }
      let completed_gpu_frame_ms = js_consume_gpu_frame_ms()
      state.profile = {
        fps,
        frame_time_ms,
        update_ms: update_end - frame_start,
        draw_ms: state.profile.draw_ms,
        gpu_frame_ms: if completed_gpu_frame_ms >= 0.0 {
          completed_gpu_frame_ms
        } else {
          state.profile.gpu_frame_ms
        },
        draw_calls: state.profile.draw_calls,
        vertex_count: state.profile.vertex_count,
        asset_inflight: state.profile.asset_inflight,
      }
    },
    draw=fn(ctx) {
      let draw_start = js_now()
      let cmds = state.draw(ctx)
      let draw_end = js_now()
      let mut vertex_count = 0
      for cmd in cmds {
        vertex_count = vertex_count + cmd.indices.length()
      }
      state.profile = {
        fps: state.profile.fps,
        frame_time_ms: state.profile.frame_time_ms,
        update_ms: state.profile.update_ms,
        draw_ms: draw_end - draw_start,
        gpu_frame_ms: state.profile.gpu_frame_ms,
        draw_calls: cmds.length(),
        vertex_count,
        asset_inflight: state.profile.asset_inflight,
      }
      if snapshot_tick > 0 {
        rendered_frames.val = rendered_frames.val + 1
        js_set_snapshot_tick(rendered_frames.val)
      }
      cmds
    },
    after_render=fn(draw_callback_ms, render_commands_ms) {
      js_publish_profiler_state(
        state.profile.fps,
        state.profile.frame_time_ms,
        state.profile.update_ms,
        state.profile.draw_ms,
        draw_callback_ms,
        render_commands_ms,
        js_last_render_upload_cpu_ms(),
        js_last_render_bind_group_cpu_ms(),
        js_last_render_pass_encode_cpu_ms(),
        js_last_render_acquire_cpu_ms(),
        js_last_render_pass_setup_cpu_ms(),
        js_last_render_draw_encode_cpu_ms(),
        js_last_render_cleanup_cpu_ms(),
        js_last_render_encode_cpu_ms(),
        js_last_render_submit_cpu_ms(),
        state.profile.gpu_frame_ms,
        state.profile.draw_calls,
        state.profile.vertex_count,
        state.profile.asset_inflight,
        state.world.frame_count,
        state.fxaa_enabled,
        state.shadows_enabled,
        state.ssao_config.enabled,
      )
    },
    width=screen_w,
    height=screen_h,
    title="Hack & Slash 3D",
    canvas="#app",
  )
}
