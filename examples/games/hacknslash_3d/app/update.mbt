// Game state construction, update logic, reset

///|
let key_m : Int = 77

///|
let key_p : Int = 80

///|
fn GameState::new(seed~ : Int) -> GameState {
  GameState::new_with_params(
    seed~,
    @game.BalanceParams::default(),
    archetype=@game.default_character_archetype(),
    build_policy=@game.default_archetype_build_policy(),
  )
}

///|
fn GameState::new_with_ssao(
  seed~ : Int,
  ssao_config : @render_pipeline3d.SSAOConfig,
) -> GameState {
  GameState::new_with_params(
    seed~,
    @game.BalanceParams::default(),
    postfx_config=@render_pipeline3d.PostFXConfig::{
      ..@render_pipeline3d.PostFXConfig::default(),
      ssao_config,
    },
    archetype=@game.default_character_archetype(),
    build_policy=@game.default_archetype_build_policy(),
  )
}

///|
fn GameState::new_with_params(
  seed~ : Int,
  params : @game.BalanceParams,
  postfx_config? : @render_pipeline3d.PostFXConfig = @render_pipeline3d.PostFXConfig::default(),
  archetype? : @game.CharacterArchetype = @game.default_character_archetype(),
  build_policy? : @game.ArchetypeBuildPolicy = @game.default_archetype_build_policy(),
  hunting_grounds? : Bool = false,
  species? : CharacterSpecies = Human,
) -> GameState {
  let map_started = hunter_terrain_clock()
  let world = @game.GameWorld::new(
    seed~,
    params~,
    archetype~,
    build_policy~,
    hunting_grounds~,
  )
  let audio_ctx = @audio.MixerAudioContext::new(44100)
  world.manual_combat = true
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
      init_y + 0.3,
      world.player.y / tile_size,
    ),
    18.0, // pulled-back quarter view: combat space and readable hunter silhouette
    0.785, // yaw 45 degrees
    0.78, // 45-degree quarter view
    @math.PI / 5.0,
    sw / sh,
    0.1,
    700.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.4, -1.0, -0.6),
      @math3d.Vec3::new(0.80, 0.89, 1.0), // moonlit edges
      1.15,
    ),
    @light3d.AmbientLight::new(
      @math3d.Vec3::new(0.65, 0.72, 0.84), // keep dark cloth readable
      0.48,
    ),
  )
  let meshes = Meshes3D::new()
  let dungeon_chunks = if hunting_grounds {
    build_hunting_chunks(world.dungeon, seed, region=0)
  } else {
    build_dungeon_chunks(world.dungeon, meshes)
  }
  let scenery = build_scenery_cache(world)
  let initial_map_ms = (hunter_terrain_clock() - map_started).max(0.0)
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
  let character = CharacterModel::new(species~)
  character.equip_outfit(CharacterOutfit::from_equipment(world.equipment))
  {
    world,
    scenery,
    scenery_shader: @gfx.new_shader_handle(119, scenery_shader_wgsl()),
    sky_mesh: @draw3d.sky_mesh(),
    sky_shader: @gfx.new_shader_handle(120, @draw3d.shader3d_sky_wgsl()),
    aim: HunterAimState::new(),
    combat_feedback: CombatFeedbackState::new(),
    input: @inpututil.new_input_helper(),
    show_profiler: false,
    profile: @engine.default_frame_profile(),
    camera,
    camera_settings: HunterCameraSettings::new(),
    terrain_lab: TerrainLabState::new(world.dungeon),
    expedition_map: build_expedition_map(world),
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
    character,
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
      depth_meshes: [],
      all_mesh: @mesh3d.Mesh3D::new([], []),
    },
    visible_dungeon_mesh_cache_player_tile_x: -1,
    visible_dungeon_mesh_cache_player_tile_z: -1,
    visible_dungeon_mesh_cache_builds: 0,
    generated_props: [],
    active_effects: [],
    damage_popups: [],
    audio_ctx,
    audio_bank: @audio.SoundBank::new(audio_ctx),
    audio_failed_paths: [],
    audio_last_played_cue: "",
    audio_last_played_state: "",
    dungeon_floor_texture_image_id: None,
    dungeon_wall_texture_image_id: None,
    // PostFX pipeline
    pipeline: @render_pipeline3d.RenderPipeline3D::new(
      300, screen_w, screen_h, postfx_config,
    ),
    fog_sh: @gfx.new_shader_handle(308, @postfx.fog_wgsl()),
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
    region_meshes: [None, None, None, None],
    region_mesh_stamp: 0,
    region_chunks_built: 0,
    region_prepare_max_ms: 0.0,
    region_chunk_max_ms: 0.0,
    region_batch_max_ms: 0.0,
    initial_map_ms,
    inventory_notice: "",
    paused: false,
    active_save_slot: 0,
    hud_publisher: @ui.JsonObjectPublisher::new(),
    save_slots: read_save_slots(),
    save_notice: "",
    pending_save_deletion: None,
    pause_return_ui: @game.UIMode::None,
    pause_return_cursor: 0,
    ground_targeting: false,
    ground_target_x: world.player.x,
    ground_target_y: world.player.y,
    combat_visuals: [],
    motion_preview: false,
  }
}

///|
fn GameState::update(self : GameState, input : @core.InputSnapshot) -> Unit {
  let input = self.resolve_hunter_hotbar(input)
  let web_key = hunter_web_key()
  let selection = hunter_web_selection()
  if selection >= 0 {
    if self.world.mode == @game.Title && selection < save_slot_count {
      self.world.select_cursor = selection
    } else if self.world.mode == @game.CharacterSelect &&
      selection < @game.selectable_archetypes().length() {
      self.world.select_cursor = selection
    } else {
      let count = match self.world.ui_mode {
        Waypoints =>
          if self.expedition_map is Some(_) {
            8
          } else {
            @game.world_regions.length()
          }
        Inventory => self.world.inventory.capacity
        Skills => self.world.skills.nodes.length()
        LevelUp => self.world.level_progress.current_offers.length()
        None => 0
      }
      if selection < count {
        self.world.ui_cursor = selection
      }
    }
  }
  let input = if web_key == 0 {
    input
  } else {
    let keys = input.pressed_keys.copy()
    if !keys.contains(web_key) {
      keys.push(web_key)
    }
    @core.new_input_snapshot_full(
      input.cursor_x,
      input.cursor_y,
      input.wheel_x,
      input.wheel_y,
      keys,
      input.pressed_mouse_buttons,
      input.touches,
      input.gamepads,
    )
  }
  let was_dragging = @inpututil.is_mouse_button_pressed(
    self.input.mouse_state,
    1,
  )
  @inpututil.update_input_helper(self.input, input)
  if self.handle_hunter_preset_input() {
    return
  }
  let inventory_command = hunter_web_inventory_move()
  if inventory_command.length() > 0 {
    ignore(self.apply_inventory_command(inventory_command))
    return
  }
  if self.handle_pause_input() {
    return
  }
  let camera_command = hunter_web_camera_command()
  let terrain_command = hunter_web_terrain_command()
  if self.terrain_lab.editing && terrain_command.length() > 0 {
    ignore(self.apply_terrain_lab(terrain_command))
  }
  if camera_command.length() > 0 && self.camera_settings.editing {
    ignore(self.apply_camera_command(camera_command))
  }
  if self.camera_settings.editing || self.terrain_lab.editing {
    self.camera = hunter_responsive_camera(
      self.camera,
      canvas_css_width(),
      canvas_css_height(),
      tps=self.camera_settings.mode == 1,
    )
    return
  }
  if self.update_region_streaming() {
    return
  }
  if self.world.mode != @game.Playing ||
    (
      !self.paused &&
      self.world.ui_mode == @game.UIMode::None &&
      !self.motion_preview &&
      self.combat_feedback.hitstop == 0
    ) {
    self.world.frame_count = self.world.frame_count + 1
  }
  let previous_x = self.world.cursor_x
  let previous_y = self.world.cursor_y
  // Scale CSS cursor coordinates to logical game coordinates
  let css_w = canvas_css_width()
  let css_h = canvas_css_height()
  if hunter_web_enabled() {
    self.camera = hunter_responsive_camera(
      self.camera,
      css_w,
      css_h,
      tps=self.camera_settings.mode == 1,
    )
  }
  let scale_x = screen_w.to_double() / css_w
  let scale_y = screen_h.to_double() / css_h
  self.world.cursor_x = input.cursor_x * scale_x
  self.world.cursor_y = input.cursor_y * scale_y
  self.update_aim_input(input)
  if self.world.mode == @game.Playing &&
    !self.paused &&
    self.world.ui_mode == @game.UIMode::None {
    self.update_camera_controls(
      input, previous_x, previous_y, was_dragging, scale_x, scale_y,
    )
  }
  // Profiler toggle (works in any mode)
  if @inpututil.is_key_just_pressed(self.input.key_state, key_f3) {
    self.show_profiler = !self.show_profiler
  }
  // FXAA toggle for visual/perf comparison
  if @inpututil.is_key_just_pressed(self.input.key_state, key_f4) {
    self.pipeline.set_fxaa_enabled(!self.pipeline.config.fxaa_enabled)
  }
  // Shadow toggle for visual/perf comparison
  if @inpututil.is_key_just_pressed(self.input.key_state, key_f5) {
    self.shadows_enabled = !self.shadows_enabled
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
  if !self.world.hunting_grounds &&
    input_snapshot_requests_debug_reset(input, self.world.mode) {
    self.reset_save_and_restart()
    return
  }
  if self.world.hunting_grounds && self.handle_save_delete_input() {
    return
  }
  if @inpututil.is_up_just_pressed(self.input) {
    self.world.select_cursor = (self.world.select_cursor + save_slot_count - 1) %
      save_slot_count
  }
  if @inpututil.is_down_just_pressed(self.input) {
    self.world.select_cursor = (self.world.select_cursor + 1) % save_slot_count
  }
  if @inpututil.is_confirm_just_pressed(self.input) {
    ignore(self.select_save_slot(self.world.select_cursor))
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
    self.world.begin_starting_build(chosen)
    self.world.mode = @game.Playing
    self.sync_character_equipment()
    self.save_game()
  }
  // ESC to go back to title
  if @inpututil.is_key_just_pressed(self.input.key_state, key_escape) {
    self.world.mode = @game.Title
    self.world.select_cursor = self.active_save_slot
    self.save_slots = read_save_slots()
  }
}

///|
fn GameState::update_gameover(
  self : GameState,
  _input : @core.InputSnapshot,
) -> Unit {
  if @inpututil.is_confirm_just_pressed(self.input) {
    self.respawn_player()
  }
}

///|
fn GameState::update_playing(self : GameState) -> Unit {
  self.sync_character_equipment()
  // Auto-play toggle (F2)
  if !self.paused &&
    @inpututil.is_key_just_pressed(self.input.key_state, key_f2) {
    self.world.auto_play = !self.world.auto_play
  }
  if self.paused ||
    self.motion_preview ||
    self.world.ui_mode != @game.UIMode::None ||
    @inpututil.is_key_just_pressed(self.input.key_state, key_i) ||
    @inpututil.is_key_just_pressed(self.input.key_state, key_k) ||
    @inpututil.is_key_just_pressed(self.input.key_state, 71) ||
    @inpututil.is_key_just_pressed(self.input.key_state, key_f2) {
    self.world.stop_whirlwind()
  }
  if self.world.ui_mode == @game.LevelUp {
    self.update_ui()
    return
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, 71) &&
    self.world.atlas is Some(_) &&
    self.world.authored_scene is None &&
    !self.motion_preview {
    if self.world.ui_mode == @game.Waypoints {
      self.world.ui_mode = @game.UIMode::None
    } else {
      self.world.ui_mode = @game.Waypoints
      self.world.ui_cursor = self.world.atlas.unwrap().current
    }
    self.world.atlas.unwrap().travel_target = None
    return
  }
  // UI toggle (works while paused)
  if @inpututil.is_key_just_pressed(self.input.key_state, key_i) {
    self.inventory_notice = ""
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
  // UI interaction mode (works while paused)
  if self.world.ui_mode != @game.UIMode::None {
    self.update_ui()
    return
  }
  // Skip game tick while paused
  if self.paused || self.motion_preview {
    return
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, 66) {
    ignore(self.world.open_nearby_chest())
  }
  if self.combat_feedback.hitstop > 0 {
    // Dodge wins over hitstop; a quick press must never disappear into the freeze.
    if @inpututil.is_key_just_pressed(self.input.key_state, 32) ||
      @inpututil.is_key_just_pressed(self.input.key_state, key_shift) {
      self.combat_feedback.hitstop = 0
    } else {
      self.combat_feedback.hitstop -= 1
      self.update_damage_popups()
      self.update_combat_camera()
      return
    }
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, key_pickup_item) {
    ignore(self.apply_loot_pickup(hunter_web_selection()))
  }
  // Physical X, or the same intent with a selected weapon from the mobile HUD.
  if @inpututil.is_key_just_pressed(self.input.key_state, 88) {
    let selected = hunter_web_selection()
    let index = if selected >= 0 {
      selected
    } else {
      (self.world.player_weapon.index() + 1) % 5
    }
    match @game.player_weapon_from_index(index) {
      Some(weapon) =>
        if self.world.equip_player_weapon(weapon) {
          self.character.equip_weapon(weapon)
          self.save_game()
        }
      None => ()
    }
  }
  let previous_player_x = self.world.player.x
  let previous_player_y = self.world.player.y
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
    raw_dx += hunter_web_move_x()
    raw_dy += hunter_web_move_y()
    if raw_dx * raw_dx + raw_dy * raw_dy > 1.0 {
      let v = @vector.Vec2::new(raw_dx, raw_dy).normalize()
      raw_dx = v.x
      raw_dy = v.y
    }
    let yaw = self.camera.yaw
    let cos_yaw = @math.cos(yaw)
    let sin_yaw = @math.sin(yaw)
    let dx = raw_dx * cos_yaw + raw_dy * sin_yaw
    let dy = -raw_dx * sin_yaw + raw_dy * cos_yaw
    let targeting = self.update_hunter_art_input(dx, dy)
    // Dash via shift
    let shift_pressed = @inpututil.is_key_just_pressed(
      self.input.key_state,
      key_shift,
    )
    let dodge_pressed = shift_pressed ||
      @inpututil.is_key_just_pressed(self.input.key_state, 32)
    if dodge_pressed &&
      self.world.player.dash_cooldown_timer <= 0 &&
      (dx != 0.0 || dy != 0.0 || hunter_web_enabled()) {
      let dodge_x = if dx == 0.0 && dy == 0.0 {
        @math.cos(self.world.player.facing_angle)
      } else {
        dx
      }
      let dodge_y = if dx == 0.0 && dy == 0.0 {
        @math.sin(self.world.player.facing_angle)
      } else {
        dy
      }
      @game.start_dash(self.world, dodge_x, dodge_y)
      self.character.trigger_dodge()
      self.play_sound_cue(SfxDodge)
    }
    if !targeting && @inpututil.is_key_just_pressed(self.input.key_state, 67) {
      let angle = if self.pointer_aim_angle() is Some(angle) {
        angle
      } else if dx != 0.0 || dy != 0.0 {
        @math.atan2(dy, dx)
      } else {
        hunter_assisted_aim(self.world)
      }
      if self.world.request_charge(angle) {
        self.play_sound_cue(SfxAttack)
      }
    }
    if !targeting && self.world.hunting_grounds {
      if @inpututil.is_key_just_pressed(self.input.key_state, 48) {
        ignore(self.world.request_hunter_spell(@game.RaiseZombieArt))
      }
      if @inpututil.is_key_pressed(self.input.key_state, 57) ||
        hunter_web_skull_held() {
        ignore(self.world.request_hunter_spell(@game.FlamingSkullArt))
      }
    }
    // Skill activation: 1/2/3 keys
    if @inpututil.is_key_just_pressed(self.input.key_state, key_1) {
      @game.activate_skill(self.world, 0)
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_3) {
      if self.world.hunting_grounds {
        ignore(self.world.request_hunter_spell(@game.FlameArt))
      } else {
        @game.activate_skill(self.world, 2)
      }
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_4) {
      @game.activate_skill(
        self.world,
        if self.world.hunting_grounds {
          5
        } else {
          3
        },
      )
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_5) {
      if self.world.hunting_grounds {
        ignore(self.world.request_hunter_spell(@game.LightningArt))
      } else {
        @game.activate_skill(self.world, 4)
      }
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_6) {
      @game.activate_skill(
        self.world,
        if self.world.hunting_grounds {
          6
        } else {
          5
        },
      )
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_7) {
      @game.activate_skill(self.world, 6)
    }
    if @inpututil.is_key_just_pressed(self.input.key_state, key_8) {
      @game.activate_skill(self.world, 7)
    }
    if !targeting &&
      (
        (
          !self.world.hunting_grounds &&
          @inpututil.is_mouse_button_pressed(self.input.mouse_state, 0)
        ) ||
        @inpututil.is_key_pressed(self.input.key_state, 74) ||
        hunter_web_attacking()
      ) {
      let angle = match self.pointer_aim_angle() {
        Some(angle) => angle
        None =>
          if self.world.player_weapon.is_melee() && (dx != 0.0 || dy != 0.0) {
            self.world.assist_melee_angle(
              @math.atan2(dy, dx),
              self.world.player_weapon,
            )
          } else {
            hunter_assisted_aim(self.world)
          }
      }
      let _ = self.world.request_basic_attack(angle)
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
  if self.try_cross_region_boundary() {
    return
  }
  let events = self.world.drain_events()
  let melee_hit = events.any(e => {
    match e {
      @game.MeleeImpact(_, _, _, _, _, _) => true
      _ => false
    }
  })
  for event in events {
    self.apply_melee_feedback(event)
    if !(melee_hit && event is @game.HitSparks(_, _)) &&
      !(self.world.player_weapon.is_melee() && event is @game.AttackTriggered) {
      self.play_sound_for_event(event)
    }
    self.queue_combat_visual(event)
    match event {
      @game.EnemyAreaDamage(_, _, _, _) => ()
      @game.SummonReleased(x, y, fire) =>
        if fire {
          self.queue_fireball_cast_effect(x, y)
        } else {
          spawn_item_pickup(self.particle_manager, x, y, true)
        }
      @game.GuardBlocked(_, _, _) => self.play_sound_cue(SfxEnemyHit)
      @game.CombatImpact(kind, _, _, _, _) =>
        self.play_sound_cue(
          if kind == @game.WhirlwindCut {
            SfxAttack
          } else if kind == @game.FlameBlast {
            SfxSpellFireball
          } else {
            SfxSpellChainLightning
          },
        )
      @game.MeleeImpact(_, _, _, _, _, _) | @game.EnemyMeleeWarning(_, _) => ()
      @game.HitSparks(x, y) => spawn_hit_sparks(self.particle_manager, x, y)
      @game.DeathBurst(x, y) => spawn_death_burst(self.particle_manager, x, y)
      @game.DashTrail(x, y) => spawn_dash_trail(self.particle_manager, x, y)
      @game.PlayerHurt(x, y) => spawn_player_hurt(self.particle_manager, x, y)
      @game.PlayerDamageNumber(x, y, amount) =>
        self.spawn_damage_popup(x, y, amount, 0xFF7777)
      @game.EnemyDamageNumber(x, y, amount) =>
        self.spawn_damage_popup(x, y, amount, 0xFFF0BB)
      @game.ChestOpened(x, y) => {
        spawn_item_pickup(self.particle_manager, x, y, false)
        self.save_game()
      }
      @game.ItemPickup(x, y, is_health) =>
        spawn_item_pickup(self.particle_manager, x, y, is_health)
      @game.GroundTelegraphRing(x, y, radius) =>
        self.queue_ground_ring_telegraph_effect(x, y, radius)
      @game.GroundTelegraphLine(x0, y0, x1, y1) =>
        self.queue_ground_line_telegraph_effect(x0, y0, x1, y1)
      @game.ChainLightningArc(_, _, _, _) => ()
      @game.HomingMissileLaunch(x0, y0, x1, y1) =>
        self.queue_homing_missile_effect(x0, y0, x1, y1)
      @game.HomingMissileTrail(x0, y0, x1, y1) =>
        self.queue_homing_missile_effect(x0, y0, x1, y1)
      @game.HomingMissileImpact(x, y) =>
        self.queue_homing_missile_impact_effect(x, y)
      @game.FireballCast(x, y) => self.queue_fireball_cast_effect(x, y)
      @game.FireballTrail(_, _) => ()
      @game.FireballBurst(_, _) => ()
      @game.IceNovaCast(x, y, radius) =>
        self.queue_ice_nova_effect(x, y, radius)
      @game.BeamFire(x0, y0, x1, y1, _is_player) => {
        // Yellow lightning beam effect
        self.play_sound_for_event(@game.ChainLightningArc(x0, y0, x1, y1))
        self.queue_beam_lightning_effect(x0, y0, x1, y1)
        self.queue_beam_lightning_effect(x0, y0, x1, y1)
        self.queue_beam_lightning_effect(x0, y0, x1, y1)
        // Sparks along the beam path
        let steps = 6
        for s = 0; s < steps; s = s + 1 {
          let t = (s + 1).to_double() / steps.to_double()
          let bx = x0 + (x1 - x0) * t
          let by = y0 + (y1 - y0) * t
          spawn_hit_sparks(self.particle_manager, bx, by)
        }
      }
      @game.MeteorCastStart(x, y, radius) => {
        // Triple ring for maximum visibility
        self.queue_enemy_telegraph_effect(x, y, radius)
        self.queue_enemy_telegraph_effect(x, y, radius * 0.7)
        self.queue_enemy_telegraph_effect(x, y, radius * 0.4)
      }
      @game.MeteorImpact(x, y, radius) => {
        // Meteor descends from above and explodes on impact
        self.queue_meteor_fall_effect(x, y, radius)
        spawn_death_burst(self.particle_manager, x, y)
        spawn_death_burst(self.particle_manager, x, y)
        self.queue_fireball_burst_effect(x, y)
      }
      @game.EnemyTelegraphRing(x, y, radius) =>
        self.queue_enemy_telegraph_effect(x, y, radius)
      @game.MeleeSlash(_x, _y, _radius) => () // the rig drives the blade trail
      @game.RoomCleared(_room_idx, x, y) => {
        // Celebration burst for room clear
        spawn_death_burst(self.particle_manager, x, y)
        spawn_death_burst(self.particle_manager, x, y)
        self.queue_fireball_burst_effect(x, y)
      }
      @game.AttackTriggered =>
        self.character.trigger_attack(
          combo=self.world.weapon_attack.map(a => a.combo).or(@game.Opening),
        )
      @game.HurtTriggered => self.character.trigger_hurt()
      @game.FloorComplete => {
        self.rebuild_dungeon_rendering()
        self.save_game()
      }
    }
  }
  if self.world.mode == @game.GameOver {
    self.save_game()
  }
  self.apply_generated_prop_roles_for_current_floor()
  if self.world.weapon_attack is None &&
    self.world.player_charge is None &&
    self.world.player.dash_timer <= 0 &&
    !self.world.hunter_action_locked() {
    if self.pointer_aim_angle() is Some(angle) {
      self.world.player.facing_angle = angle
    }
  }
  self.update_combat_camera()
  if self.world.weapon_attack is Some(attack) {
    if attack.weapon.is_melee() && attack.frame == attack.profile().windup - 2 {
      self.play_sound_cue(SfxAttack)
    }
  }
  // Update character animation
  let moved_x = self.world.player.x - previous_player_x
  let moved_y = self.world.player.y - previous_player_y
  let is_moving = moved_x * moved_x + moved_y * moved_y > 0.0001
  self.character.set_moving(is_moving)
  self.character.update(1.0 / 60.0)
  // Sample the same integer frame as combat; float accumulation must not delay release.
  if self.world.weapon_attack is Some(attack) {
    self.character.action_time = attack.frame.to_double() / 60.0
  }
  if self.world.player_charge is Some(charge) {
    self.character.anim_state = Charging
    self.character.action_time = charge.frame.to_double() / 60.0
    self.character.skinning_cache_dirty = true
    if charge.frame == @game.player_charge_profile.windup {
      self.play_sound_cue(SfxDodge)
    }
  } else if self.character.anim_state == Charging {
    self.character.anim_state = if is_moving { Running } else { Idle }
    self.character.skinning_cache_dirty = true
  }
  if self.world.arts.whirlwind.active {
    self.character.anim_state = Whirling
    self.character.action_time = self.world.arts.whirlwind.frame.to_double() /
      60.0
    self.character.skinning_cache_dirty = true
  } else if self.world.arts.guarding {
    self.character.anim_state = Guarding
    self.character.action_time = self.world.arts.guard_frame.to_double() / 60.0
    self.character.skinning_cache_dirty = true
  } else if self.world.arts.action is Some(action) {
    self.character.anim_state = Casting(action.kind)
    self.character.action_time = action.frame.to_double() / 60.0
    self.character.skinning_cache_dirty = true
  } else if self.character.anim_state == Whirling ||
    self.character.anim_state == Guarding ||
    self.character.anim_state is Casting(_) {
    self.character.anim_state = if is_moving { Running } else { Idle }
    self.character.skinning_cache_dirty = true
  }
  self.tick_combat_visuals()
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
  if self.damage_popups.length() >= 48 {
    ignore(self.damage_popups.remove(0))
  }
  let scatter = (self.damage_popups.length() % 3 - 1).to_double() * 3.5
  self.damage_popups.push({
    x: x + scatter,
    y,
    amount,
    color_hex,
    ttl: 48,
    rise: 0.0,
  })
}

///|
fn GameState::update_damage_popups(self : GameState) -> Unit {
  let still_active : Array[DamagePopup] = []
  for popup in self.damage_popups {
    popup.ttl = popup.ttl - 1
    popup.rise = popup.rise + 0.018
    if popup.ttl > 0 {
      still_active.push(popup)
    }
  }
  self.damage_popups = still_active
}

// Rebuild dungeon rendering state after dungeon changes (floor complete, game over reset, load)

///|
fn GameState::rebuild_dungeon_rendering(self : GameState) -> Unit {
  if self.terrain_lab.config.pattern != @terrain3d.Flat ||
    self.world.atlas is Some({ elevation: Some(_), .. }) {
    ignore(self.world.set_hunting_terrain(self.terrain_lab.config))
  }
  self.refresh_terrain_stats()
  self.expedition_map = build_expedition_map(self.world)
  self.combat_feedback.hitstop = 0
  self.combat_feedback.look_x = 0.0
  self.combat_feedback.look_y = 0.0
  self.ground_targeting = false
  self.combat_visuals.clear()
  for i in 0..<self.region_meshes.length() {
    self.region_meshes[i] = None
  }
  self.dungeon_chunks = if self.world.hunting_grounds &&
    self.world.authored_scene is None {
    build_hunting_chunks(
      self.world.dungeon,
      self.world.seed,
      region=self.world.atlas.map(atlas => atlas.current).or(-1),
    )
  } else {
    build_dungeon_chunks(self.world.dungeon, self.meshes)
  }
  if self.world.dungeon.landscape is None {
    self.scenery = None
  } else if self.scenery is None ||
    self.scenery.unwrap().seed !=
    self.world.atlas.map(a => a.world_seed).or(self.world.seed) ||
    self.scenery.unwrap().plains_relief !=
    self.world.atlas.map(a => a.plains_relief).or(1.0) {
    self.scenery = build_scenery_cache(self.world)
  }
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
