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
extern "js" fn js_publish_runtime_state(
  frame : Int,
  mode : String,
  enemy_count : Int,
  active_effect_count : Int,
  particle_emitter_count : Int,
) -> Unit =
  #| (frame, mode, enemyCount, activeEffectCount, particleEmitterCount) => {
  #|   const runtime = globalThis.__hacknslash3dRuntime ?? {}
  #|   runtime.frame = frame
  #|   runtime.mode = mode
  #|   runtime.enemyCount = enemyCount
  #|   runtime.activeEffectCount = activeEffectCount
  #|   runtime.particleEmitterCount = particleEmitterCount
  #|   globalThis.__hacknslash3dRuntime = runtime
  #| }

///|
extern "js" fn js_publish_audio_debug_state(
  loaded_count : Int,
  playing_count : Int,
  failed_count : Int,
  last_played_cue : String,
  last_played_state : String,
  muted : Bool,
) -> Unit =
  #| (loadedCount, playingCount, failedCount, lastPlayedCue, lastPlayedState, muted) => {
  #|   const debug = globalThis.__hacknslash3dAudioDebug ?? {}
  #|   debug.loadedCount = loadedCount
  #|   debug.playingCount = playingCount
  #|   debug.failedCount = failedCount
  #|   debug.lastPlayedCue = lastPlayedCue
  #|   debug.lastPlayedState = lastPlayedState
  #|   debug.muted = muted === true
  #|   globalThis.__hacknslash3dAudioDebug = debug
  #| }

///|
fn game_mode_name(mode : @game.GameMode) -> String {
  match mode {
    @game.Title => "title"
    @game.CharacterSelect => "character_select"
    @game.Playing => "playing"
    @game.GameOver => "gameover"
  }
}

///|
fn apply_initial_mode_overrides(
  state : GameState,
  snapshot_mode : String,
  snapshot_frames : Int,
  initial_autoplay_enabled : Bool,
) -> Unit {
  if snapshot_mode == "playing" {
    state.world.mode = @game.Playing
    let frames = snapshot_frames
    for i = 0; i < frames; i = i + 1 {
      state.update(@core.empty_input_snapshot())
    }
  } else if snapshot_mode == "gameover" {
    state.world.mode = @game.GameOver
  } else if snapshot_mode == "character_select" {
    state.world.mode = @game.CharacterSelect
  } else if initial_autoplay_enabled {
    state.world.mode = @game.Playing
  }
  if initial_autoplay_enabled && state.world.mode == @game.Playing {
    state.world.auto_play = true
  }
}

///|
fn build_initial_balance_params(preset_name : String) -> @game.BalanceParams {
  @game.BalanceParams::from_preset(@game.balance_preset_from_name(preset_name))
}

///|
fn build_initial_archetype(name : String) -> @game.CharacterArchetype {
  match @game.character_archetype_from_string(name) {
    Some(archetype) => archetype
    None => @game.default_character_archetype()
  }
}

///|
fn build_initial_build_policy(
  name : String,
) -> @game.ArchetypeBuildPolicy {
  match @game.archetype_build_policy_from_string(name) {
    Some(policy) => policy
    None => @game.default_archetype_build_policy()
  }
}

///|
fn apply_debug_skill_unlocks(state : GameState, unlock_spells : Bool) -> Unit {
  if not(unlock_spells) {
    return
  }
  for skill_id in @game.spell_skill_ids() {
    ignore(state.world.skills.learn_from_levelup(skill_id))
  }
  state.world.refresh_player_stats()
}

///|
fn apply_initial_audio_settings(
  state : GameState,
  initial_audio_muted : Bool,
) -> Unit {
  state.set_audio_muted(initial_audio_muted)
}

///|
///|
extern "js" fn js_random_seed() -> Int =
  #| () => (Math.random() * 2147483647) | 0

///|
fn build_initial_state() -> GameState {
  let initial_balance_params = build_initial_balance_params(
    get_initial_balance_preset_name(),
  )
  let initial_archetype = build_initial_archetype(get_initial_archetype_name())
  let initial_build_policy = build_initial_build_policy(
    get_initial_build_policy_name(),
  )
  let seed = js_random_seed()
  let postfx_config = if get_initial_ssao_enabled() {
    @render_pipeline3d.PostFXConfig::{
      ..@render_pipeline3d.PostFXConfig::default(),
      ssao_config: @render_pipeline3d.SSAOConfig::enabled_default(),
    }
  } else {
    @render_pipeline3d.PostFXConfig::default()
  }
  let state = GameState::new_with_params(
    seed~,
    initial_balance_params,
    postfx_config=postfx_config,
    archetype=initial_archetype,
    build_policy=initial_build_policy,
  )
  state.show_profiler = get_initial_profiler_enabled()
  state.pipeline.set_fxaa_enabled(get_initial_fxaa_enabled())
  state.shadows_enabled = get_initial_shadows_enabled()
  let stress_enemy_count = get_initial_stress_enemy_count()
  if stress_enemy_count > 0 {
    apply_enemy_stress_scenario(state.world, stress_enemy_count)
  }
  apply_initial_mode_overrides(
    state,
    get_snapshot_mode(),
    get_snapshot_frames(),
    get_initial_autoplay_enabled(),
  )
  apply_initial_audio_settings(state, get_initial_audio_muted())
  apply_debug_skill_unlocks(state, get_initial_unlock_spells_enabled())
  state
}

///|
fn install_web_runtime_js() -> Unit {
  @web_hooks.install("#app")
}

///|
let dungeon_floor_texture_image_id : Int = 920

///|
let dungeon_wall_texture_image_id : Int = 921

///|
fn sync_loaded_source_image(image_id : Int, spec : @asset.ImageSpec) -> Unit {
  let binding = @asset.new_source_image_binding(
    image_id,
    spec.width,
    spec.height,
    1,
    Some(@asset.new_source_image_dirty_rect(0, 0, spec.width, spec.height)),
    spec.palette,
    spec.pixels_rgba8,
  )
  ignore(@web_hooks.sync_source_images([binding]))
}

///|
fn load_dungeon_textures_js(state : GameState) -> Unit {
  @asset.fetch_image("./assets/textures/stone_pavers_diff_1k.jpg", fn(
    spec_opt,
  ) {
    match spec_opt {
      Some(spec) => {
        sync_loaded_source_image(dungeon_floor_texture_image_id, spec)
        state.dungeon_floor_texture_image_id = Some(
          dungeon_floor_texture_image_id,
        )
      }
      None =>
        println(
          "Failed to load dungeon floor texture: stone_pavers_diff_1k.jpg",
        )
    }
  })
  @asset.fetch_image("./assets/textures/old_stone_wall_02_diff_1k.jpg", fn(
    spec_opt,
  ) {
    match spec_opt {
      Some(spec) => {
        sync_loaded_source_image(dungeon_wall_texture_image_id, spec)
        state.dungeon_wall_texture_image_id = Some(
          dungeon_wall_texture_image_id,
        )
      }
      None =>
        println(
          "Failed to load dungeon wall texture: old_stone_wall_02_diff_1k.jpg",
        )
    }
  })
}

///|
fn run_game_js(state : GameState, perf_capture_enabled : Bool) -> Unit {
  let snapshot_tick = get_snapshot_tick()
  let rendered_frames : Ref[Int] = Ref::new(0)
  // Fixed 60fps timestep accumulator
  let fixed_dt : Double = 1000.0 / 60.0 // 16.667ms
  let accum : Ref[Double] = Ref::new(0.0)
  let prev_time : Ref[Double] = Ref::new(js_now())
  let last_input : Ref[@core.InputSnapshot] = Ref::new(
    @core.empty_input_snapshot(),
  )
  init_game_audio_js(state)
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
        state.pipeline.config.fxaa_enabled,
        state.shadows_enabled,
        state.pipeline.config.ssao_config.enabled,
      )
      js_publish_runtime_state(
        state.world.frame_count,
        game_mode_name(state.world.mode),
        state.world.enemies.length(),
        state.active_effects.length(),
        state.particle_manager.emitters.length(),
      )
      js_publish_audio_debug_state(
        state.loaded_audio_player_count(),
        state.playing_audio_player_count(),
        state.audio_failed_paths.length(),
        state.audio_last_played_cue,
        state.audio_last_played_state,
        state.audio_muted,
      )
    },
    audio_ctx=state.audio_ctx,
    width=screen_w,
    height=screen_h,
    title="Hack & Slash 3D",
    canvas="#app",
  )
}

///|
fn load_generated_prop_manifest_js(
  state : GameState,
  placements : Array[GeneratedPropPlacement],
  perf_capture_enabled : Bool,
  index : Int,
) -> Unit {
  if index >= placements.length() {
    run_game_js(state, perf_capture_enabled)
    load_dungeon_textures_js(state)
    return
  }
  let placement = placements[index]
  @asset.fetch_bytes(placement.source_path, fn(bytes_opt) {
    match bytes_opt {
      Some(bytes) =>
        match
          parse_generated_prop_asset_from_glb_bytes(
            bytes,
            placement.source_path,
          ) {
          Some(asset) => {
            state.set_generated_prop_asset(asset, placement)
            println("Loaded generated prop: " + placement.source_path)
          }
          None =>
            println("Failed to parse generated prop: " + placement.source_path)
        }
      None =>
        println("Failed to fetch generated prop: " + placement.source_path)
    }
    load_generated_prop_manifest_js(
      state,
      placements,
      perf_capture_enabled,
      index + 1,
    )
  })
}

///|
fn main {
  install_web_runtime_js()
  let perf_capture_enabled = get_initial_perf_capture_enabled()
  let generated_prop_path = get_initial_generated_prop_path()
  let generated_prop_anchor = match
    generated_prop_anchor_from_string(get_initial_generated_prop_anchor_name()) {
    Some(anchor) => anchor
    None => StartRoomCenter
  }
  let generated_prop_role = match
    generated_prop_role_from_string(get_initial_generated_prop_role_name()) {
    Some(role) => role
    None => Decoration
  }
  let generated_prop_pickup_effect = match
    generated_prop_pickup_effect_from_string(
      get_initial_generated_prop_pickup_effect_name(),
    ) {
    Some(effect) => effect
    None => ScorePickup
  }
  let generated_prop_pickup_rarity = generated_prop_item_rarity_from_string(
    get_initial_generated_prop_pickup_rarity_name(),
  )
  let generated_prop_pickup_slot = generated_prop_item_slot_from_string(
    get_initial_generated_prop_pickup_slot_name(),
  )
  let generated_prop_manifest = if generated_prop_path == "none" {
    []
  } else if generated_prop_path.is_empty() {
    default_generated_prop_manifest()
  } else {
    [
      generated_prop_placement(
        generated_prop_path,
        floor=1,
        anchor=generated_prop_anchor,
        role=generated_prop_role,
        pickup_effect=generated_prop_pickup_effect,
        pickup_rarity=generated_prop_pickup_rarity,
        pickup_slot=generated_prop_pickup_slot,
        scale=get_initial_generated_prop_scale(),
        yaw_degrees=get_initial_generated_prop_yaw_degrees(),
        x_offset_tiles=get_initial_generated_prop_x_offset_tiles(),
        z_offset_tiles=get_initial_generated_prop_z_offset_tiles(),
      ),
    ]
  }
  if generated_prop_manifest.is_empty() {
    let state = build_initial_state()
    run_game_js(state, perf_capture_enabled)
    load_dungeon_textures_js(state)
    return
  }
  let state = build_initial_state()
  load_generated_prop_manifest_js(
    state, generated_prop_manifest, perf_capture_enabled, 0,
  )
}
