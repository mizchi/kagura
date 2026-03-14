// Game state construction, update logic, reset

///|
fn half_res_target_size(size : Int) -> Int {
  Int::max(1, size / 2)
}

///|
let key_m : Int = 77

///|
fn GameState::new(seed~ : Int) -> GameState {
  GameState::new_with_params_and_ssao(
    seed~,
    @game.BalanceParams::default(),
    SSAOConfig::disabled_default(),
    archetype=@game.default_character_archetype(),
    build_policy=@game.default_archetype_build_policy(),
  )
}

///|
fn GameState::new_with_ssao(seed~ : Int, ssao_config : SSAOConfig) -> GameState {
  GameState::new_with_params_and_ssao(
    seed~,
    @game.BalanceParams::default(),
    ssao_config,
    archetype=@game.default_character_archetype(),
    build_policy=@game.default_archetype_build_policy(),
  )
}

///|
fn GameState::new_with_params(
  seed~ : Int,
  params : @game.BalanceParams,
  archetype? : @game.CharacterArchetype = @game.default_character_archetype(),
  build_policy? : @game.ArchetypeBuildPolicy = @game.default_archetype_build_policy(),
) -> GameState {
  GameState::new_with_params_and_ssao(
    seed~,
    params,
    SSAOConfig::disabled_default(),
    archetype=archetype,
    build_policy=build_policy,
  )
}

///|
fn GameState::new_with_params_and_ssao(
  seed~ : Int,
  params : @game.BalanceParams,
  ssao_config : SSAOConfig,
  archetype? : @game.CharacterArchetype = @game.default_character_archetype(),
  build_policy? : @game.ArchetypeBuildPolicy = @game.default_archetype_build_policy(),
) -> GameState {
  let world = @game.GameWorld::new(
    seed~,
    params~,
    archetype=archetype,
    build_policy=build_policy,
  )
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let bloom_w = half_res_target_size(screen_w)
  let bloom_h = half_res_target_size(screen_h)
  let init_y = @game.get_tile_height(
    world.dungeon,
    world.player.x,
    world.player.y,
  )
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(
      world.player.x / tile_size,
      init_y,
      world.player.y / tile_size,
    ),
    22.0, // pulled back for wider view
    0.785, // yaw 45 degrees
    1.1, // pitch ~63 degrees (more top-down like PoE)
    @math.PI / 5.0,
    sw / sh,
    0.1,
    100.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.4, -1.0, -0.6),
      @math3d.Vec3::new(1.0, 0.9, 0.7), // warm directional light
      0.85,
    ),
    @light3d.AmbientLight::new(
      @math3d.Vec3::new(0.6, 0.65, 0.8), // cool blue ambient
      0.2,
    ),
  )
  let meshes = Meshes3D::new()
  let dungeon_chunks = build_dungeon_chunks(world.dungeon, meshes)
  let dungeon_tinted_lighting_cache = build_dungeon_tinted_lighting_cache(
    lighting,
  )
  let icon_atlas = create_icon_atlas()
  let shadow_config = @shadow3d.ShadowConfig::new(
    1024, // map_size
    18.0, // half_extent (wider for pulled-back camera)
    0.1, // near
    80.0, // far
    40.0, // distance
    @math3d.Vec3::new(
      world.player.x / tile_size,
      0.0,
      world.player.y / tile_size,
    ), // center (player pos)
    0.005, // bias
  )
  {
    world,
    input: @inpututil.new_input_helper(),
    show_profiler: false,
    profile: @debugutil.default_frame_profile(),
    camera,
    lighting,
    shader3d: @gfx.new_shader_handle(
      100,
      @draw3d.shader3d_lit_untextured_wgsl(),
    ),
    shader3d_textured: @gfx.new_shader_handle(107, @draw3d.shader3d_lit_wgsl()),
    shader3d_pbr: @gfx.new_shader_handle(
      108,
      @draw3d.shader3d_pbr_untextured_wgsl(),
    ),
    shader3d_pbr_textured: @gfx.new_shader_handle(
      109,
      @draw3d.shader3d_pbr_wgsl(),
    ),
    shader3d_colored: @gfx.new_shader_handle(
      103,
      @draw3d.shader3d_lit_colored_wgsl(),
    ),
    shader3d_instanced: @gfx.new_shader_handle(
      102,
      @draw3d.shader3d_lit_instanced_wgsl(),
    ),
    shader3d_instanced_monochrome: @gfx.new_shader_handle(
      106,
      @draw3d.shader3d_lit_instanced_monochrome_wgsl(),
    ),
    shader3d_skinned: @gfx.new_shader_handle(
      101,
      @draw3d.shader3d_lit_skinned_wgsl(),
    ),
    shader3d_skinned_instanced: @gfx.new_shader_handle(
      104,
      @draw3d.shader3d_lit_skinned_instanced_wgsl(),
    ),
    shader3d_skinned_instanced_monochrome: @gfx.new_shader_handle(
      105,
      @draw3d.shader3d_lit_skinned_instanced_monochrome_wgsl(),
    ),
    meshes,
    character: PlayerCharacter::new(),
    enemy_models: EnemyModels::new(),
    enemy_render_buckets: default_enemy_render_buckets(),
    // Shadow mapping
    shadow_map: @gfx.new_image_handle(200, 1024, 1024),
    shadow_depth_shader: @gfx.new_shader_handle(
      200,
      @shadow3d.shader_shadow_depth_wgsl(),
    ),
    shadow_lit_shader: @gfx.new_shader_handle(
      201,
      @shadow3d.shader3d_shadow_lit_untextured_wgsl(),
    ),
    shadow_lit_textured_shader: @gfx.new_shader_handle(
      202,
      @shadow3d.shader3d_shadow_lit_wgsl(),
    ),
    shadows_enabled: false,
    shadow_config,
    dungeon_chunks,
    dungeon_tinted_lighting_cache,
    visible_chunks_cache: [],
    visible_chunk_cache_player_tile_x: -1,
    visible_chunk_cache_player_tile_z: -1,
    visible_chunk_cache_builds: 0,
    visible_dungeon_mesh_cache: {
      groups: [],
      all_mesh: @mesh3d.Mesh3D::new([], []),
    },
    visible_dungeon_mesh_cache_player_tile_x: -1,
    visible_dungeon_mesh_cache_player_tile_z: -1,
    visible_dungeon_mesh_cache_builds: 0,
    generated_props: [],
    active_effects: [],
    damage_popups: [],
    audio_ctx: @audio.MixerAudioContext::new(44100),
    audio_muted: false,
    audio_players: default_game_audio_players(),
    audio_failed_paths: [],
    audio_last_played_cue: "",
    audio_last_played_state: "",
    dungeon_floor_texture_image_id: None,
    dungeon_wall_texture_image_id: None,
    // PostFX render targets
    scene_target: @gfx.new_image_handle(300, screen_w, screen_h),
    bloom_a: @gfx.new_image_handle(301, bloom_w, bloom_h),
    bloom_b: @gfx.new_image_handle(302, bloom_w, bloom_h),
    post_target: @gfx.new_image_handle(303, screen_w, screen_h),
    // PostFX shaders
    bloom_threshold_sh: @gfx.new_shader_handle(
      300,
      @postfx.bloom_threshold_wgsl(),
    ),
    bloom_hblur_sh: @gfx.new_shader_handle(301, @postfx.bloom_blur_wgsl(true)),
    bloom_vblur_sh: @gfx.new_shader_handle(302, @postfx.bloom_blur_wgsl(false)),
    bloom_composite_sh: @gfx.new_shader_handle(
      303,
      @postfx.bloom_composite_wgsl(),
    ),
    fxaa_enabled: false,
    fxaa_sh: @gfx.new_shader_handle(304, @postfx.fxaa_wgsl()),
    tonemap_sh: @gfx.new_shader_handle(305, @postfx.tonemap_wgsl(@postfx.ACES)),
    fog_sh: @gfx.new_shader_handle(308, @postfx.fog_wgsl()),
    // Camera depth (for SSAO)
    camera_depth_target: @gfx.new_image_handle(305, screen_w, screen_h),
    camera_depth_shader: @gfx.new_shader_handle(
      307,
      @shadow3d.shader_camera_depth_wgsl(),
    ),
    // SSAO
    ssao_config,
    ssao_sh: @gfx.new_shader_handle(306, @postfx.ssao_wgsl()),
    ssao_target: @gfx.new_image_handle(304, screen_w, screen_h),
    // Particles
    particle_manager: @particle3d.ParticleManager::new(400),
    // UI icons
    icon_atlas,
    // Text
    text_renderer: None,
    entity_instance_scratch: default_entity_instance_scratch(),
    minimap_static_cmds: [],
    minimap_cache_player_tile_x: -1,
    minimap_cache_player_tile_y: -1,
    minimap_cache_floor: -1,
    minimap_cache_dst_id: -1,
    minimap_cache_shader_id: -1,
    minimap_cache_discovery_version: -1,
    minimap_cache_builds: 0,
    hud_static_cmds: [],
    hud_static_cache_floor: -1,
    hud_static_cache_dst_id: -1,
    hud_static_cache_shader_id: -1,
    hud_static_cache_text_mode: -1,
    hud_static_cache_builds: 0,
  }
}

///|
fn GameState::update(self : GameState, input : @core.InputSnapshot) -> Unit {
  self.world.frame_count = self.world.frame_count + 1
  @inpututil.update_input_helper(self.input, input)
  // Profiler toggle (works in any mode)
  if @inpututil.is_key_just_pressed(self.input.key_state, key_f3) {
    self.show_profiler = not(self.show_profiler)
  }
  // FXAA toggle for visual/perf comparison
  if @inpututil.is_key_just_pressed(self.input.key_state, key_f4) {
    self.fxaa_enabled = not(self.fxaa_enabled)
  }
  // Shadow toggle for visual/perf comparison
  if @inpututil.is_key_just_pressed(self.input.key_state, key_f5) {
    self.shadows_enabled = not(self.shadows_enabled)
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, key_m) {
    self.toggle_audio_muted()
  }
  match self.world.mode {
    @game.Title => self.update_title(input)
    @game.CharacterSelect => self.update_character_select(input)
    @game.Playing => self.update_playing()
    @game.GameOver => self.update_gameover(input)
  }
}

///|
fn GameState::update_title(
  self : GameState,
  input : @core.InputSnapshot,
) -> Unit {
  if input_snapshot_requests_debug_reset(input, self.world.mode) {
    self.reset_save_and_restart()
    return
  }
  if @inpututil.is_confirm_just_pressed(self.input) {
    // Try loading save first
    if self.load_game() {
      self.world.mode = @game.Playing
    } else {
      // No save — go to character select
      self.world.select_cursor = 0
      self.world.mode = @game.CharacterSelect
    }
  }
}

///|
fn GameState::random_seed(self : GameState) -> Int {
  // Use frame count as entropy source for varying seeds between sessions
  let t = self.world.frame_count
  let h = t * 31337 + 137
  (if h < 0 { -h } else { h }) % 100000
}

///|
fn GameState::update_character_select(
  self : GameState,
  _input : @core.InputSnapshot,
) -> Unit {
  let archetypes = @game.selectable_archetypes()
  let count = archetypes.length()
  if @inpututil.is_up_just_pressed(self.input) {
    self.world.select_cursor = (self.world.select_cursor - 1 + count) % count
  }
  if @inpututil.is_down_just_pressed(self.input) {
    self.world.select_cursor = (self.world.select_cursor + 1) % count
  }
  if @inpututil.is_confirm_just_pressed(self.input) {
    let chosen = archetypes[self.world.select_cursor]
    self.world.apply_archetype(chosen)
    self.world.mode = @game.Playing
  }
  // ESC to go back to title
  if @inpututil.is_key_just_pressed(self.input.key_state, key_escape) {
    self.world.mode = @game.Title
  }
}

///|
fn GameState::update_gameover(
  self : GameState,
  input : @core.InputSnapshot,
) -> Unit {
  if input_snapshot_requests_debug_reset(input, self.world.mode) {
    self.reset_save_and_restart()
    return
  }
  if @inpututil.is_confirm_just_pressed(self.input) {
    self.world.mode = @game.Title
    self.world.floor = 1
    self.world.score = 0
    self.world.seed = self.random_seed()
    self.world.apply_dungeon(self.world.seed, 1)
    // Rebuild rendering state after dungeon change
    self.rebuild_dungeon_rendering()
    self.world.player.damage_timer = 0
    self.world.player.iframe_timer = 0
    self.world.floor_announce_timer = 0
    self.world.player.dash_timer = 0
    self.world.player.dash_cooldown_timer = 0
    self.delete_save()
    // Reset RPG state
    self.world.ui_mode = @game.UIMode::None
    self.world.ui_cursor = 0
    for i in 0..<self.world.inventory.capacity {
      self.world.inventory.items[i] = None
    }
    self.world.equipment.weapon = None
    self.world.equipment.armor = None
    self.world.equipment.accessory = None
    for node in self.world.skills.nodes {
      node.level = 0
    }
    self.world.skills.skill_points = 0
    self.world.level_progress = @game.LevelProgression::new(
      config=self.world.params.levelup_config(),
    )
    self.world.player_stats = @game.compute_player_stats(
      self.world.equipment,
      self.world.skills,
      base_hp=self.world.params.player_base_hp.to_int(),
    )
    self.world.player.hp = self.world.player_stats.max_hp
  }
}

///|
fn GameState::update_playing(self : GameState) -> Unit {
  // Auto-play toggle (F2)
  if @inpututil.is_key_just_pressed(self.input.key_state, key_f2) {
    self.world.auto_play = not(self.world.auto_play)
  }
  if self.world.ui_mode == @game.LevelUp {
    self.update_ui()
    return
  }
  // UI toggle
  if @inpututil.is_key_just_pressed(self.input.key_state, key_i) {
    self.world.ui_mode = if self.world.ui_mode == @game.Inventory {
      @game.UIMode::None
    } else {
      @game.Inventory
    }
    self.world.ui_cursor = 0
    return
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, key_k) {
    self.world.ui_mode = if self.world.ui_mode == @game.Skills {
      @game.UIMode::None
    } else {
      @game.Skills
    }
    self.world.ui_cursor = 0
    return
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, key_escape) &&
    self.world.ui_mode != @game.UIMode::None {
    self.world.ui_mode = @game.UIMode::None
    return
  }
  // UI interaction mode
  if self.world.ui_mode != @game.UIMode::None {
    self.update_ui()
    return
  }
  // Determine movement input
  if self.world.auto_play {
    // Auto-play: let world handle everything
    match self.build_generated_prop_enemy_ai_grid() {
      Some(collision_grid) =>
        self.world.tick_auto_with_enemy_ai_grid(collision_grid)
      None => self.world.tick_auto()
    }
  } else {
    // Manual input (camera-relative)
    let mut raw_dx = 0.0
    let mut raw_dy = 0.0
    if @inpututil.is_move_up(self.input.key_state) {
      raw_dy = raw_dy - 1.0
    }
    if @inpututil.is_move_down(self.input.key_state) {
      raw_dy = raw_dy + 1.0
    }
    if @inpututil.is_move_left(self.input.key_state) {
      raw_dx = raw_dx - 1.0
    }
    if @inpututil.is_move_right(self.input.key_state) {
      raw_dx = raw_dx + 1.0
    }
    if raw_dx != 0.0 && raw_dy != 0.0 {
      let v = @vector.Vec2::new(raw_dx, raw_dy).normalize()
      raw_dx = v.x
      raw_dy = v.y
    }
    let yaw = self.camera.yaw
    let cos_yaw = @math.cos(yaw)
    let sin_yaw = @math.sin(yaw)
    let dx = raw_dx * cos_yaw + raw_dy * sin_yaw
    let dy = -raw_dx * sin_yaw + raw_dy * cos_yaw
    // Dash via shift
    let shift_pressed = @inpututil.is_key_just_pressed(
      self.input.key_state,
      key_shift,
    )
    if shift_pressed &&
      self.world.player.dash_cooldown_timer <= 0 &&
      (dx != 0.0 || dy != 0.0) {
      @game.start_dash(self.world, dx, dy)
    }
    // Skill activation: 1/2/3 keys
    if @inpututil.is_key_just_pressed(self.input.key_state, key_1) {
      @game.activate_skill(self.world, 0)
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_2) {
      @game.activate_skill(self.world, 1)
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_3) {
      @game.activate_skill(self.world, 2)
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_4) {
      @game.activate_skill(self.world, 3)
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_5) {
      @game.activate_skill(self.world, 4)
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_6) {
      @game.activate_skill(self.world, 5)
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_7) {
      @game.activate_skill(self.world, 6)
    }
    // Tick world with movement
    match self.build_generated_prop_enemy_ai_grid() {
      Some(collision_grid) =>
        self.world.tick_with_enemy_ai_grid(dx, dy, collision_grid)
      None => self.world.tick(dx, dy)
    }
  }
  self.update_damage_popups()
  // Process events from world tick
  let events = self.world.drain_events()
  for event in events {
    self.play_sound_for_event(event)
    match event {
      @game.HitSparks(x, y) => spawn_hit_sparks(self.particle_manager, x, y)
      @game.DeathBurst(x, y) => spawn_death_burst(self.particle_manager, x, y)
      @game.DashTrail(x, y) => spawn_dash_trail(self.particle_manager, x, y)
      @game.PlayerHurt(x, y) => spawn_player_hurt(self.particle_manager, x, y)
      @game.PlayerDamageNumber(x, y, amount) =>
        self.spawn_damage_popup(x, y, amount, 0xFF7777)
      @game.EnemyDamageNumber(x, y, amount) =>
        self.spawn_damage_popup(x, y, amount, 0xFF4444)
      @game.ItemPickup(x, y, is_health) =>
        spawn_item_pickup(self.particle_manager, x, y, is_health)
      @game.GroundTelegraphRing(x, y, radius) =>
        self.queue_ground_ring_telegraph_effect(x, y, radius)
      @game.GroundTelegraphLine(x0, y0, x1, y1) =>
        self.queue_ground_line_telegraph_effect(x0, y0, x1, y1)
      @game.ChainLightningArc(x0, y0, x1, y1) =>
        self.queue_chain_lightning_effect(x0, y0, x1, y1)
      @game.HomingMissileLaunch(x0, y0, x1, y1) =>
        self.queue_homing_missile_effect(x0, y0, x1, y1)
      @game.HomingMissileTrail(x0, y0, x1, y1) =>
        self.queue_homing_missile_effect(x0, y0, x1, y1)
      @game.HomingMissileImpact(x, y) =>
        self.queue_homing_missile_impact_effect(x, y)
      @game.FireballCast(x, y) => self.queue_fireball_cast_effect(x, y)
      @game.FireballTrail(x, y) =>
        spawn_fireball_trail(self.particle_manager, x, y)
      @game.FireballBurst(x, y) => self.queue_fireball_burst_effect(x, y)
      @game.IceNovaCast(x, y, radius) =>
        self.queue_ice_nova_effect(x, y, radius)
      @game.MeteorCastStart(x, y, radius) => {
        // Large warning telegraph at cast start
        self.queue_ground_ring_telegraph_effect(x, y, radius)
        self.queue_ground_ring_telegraph_effect(x, y, radius * 0.5)
      }
      @game.MeteorImpact(x, y, radius) => {
        // Huge explosion effect
        spawn_death_burst(self.particle_manager, x, y)
        spawn_death_burst(self.particle_manager, x, y)
        self.queue_fireball_burst_effect(x, y)
        self.queue_ground_ring_telegraph_effect(x, y, radius)
        // Damage player if in radius
        let pdx = self.world.player.x - x
        let pdy = self.world.player.y - y
        if pdx * pdx + pdy * pdy <= radius * radius &&
          self.world.player.iframe_timer <= 0 {
          let meteor_dmg = self.world.params.scale_enemy_damage_for_floor(
            self.world.params.enemy_contact_damage.to_int() *
            @game.meteor_damage_mult,
            self.world.floor,
          )
          self.world.deal_player_damage(meteor_dmg)
        }
      }
      @game.AttackTriggered => self.character.trigger_attack()
      @game.HurtTriggered => self.character.trigger_hurt()
      @game.FloorComplete => {
        self.rebuild_dungeon_rendering()
        self.save_game()
      }
    }
  }
  self.apply_generated_prop_roles_for_current_floor()
  // Camera follow (3D: convert 2D coords to 3D with height)
  let cam_y = @game.get_tile_height(
    self.world.dungeon,
    self.world.player.x,
    self.world.player.y,
  )
  self.camera = self.camera.with_target(
    @math3d.Vec3::new(
      self.world.player.x / tile_size,
      cam_y,
      self.world.player.y / tile_size,
    ),
  )
  // Update character animation
  let is_moving = self.world.player.dash_timer > 0 ||
    (
    // check if player moved this frame by seeing if facing angle changed or velocity != 0
    // simpler: check if any movement keys are held
      not(self.world.auto_play) &&
      (
        @inpututil.is_move_up(self.input.key_state) ||
        @inpututil.is_move_down(self.input.key_state) ||
        @inpututil.is_move_left(self.input.key_state) ||
        @inpututil.is_move_right(self.input.key_state)
      )
    ) ||
    self.world.auto_play
  self.character.set_moving(is_moving)
  self.character.update(1.0 / 60.0)
  self.enemy_models.update(1.0 / 60.0)
  // Ambient dust particles (every 15 frames)
  if self.world.frame_count % 15 == 0 {
    spawn_ambient_dust(
      self.particle_manager,
      self.world.player.x,
      self.world.player.y,
      self.world.frame_count,
    )
  }
  self.update_active_effects(1.0 / 60.0)
  // Update particles
  self.particle_manager.update(1.0 / 60.0)
}

///|
fn GameState::spawn_damage_popup(
  self : GameState,
  x : Double,
  y : Double,
  amount : Int,
  color_hex : Int,
) -> Unit {
  self.damage_popups.push({ x, y, amount, color_hex, ttl: 30, rise: 0.0 })
}

///|
fn GameState::update_damage_popups(self : GameState) -> Unit {
  let still_active : Array[DamagePopup] = []
  for popup in self.damage_popups {
    popup.ttl = popup.ttl - 1
    popup.rise = popup.rise + 0.025
    if popup.ttl > 0 {
      still_active.push(popup)
    }
  }
  self.damage_popups = still_active
}

// Rebuild dungeon rendering state after dungeon changes (floor complete, game over reset, load)

///|
fn GameState::rebuild_dungeon_rendering(self : GameState) -> Unit {
  self.dungeon_chunks = build_dungeon_chunks(self.world.dungeon, self.meshes)
  self.dungeon_tinted_lighting_cache = build_dungeon_tinted_lighting_cache(
    self.lighting,
  )
  self.invalidate_visible_chunk_cache()
  self.invalidate_minimap_cache()
  let ry = @game.get_tile_height(
    self.world.dungeon,
    self.world.player.x,
    self.world.player.y,
  )
  self.camera = self.camera.with_target(
    @math3d.Vec3::new(
      self.world.player.x / tile_size,
      ry,
      self.world.player.y / tile_size,
    ),
  )
  self.refresh_generated_props_for_current_floor()
}
