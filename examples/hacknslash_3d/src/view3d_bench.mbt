///|
fn bench_engine_context() -> @engine.EngineContext {
  {
    dst: @gfx.new_image_handle(990, screen_w, screen_h),
    shader: @gfx.new_shader_handle(991, "ui"),
    screen_w,
    screen_h,
  }
}

///|
fn bench_visible_region(state : GameState) -> VisibleRegion {
  compute_visible_region(
    state.world.dungeon.rooms,
    state.world.player.x,
    state.world.player.y,
    state.world.dungeon.grid.width,
    state.world.dungeon.grid.height,
  )
}

///|
fn bench_state_with_all_effects_enabled() -> GameState {
  let state = GameState::new_with_ssao(seed=42, SSAOConfig::enabled_default())
  state.fxaa_enabled = true
  state.shadows_enabled = true
  state
}

///|
fn bench_state_with_visible_entities() -> GameState {
  let state = GameState::new(seed=42)
  let px = state.world.player.x
  let py = state.world.player.y
  state.world.items = [
    {
      x: px,
      y: py,
      vx: 0.0,
      vy: 0.0,
      kind: @game.Health,
      alive: true,
      spawn_frame: 0,
    },
    {
      x: px + 8.0,
      y: py,
      vx: 0.0,
      vy: 0.0,
      kind: @game.Score,
      alive: true,
      spawn_frame: 0,
    },
  ]
  state.world.projectiles = [
    {
      x: px,
      y: py,
      vx: 1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: true,
      kind: @game.Arrow,
    },
    {
      x: px + 4.0,
      y: py + 4.0,
      vx: -1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: false,
      kind: @game.EnemyBolt,
    },
  ]
  state
}

///|
fn bench_state_with_particles() -> GameState {
  let state = GameState::new(seed=42)
  let px = state.world.player.x
  let py = state.world.player.y
  spawn_death_burst(state.particle_manager, px, py)
  spawn_hit_sparks(state.particle_manager, px + 8.0, py)
  spawn_item_pickup(state.particle_manager, px, py + 8.0, true)
  state.particle_manager.update(1.0 / 60.0)
  state
}

///|
fn bench_state_with_visible_enemy() -> GameState {
  let state = GameState::new(seed=42)
  let px = state.world.player.x
  let py = state.world.player.y
  state.world.enemies = [
    {
      x: px,
      y: py,
      vx: 0.0,
      vy: 0.0,
      hp: 3,
      max_hp: 3,
      speed: 1.0,
      size: 12.0,
      alive: true,
      damage_timer: 0,
      kind: @game.Basic,
      path_cache: [],
      path_index: 0,
      path_timer: 0,
      shoot_cooldown: 0,
      pending_bolt_timer: 0,
      pending_bolt_target_x: px,
      pending_bolt_target_y: py,
      charge_timer: 0,
      charge_cooldown: 0, meteor_cast_timer: 0, meteor_target_x: 0.0, meteor_target_y: 0.0,
    },
  ]
  state
}

///|
fn bench_state_with_stress_enemies(count : Int) -> GameState {
  let state = GameState::new(seed=42)
  apply_enemy_stress_scenario(state.world, count)
  state
}

///|
fn clone_enemy_array(src : Array[@game.Enemy]) -> Array[@game.Enemy] {
  let out : Array[@game.Enemy] = []
  for enemy in src {
    out.push(enemy)
  }
  out
}

///|
fn clone_projectile_array(
  src : Array[@game.Projectile],
) -> Array[@game.Projectile] {
  let out : Array[@game.Projectile] = []
  for projectile in src {
    out.push(projectile)
  }
  out
}

///|
fn clone_item_array(src : Array[@game.ItemDrop]) -> Array[@game.ItemDrop] {
  let out : Array[@game.ItemDrop] = []
  for item in src {
    out.push(item)
  }
  out
}

///|
fn bench_state_with_enemy_projectile_hit() -> GameState {
  let state = GameState::new(seed=42)
  state.world.projectiles = [
    {
      x: state.world.player.x,
      y: state.world.player.y,
      vx: 0.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 2,
      is_player: false,
      kind: @game.EnemyBolt,
    },
  ]
  state
}

///|
fn bench_state_with_collectible_item() -> GameState {
  let state = GameState::new(seed=42)
  state.world.items = [
    {
      x: state.world.player.x,
      y: state.world.player.y,
      vx: 0.0,
      vy: 0.0,
      kind: @game.Score,
      alive: true,
      spawn_frame: state.world.frame_count,
    },
  ]
  state
}

///|
fn build_basic_enemy_cluster(
  center_x : Double,
  center_y : Double,
  count : Int,
) -> Array[@game.Enemy] {
  let side = enemy_stress_grid_side(count)
  let spacing = tile_size * 0.75
  let center = (side - 1).to_double() / 2.0
  let enemies : Array[@game.Enemy] = []
  for i = 0; i < count; i = i + 1 {
    let col = i % side
    let row = i / side
    let offset_x = (col.to_double() - center) * spacing
    let offset_y = (row.to_double() - center) * spacing
    enemies.push(
      @game.make_enemy(
        center_x + offset_x,
        center_y + offset_y,
        @game.Basic,
        3,
        1.0,
        10.0,
      ),
    )
  }
  enemies
}

///|
fn bench_state_with_enemy_ai_direct_chase(count : Int) -> GameState {
  let state = GameState::new(seed=42)
  state.world.enemies = build_basic_enemy_cluster(
    state.world.player.x + tile_size * 2.0,
    state.world.player.y,
    count,
  )
  state
}

///|
fn bench_state_with_enemy_ai_castup_phase(count : Int) -> GameState {
  let state = bench_state_with_stress_enemies(count)
  let target_x = state.world.player.x + tile_size
  let target_y = state.world.player.y
  for enemy in state.world.enemies {
    enemy.pending_bolt_timer = @game.enemy_bolt_telegraph_frames
    enemy.pending_bolt_target_x = target_x
    enemy.pending_bolt_target_y = target_y
  }
  state
}

///|
fn bench_state_with_enemy_ai_tackle_phase(count : Int) -> GameState {
  let state = bench_state_with_stress_enemies(count)
  let target_x = state.world.player.x + tile_size
  let target_y = state.world.player.y
  for enemy in state.world.enemies {
    enemy.charge_timer = @game.enemy_tackle_active_frames
    enemy.pending_bolt_target_x = target_x
    enemy.pending_bolt_target_y = target_y
  }
  state
}

///|
fn bench_state_with_enemy_ai_path_rebuild(count : Int) -> GameState {
  let state = bench_state_with_enemy_ai_direct_chase(count)
  let grid = @physics2d.clone_terrain_grid(state.world.dungeon.grid)
  @physics2d.append_circular_wall_blocker(
    grid,
    state.world.player.x + tile_size,
    state.world.player.y,
    tile_size * 0.75,
    tile_size,
  )
  state.world.dungeon.grid = grid
  for enemy in state.world.enemies {
    enemy.path_timer = 0
  }
  state
}

///|
fn bench_state_with_enemy_ai_path_follow(count : Int) -> GameState {
  let state = bench_state_with_enemy_ai_path_rebuild(count)
  state.world.projectiles = []
  state.world.events = []
  state.world.tick_enemy_ai_phase()
  state.world.projectiles = []
  state.world.events = []
  state
}

///|
test "bench hacknslash_3d draw_playing default" (b : @bench.T) {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  b.bench(name="hacknslash_3d/draw_playing/default", fn() {
    let commands = state.draw_playing(ctx)
    let stats = summarize_draw_playing_commands(commands, state, ctx.dst)
    b.keep(
      stats.total_commands +
      stats.estimated_draw_calls +
      stats.instanced_instances,
    )
  })
}

///|
test "bench hacknslash_3d draw_playing all_effects" (b : @bench.T) {
  let state = bench_state_with_all_effects_enabled()
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  b.bench(name="hacknslash_3d/draw_playing/all_effects", fn() {
    let commands = state.draw_playing(ctx)
    let stats = summarize_draw_playing_commands(commands, state, ctx.dst)
    b.keep(
      stats.total_commands +
      stats.estimated_draw_calls +
      stats.instanced_instances,
    )
  })
}

///|
test "bench hacknslash_3d draw_playing stress_enemies_64" (b : @bench.T) {
  let state = bench_state_with_stress_enemies(64)
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  b.bench(name="hacknslash_3d/draw_playing/stress_enemies_64", fn() {
    let commands = state.draw_playing(ctx)
    let stats = summarize_draw_playing_commands(commands, state, ctx.dst)
    b.keep(
      stats.total_commands +
      stats.estimated_draw_calls +
      stats.instanced_instances,
    )
  })
}

///|
test "bench hacknslash_3d draw_playing stress_enemies_256" (b : @bench.T) {
  let state = bench_state_with_stress_enemies(256)
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  b.bench(name="hacknslash_3d/draw_playing/stress_enemies_256", fn() {
    let commands = state.draw_playing(ctx)
    let stats = summarize_draw_playing_commands(commands, state, ctx.dst)
    b.keep(
      stats.total_commands +
      stats.estimated_draw_calls +
      stats.instanced_instances,
    )
  })
}

///|
test "bench hacknslash_3d enemy_compute_skinning" (b : @bench.T) {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  b.bench(name="hacknslash_3d/enemy_compute_skinning", fn() {
    let matrices = state.enemy_models.compute_skinning()
    b.keep(matrices.length())
  })
}

///|
test "bench hacknslash_3d entities_pass default" (b : @bench.T) {
  let state = bench_state_with_visible_entities()
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let vis_region = bench_visible_region(state)
  let camera = state.camera.to_camera3d()
  b.bench(name="hacknslash_3d/entities_pass/default", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    push_entity_instanced_cmds(
      state,
      vis_region,
      camera,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d entities_rebuild_scratch default" (b : @bench.T) {
  let state = bench_state_with_visible_entities()
  state.world.mode = @game.Playing
  let vis_region = bench_visible_region(state)
  b.bench(name="hacknslash_3d/entities_rebuild_scratch/default", fn() {
    state.rebuild_entity_instance_scratch(vis_region)
    b.keep(
      state.entity_instance_scratch.item_instances.length() +
      state.entity_instance_scratch.arrow_instances.length() +
      state.entity_instance_scratch.enemy_projectile_instances.length(),
    )
  })
}

///|
test "bench hacknslash_3d entities_items_draw default" (b : @bench.T) {
  let state = bench_state_with_visible_entities()
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let vis_region = bench_visible_region(state)
  let view_projection = state.camera.to_camera3d().view_projection_matrix()
  state.rebuild_entity_instance_scratch(vis_region)
  b.bench(name="hacknslash_3d/entities_items_draw/default", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    push_item_instance_cmds(
      state,
      view_projection,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d entities_arrows_draw default" (b : @bench.T) {
  let state = bench_state_with_visible_entities()
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let vis_region = bench_visible_region(state)
  let view_projection = state.camera.to_camera3d().view_projection_matrix()
  state.rebuild_entity_instance_scratch(vis_region)
  b.bench(name="hacknslash_3d/entities_arrows_draw/default", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    push_arrow_instance_cmds(
      state,
      view_projection,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d entities_enemy_projectiles_draw default" (
  b : @bench.T,
) {
  let state = bench_state_with_visible_entities()
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let vis_region = bench_visible_region(state)
  let view_projection = state.camera.to_camera3d().view_projection_matrix()
  state.rebuild_entity_instance_scratch(vis_region)
  b.bench(name="hacknslash_3d/entities_enemy_projectiles_draw/default", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    push_enemy_projectile_instance_cmds(
      state,
      view_projection,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d character_pass default" (b : @bench.T) {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let vis_region = bench_visible_region(state)
  let camera = state.camera.to_camera3d()
  b.bench(name="hacknslash_3d/character_pass/default", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    state.push_character_commands(
      vis_region,
      camera,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d enemy_character_pass default" (b : @bench.T) {
  let state = bench_state_with_visible_enemy()
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let vis_region = bench_visible_region(state)
  let camera = state.camera.to_camera3d()
  b.bench(name="hacknslash_3d/enemy_character_pass/default", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    state.push_enemy_character_commands(
      vis_region,
      camera,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d enemy_character_pass stress_enemies_64" (b : @bench.T) {
  let state = bench_state_with_stress_enemies(64)
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let vis_region = bench_visible_region(state)
  let camera = state.camera.to_camera3d()
  b.bench(name="hacknslash_3d/enemy_character_pass/stress_enemies_64", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    state.push_enemy_character_commands(
      vis_region,
      camera,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d enemy_character_pass stress_enemies_256" (
  b : @bench.T,
) {
  let state = bench_state_with_stress_enemies(256)
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let vis_region = bench_visible_region(state)
  let camera = state.camera.to_camera3d()
  b.bench(name="hacknslash_3d/enemy_character_pass/stress_enemies_256", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    state.push_enemy_character_commands(
      vis_region,
      camera,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d rebuild_enemy_render_buckets stress_enemies_64" (
  b : @bench.T,
) {
  let state = bench_state_with_stress_enemies(64)
  state.world.mode = @game.Playing
  let vis_region = bench_visible_region(state)
  b.bench(name="hacknslash_3d/rebuild_enemy_render_buckets/stress_enemies_64", fn() {
    state.rebuild_enemy_render_buckets(vis_region)
    let buckets = state.enemy_render_buckets
    b.keep(
      buckets.basic_matrices.length() +
      buckets.fast_matrices.length() +
      buckets.tank_matrices.length() +
      buckets.ranged_matrices.length() +
      buckets.boss_matrices.length(),
    )
  })
}

///|
test "bench hacknslash_3d rebuild_enemy_render_buckets stress_enemies_256" (
  b : @bench.T,
) {
  let state = bench_state_with_stress_enemies(256)
  state.world.mode = @game.Playing
  let vis_region = bench_visible_region(state)
  b.bench(
    name="hacknslash_3d/rebuild_enemy_render_buckets/stress_enemies_256",
    fn() {
      state.rebuild_enemy_render_buckets(vis_region)
      let buckets = state.enemy_render_buckets
      b.keep(
        buckets.basic_matrices.length() +
        buckets.fast_matrices.length() +
        buckets.tank_matrices.length() +
        buckets.ranged_matrices.length() +
        buckets.boss_matrices.length(),
      )
    },
  )
}

///|
test "bench hacknslash_3d enemy_enemy_separation stress_enemies_64" (
  b : @bench.T,
) {
  let state = bench_state_with_stress_enemies(64)
  let template = clone_enemy_array(state.world.enemies)
  b.bench(name="hacknslash_3d/enemy_enemy_separation/stress_enemies_64", fn() {
    state.world.enemies = clone_enemy_array(template)
    state.world.resolve_enemy_enemy_separation()
    b.keep(state.world.enemies.length())
  })
}

///|
test "bench hacknslash_3d enemy_enemy_separation stress_enemies_256" (
  b : @bench.T,
) {
  let state = bench_state_with_stress_enemies(256)
  let template = clone_enemy_array(state.world.enemies)
  b.bench(name="hacknslash_3d/enemy_enemy_separation/stress_enemies_256", fn() {
    state.world.enemies = clone_enemy_array(template)
    state.world.resolve_enemy_enemy_separation()
    b.keep(state.world.enemies.length())
  })
}

///|
test "bench hacknslash_3d enemy_ai_phase stress_enemies_64" (b : @bench.T) {
  let state = bench_state_with_stress_enemies(64)
  let template = clone_enemy_array(state.world.enemies)
  b.bench(name="hacknslash_3d/enemy_ai_phase/stress_enemies_64", fn() {
    state.world.enemies = clone_enemy_array(template)
    state.world.projectiles = []
    state.world.tick_enemy_ai_phase()
    b.keep(state.world.enemies.length() + state.world.projectiles.length())
  })
}

///|
test "bench hacknslash_3d enemy_ai_phase stress_enemies_256" (b : @bench.T) {
  let state = bench_state_with_stress_enemies(256)
  let template = clone_enemy_array(state.world.enemies)
  b.bench(name="hacknslash_3d/enemy_ai_phase/stress_enemies_256", fn() {
    state.world.enemies = clone_enemy_array(template)
    state.world.projectiles = []
    state.world.tick_enemy_ai_phase()
    b.keep(state.world.enemies.length() + state.world.projectiles.length())
  })
}

///|
test "bench hacknslash_3d enemy_ai_castup_phase stress_enemies_256" (
  b : @bench.T,
) {
  let state = bench_state_with_enemy_ai_castup_phase(256)
  let template = clone_enemy_array(state.world.enemies)
  b.bench(name="hacknslash_3d/enemy_ai_castup_phase/stress_enemies_256", fn() {
    state.world.enemies = clone_enemy_array(template)
    state.world.projectiles = []
    state.world.events = []
    state.world.tick_enemy_ai_phase()
    b.keep(state.world.enemies.length() + state.world.projectiles.length())
  })
}

///|
test "bench hacknslash_3d enemy_ai_tackle_phase stress_enemies_256" (
  b : @bench.T,
) {
  let state = bench_state_with_enemy_ai_tackle_phase(256)
  let template = clone_enemy_array(state.world.enemies)
  b.bench(name="hacknslash_3d/enemy_ai_tackle_phase/stress_enemies_256", fn() {
    state.world.enemies = clone_enemy_array(template)
    state.world.projectiles = []
    state.world.events = []
    state.world.tick_enemy_ai_phase()
    b.keep(state.world.enemies.length() + state.world.projectiles.length())
  })
}

///|
test "bench hacknslash_3d enemy_ai_direct_chase_phase stress_enemies_256" (
  b : @bench.T,
) {
  let state = bench_state_with_enemy_ai_direct_chase(256)
  let template = clone_enemy_array(state.world.enemies)
  b.bench(name="hacknslash_3d/enemy_ai_direct_chase_phase/stress_enemies_256", fn() {
    state.world.enemies = clone_enemy_array(template)
    state.world.projectiles = []
    state.world.events = []
    state.world.tick_enemy_ai_phase()
    b.keep(state.world.enemies.length() + state.world.projectiles.length())
  })
}

///|
test "bench hacknslash_3d enemy_ai_path_rebuild_phase stress_enemies_256" (
  b : @bench.T,
) {
  let state = bench_state_with_enemy_ai_path_rebuild(256)
  let template = clone_enemy_array(state.world.enemies)
  b.bench(name="hacknslash_3d/enemy_ai_path_rebuild_phase/stress_enemies_256", fn() {
    state.world.enemies = clone_enemy_array(template)
    state.world.projectiles = []
    state.world.events = []
    state.world.tick_enemy_ai_phase()
    b.keep(state.world.enemies.length() + state.world.projectiles.length())
  })
}

///|
test "bench hacknslash_3d enemy_ai_path_follow_phase stress_enemies_256" (
  b : @bench.T,
) {
  let state = bench_state_with_enemy_ai_path_follow(256)
  let template = clone_enemy_array(state.world.enemies)
  b.bench(name="hacknslash_3d/enemy_ai_path_follow_phase/stress_enemies_256", fn() {
    state.world.enemies = clone_enemy_array(template)
    state.world.projectiles = []
    state.world.events = []
    state.world.tick_enemy_ai_phase()
    b.keep(state.world.enemies.length() + state.world.projectiles.length())
  })
}

///|
test "bench hacknslash_3d enemy_movement_contact_phase stress_enemies_64" (
  b : @bench.T,
) {
  let state = bench_state_with_stress_enemies(64)
  let template = clone_enemy_array(state.world.enemies)
  let base_hp = state.world.player.hp
  b.bench(name="hacknslash_3d/enemy_movement_contact_phase/stress_enemies_64", fn() {
    state.world.enemies = clone_enemy_array(template)
    state.world.player.hp = base_hp
    state.world.player.iframe_timer = 0
    state.world.tick_enemy_movement_and_contact_phase()
    b.keep(state.world.enemies.length() + state.world.player.hp)
  })
}

///|
test "bench hacknslash_3d enemy_movement_contact_phase stress_enemies_256" (
  b : @bench.T,
) {
  let state = bench_state_with_stress_enemies(256)
  let template = clone_enemy_array(state.world.enemies)
  let base_hp = state.world.player.hp
  b.bench(
    name="hacknslash_3d/enemy_movement_contact_phase/stress_enemies_256",
    fn() {
      state.world.enemies = clone_enemy_array(template)
      state.world.player.hp = base_hp
      state.world.player.iframe_timer = 0
      state.world.tick_enemy_movement_and_contact_phase()
      b.keep(state.world.enemies.length() + state.world.player.hp)
    },
  )
}

///|
test "bench hacknslash_3d projectiles_phase player_hit" (b : @bench.T) {
  let state = bench_state_with_enemy_projectile_hit()
  let template_projectiles = clone_projectile_array(state.world.projectiles)
  let base_hp = state.world.player.hp
  b.bench(name="hacknslash_3d/projectiles_phase/player_hit", fn() {
    state.world.projectiles = clone_projectile_array(template_projectiles)
    state.world.player.hp = base_hp
    state.world.player.iframe_timer = 0
    state.world.tick_projectiles_phase()
    b.keep(state.world.player.hp + state.world.projectiles.length())
  })
}

///|
test "bench hacknslash_3d items_phase pickup" (b : @bench.T) {
  let state = bench_state_with_collectible_item()
  let template_items = clone_item_array(state.world.items)
  let base_score = state.world.score
  b.bench(name="hacknslash_3d/items_phase/pickup", fn() {
    state.world.items = clone_item_array(template_items)
    state.world.score = base_score
    state.world.tick_items_phase()
    b.keep(state.world.score + state.world.items.length())
  })
}

///|
test "bench hacknslash_3d enemy_character_groups_draw stress_enemies_64" (
  b : @bench.T,
) {
  let state = bench_state_with_stress_enemies(64)
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let vis_region = bench_visible_region(state)
  let view_projection = state.camera.to_camera3d().view_projection_matrix()
  let enemy_skinning = state.enemy_models.compute_skinning()
  state.rebuild_enemy_render_buckets(vis_region)
  b.bench(name="hacknslash_3d/enemy_character_groups_draw/stress_enemies_64", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    state.push_enemy_render_bucket_groups_with_view_projection(
      state.enemy_render_buckets,
      enemy_skinning,
      view_projection,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d enemy_character_groups_draw stress_enemies_256" (
  b : @bench.T,
) {
  let state = bench_state_with_stress_enemies(256)
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let vis_region = bench_visible_region(state)
  let view_projection = state.camera.to_camera3d().view_projection_matrix()
  let enemy_skinning = state.enemy_models.compute_skinning()
  state.rebuild_enemy_render_buckets(vis_region)
  b.bench(name="hacknslash_3d/enemy_character_groups_draw/stress_enemies_256", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    state.push_enemy_render_bucket_groups_with_view_projection(
      state.enemy_render_buckets,
      enemy_skinning,
      view_projection,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d player_character_pass default" (b : @bench.T) {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let camera = state.camera.to_camera3d()
  b.bench(name="hacknslash_3d/player_character_pass/default", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    state.push_player_character_commands(
      camera,
      state.scene_target,
      ctx.screen_w,
      ctx.screen_h,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d dungeon_pass default" (b : @bench.T) {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let view_projection = state.camera.to_camera3d().view_projection_matrix()
  let visible_dungeon_cache = state.get_visible_dungeon_mesh_cache_for_player()
  let shadow_state = compute_shadow_frame_state(
    state.shadows_enabled,
    state.shadow_config,
    state.world.player.x,
    state.world.player.y,
    state.lighting,
  )
  b.bench(name="hacknslash_3d/dungeon_pass/default", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    state.push_dungeon_chunk_commands(
      visible_dungeon_cache.groups,
      visible_dungeon_cache.all_mesh,
      view_projection,
      shadow_state,
      state.scene_target,
      commands,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d particles_pass active" (b : @bench.T) {
  let state = bench_state_with_particles()
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  let camera = state.camera.to_camera3d()
  b.bench(name="hacknslash_3d/particles_pass/active", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    state.particle_manager.append_draw_commands(
      commands,
      state.scene_target,
      camera,
      ctx.screen_w,
      ctx.screen_h,
      state.world.frame_count,
    )
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d hud_pass default" (b : @bench.T) {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = bench_engine_context()
  b.bench(name="hacknslash_3d/hud_pass/default", fn() {
    let commands = state.render_hud_cmds(ctx.dst, ctx.shader)
    b.keep(commands.length())
  })
}

///|
test "bench hacknslash_3d dungeon_pass shadows" (b : @bench.T) {
  let state = bench_state_with_all_effects_enabled()
  state.world.mode = @game.Playing
  let view_projection = state.camera.to_camera3d().view_projection_matrix()
  let visible_dungeon_cache = state.get_visible_dungeon_mesh_cache_for_player()
  let shadow_state = compute_shadow_frame_state(
    state.shadows_enabled,
    state.shadow_config,
    state.world.player.x,
    state.world.player.y,
    state.lighting,
  )
  b.bench(name="hacknslash_3d/dungeon_pass/shadows", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    state.push_dungeon_chunk_commands(
      visible_dungeon_cache.groups,
      visible_dungeon_cache.all_mesh,
      view_projection,
      shadow_state,
      state.scene_target,
      commands,
    )
    b.keep(commands.length())
  })
}
