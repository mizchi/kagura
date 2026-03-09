// Game state construction, update logic, reset

///|
fn GameState::new(seed~ : Int) -> GameState {
  let world = @game.GameWorld::new(seed~)
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
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
    16.0, // closer to player
    0.785, // yaw 45 degrees
    0.96, // pitch ~55 degrees
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
  let icon_atlas = create_icon_atlas()
  let shadow_config = @shadow3d.ShadowConfig::new(
    1024, // map_size
    14.0, // half_extent
    0.1, // near
    60.0, // far
    30.0, // distance
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
    shader3d_skinned: @gfx.new_shader_handle(
      101,
      @draw3d.shader3d_lit_skinned_wgsl(),
    ),
    meshes,
    character: PlayerCharacter::new(),
    enemy_models: EnemyModels::new(),
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
    shadow_config,
    dungeon_chunks,
    // PostFX render targets
    scene_target: @gfx.new_image_handle(300, screen_w, screen_h),
    bloom_a: @gfx.new_image_handle(301, screen_w, screen_h),
    bloom_b: @gfx.new_image_handle(302, screen_w, screen_h),
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
    fxaa_sh: @gfx.new_shader_handle(304, @postfx.fxaa_wgsl()),
    tonemap_sh: @gfx.new_shader_handle(305, @postfx.tonemap_wgsl(@postfx.ACES)),
    // Camera depth (for SSAO)
    camera_depth_target: @gfx.new_image_handle(305, screen_w, screen_h),
    camera_depth_shader: @gfx.new_shader_handle(
      307,
      @shadow3d.shader_camera_depth_wgsl(),
    ),
    // SSAO
    ssao_sh: @gfx.new_shader_handle(306, @postfx.ssao_wgsl()),
    ssao_target: @gfx.new_image_handle(304, screen_w, screen_h),
    // Particles
    particle_manager: @particle3d.ParticleManager::new(400),
    // UI icons
    icon_atlas,
    // Text
    text_renderer: None,
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
  match self.world.mode {
    @game.Title => self.update_title()
    @game.Playing => self.update_playing()
    @game.GameOver => self.update_gameover()
  }
}

///|
fn GameState::update_title(self : GameState) -> Unit {
  if @inpututil.is_confirm_just_pressed(self.input) {
    // Try loading save first
    if not(self.load_game()) {
      // No save — fresh start
    }
    self.world.mode = @game.Playing
  }
}

///|
fn GameState::update_gameover(self : GameState) -> Unit {
  if @inpututil.is_confirm_just_pressed(self.input) {
    self.world.mode = @game.Title
    self.world.floor = 1
    self.world.score = 0
    self.world.seed = 42
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
    self.world.player_stats = @game.compute_player_stats(
      self.world.equipment,
      self.world.skills,
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
    self.world.tick_auto()
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
    // Tick world with movement
    self.world.tick(dx, dy)
  }
  // Process events from world tick
  let events = self.world.drain_events()
  for event in events {
    match event {
      @game.HitSparks(x, y) => spawn_hit_sparks(self.particle_manager, x, y)
      @game.DeathBurst(x, y) => spawn_death_burst(self.particle_manager, x, y)
      @game.DashTrail(x, y) => spawn_dash_trail(self.particle_manager, x, y)
      @game.PlayerHurt(x, y) => spawn_player_hurt(self.particle_manager, x, y)
      @game.ItemPickup(x, y, is_health) =>
        spawn_item_pickup(self.particle_manager, x, y, is_health)
      @game.AttackTriggered => self.character.trigger_attack()
      @game.HurtTriggered => self.character.trigger_hurt()
      @game.FloorComplete => {
        self.rebuild_dungeon_rendering()
        self.save_game()
      }
    }
  }
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
  // Update particles
  self.particle_manager.update(1.0 / 60.0)
}

// Rebuild dungeon rendering state after dungeon changes (floor complete, game over reset, load)

///|
fn GameState::rebuild_dungeon_rendering(self : GameState) -> Unit {
  self.dungeon_chunks = build_dungeon_chunks(self.world.dungeon, self.meshes)
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
}
