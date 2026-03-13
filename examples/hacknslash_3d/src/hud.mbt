// HUD: HP bar, floor, score, enemy count, dash cooldown (no minimap)
// Uses @hud.HudContext for rendering, falls back to @scene.label when TextRenderer is unavailable.

///|
fn GameState::make_hud_ctx(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> @hud.HudContext {
  {
    dst,
    shader,
    screen_w: screen_w.to_double(),
    screen_h: screen_h.to_double(),
    text_renderer: self.text_renderer,
  }
}

///|
fn GameState::invalidate_minimap_cache(self : GameState) -> Unit {
  self.minimap_static_cmds = []
  self.minimap_cache_player_tile_x = -1
  self.minimap_cache_player_tile_y = -1
  self.minimap_cache_floor = -1
  self.minimap_cache_dst_id = -1
  self.minimap_cache_shader_id = -1
  self.minimap_cache_discovery_version = -1
}

///|
fn GameState::invalidate_hud_static_cache(self : GameState) -> Unit {
  self.hud_static_cmds = []
  self.hud_static_cache_floor = -1
  self.hud_static_cache_dst_id = -1
  self.hud_static_cache_shader_id = -1
  self.hud_static_cache_text_mode = -1
}

///|
fn GameState::hud_static_text_mode(self : GameState) -> Int {
  match self.text_renderer {
    Some(_) => 1
    None => 0
  }
}

///|
fn cooldown_tenths_text(timer : Int) -> String {
  let tenths = (timer + 5) / 6
  let whole = tenths / 10
  let frac = tenths % 10
  whole.to_string() + "." + frac.to_string()
}

///|
fn GameState::draw_spell_cooldown_widget(
  self : GameState,
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
  label : String,
  x : Double,
  y : Double,
  width : Double,
  timer : Int,
  max_timer : Int,
  color_hex : Int,
) -> Unit {
  let bg_y = y + 2.0
  ctx.draw_text(cmds, label, 12.0, x, y, 0xDDEEFF)
  ctx.draw_rect(
    cmds,
    x + 28.0,
    bg_y,
    width,
    6.0,
    @hud.hex_color(0x112233, alpha=0.45),
  )
  if timer > 0 {
    let ratio = timer.to_double() / max_timer.to_double()
    ctx.draw_rect(
      cmds,
      x + 28.0,
      bg_y,
      width * ratio,
      6.0,
      @hud.hex_color(color_hex, alpha=0.85),
    )
    ctx.draw_text(
      cmds,
      cooldown_tenths_text(timer),
      12.0,
      x + 28.0 + width + 6.0,
      y,
      color_hex,
    )
  }
}

///|
fn GameState::draw_spell_cooldowns(
  self : GameState,
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  self.draw_spell_cooldown_widget(
    ctx,
    cmds,
    "4 CL",
    10.0,
    42.0,
    56.0,
    self.world.chain_lightning_cooldown_timer,
    self.world.params.chain_lightning_cooldown_frames(),
    0x77CCFF,
  )
  self.draw_spell_cooldown_widget(
    ctx,
    cmds,
    "5 FB",
    10.0,
    58.0,
    56.0,
    self.world.splitting_fireball_cooldown_timer,
    self.world.params.splitting_fireball_cooldown_frames(),
    0xFF9944,
  )
  self.draw_spell_cooldown_widget(
    ctx,
    cmds,
    "6 IN",
    10.0,
    74.0,
    56.0,
    self.world.ice_nova_cooldown_timer,
    self.world.params.ice_nova_cooldown_frames(),
    0x99EEFF,
  )
  self.draw_spell_cooldown_widget(
    ctx,
    cmds,
    "7 HM",
    10.0,
    90.0,
    56.0,
    self.world.homing_missile_cooldown_timer,
    self.world.params.homing_missile_cooldown_frames(),
    0xFF66CC,
  )
}

///|
fn item_drop_label_text(kind : @game.ItemKind) -> String {
  match kind {
    @game.Health => "HP +2"
    @game.Score => "GOLD +5"
    @game.Equipment(data) => data.display_name()
  }
}

///|
fn item_drop_label_color(kind : @game.ItemKind) -> Int {
  match kind {
    @game.Health => 0x66FFAA
    @game.Score => 0xFFCC33
    @game.Equipment(data) => data.rarity.color()
  }
}

///|
fn project_world_label_position(
  camera : @camera3d.Camera3D,
  world_pos : @math3d.Vec3,
  screen_w : Double,
  screen_h : Double,
) -> (Double, Double)? {
  let clip = camera
    .view_projection_matrix()
    .mul_vec4(@math3d.Vec4::from_vec3(world_pos, 1.0))
  if clip.w <= 0.000001 {
    return None
  }
  let inv_w = 1.0 / clip.w
  let ndc_x = clip.x * inv_w
  let ndc_y = clip.y * inv_w
  let ndc_z = clip.z * inv_w
  if ndc_x < -1.1 ||
    ndc_x > 1.1 ||
    ndc_y < -1.1 ||
    ndc_y > 1.1 ||
    ndc_z < -1.0 ||
    ndc_z > 1.0 {
    return None
  }
  let sx = (ndc_x * 0.5 + 0.5) * screen_w
  let sy = (1.0 - (ndc_y * 0.5 + 0.5)) * screen_h
  Some((sx, sy))
}

///|
fn GameState::draw_item_drop_labels(
  self : GameState,
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let camera = self.camera.to_camera3d()
  for item in self.world.items {
    if not(item.alive) {
      continue
    }
    let world_pos = @math3d.Vec3::new(
      item.x / tile_size,
      @game.get_tile_height(self.world.dungeon, item.x, item.y) + 1.05,
      item.y / tile_size,
    )
    match
      project_world_label_position(
        camera,
        world_pos,
        ctx.screen_w,
        ctx.screen_h,
      ) {
      Some((sx, sy)) =>
        ctx.draw_text_centered(
          cmds,
          item_drop_label_text(item.kind),
          11.0,
          sx,
          sy - 16.0,
          item_drop_label_color(item.kind),
        )
      None => ()
    }
  }
}

///|
fn GameState::build_hud_static_cmds(
  self : GameState,
  ctx : @hud.HudContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let sw = screen_w.to_double()
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  match self.text_renderer {
    Some(tr) => {
      let _ = tr
      ctx.draw_text(cmds, "HP", 16.0, 60.0, 8.0, 0xFFFFFF)
      ctx.draw_text_centered(
        cmds,
        "FLOOR " + self.world.floor.to_string(),
        20.0,
        sw / 2.0,
        16.0,
        0xCCCCCC,
      )
    }
    None => {
      let fallback = @scene.fragment([
        @scene.label(x=72.0, y=16.0, content="HP", color=0xFFFFFF),
        @scene.label(
          x=sw / 2.0,
          y=16.0,
          content="FLOOR " + self.world.floor.to_string(),
          color=0xCCCCCC,
          scale=1.2,
        ),
      ])
      let fallback_cmds = @scene.render_scene(
        fallback,
        ctx.dst,
        ctx.shader,
        sw,
        screen_h.to_double(),
      )
      for cmd in fallback_cmds {
        cmds.push(cmd)
      }
    }
  }
  cmds
}

///|
fn GameState::ensure_hud_static_cache(
  self : GameState,
  ctx : @hud.HudContext,
) -> Unit {
  let text_mode = self.hud_static_text_mode()
  if self.hud_static_cache_floor == self.world.floor &&
    self.hud_static_cache_dst_id == ctx.dst.id &&
    self.hud_static_cache_shader_id == ctx.shader.id &&
    self.hud_static_cache_text_mode == text_mode {
    return
  }
  self.hud_static_cmds = self.build_hud_static_cmds(ctx)
  self.hud_static_cache_floor = self.world.floor
  self.hud_static_cache_dst_id = ctx.dst.id
  self.hud_static_cache_shader_id = ctx.shader.id
  self.hud_static_cache_text_mode = text_mode
  self.hud_static_cache_builds = self.hud_static_cache_builds + 1
}

///|
fn minimap_layout(
  ctx : @hud.HudContext,
) -> (Double, Double, Double, Double, Int) {
  let map_size = 100.0
  let map_x = ctx.screen_w - map_size - 8.0
  let map_y = ctx.screen_h - map_size - 8.0
  let cell_size = 2.0
  let radius = (map_size / cell_size / 2.0).to_int()
  (map_size, map_x, map_y, cell_size, radius)
}

///|
fn find_room_index_at_minimap_tile(
  rooms : Array[@terrain.Room],
  gx : Int,
  gy : Int,
) -> Int {
  let point : @terrain.Point = { x: gx, y: gy }
  for i, room in rooms {
    if room.rect.contains(point) {
      return i
    }
  }
  -1
}

///|
fn GameState::build_minimap_static_cmds(
  self : GameState,
  ctx : @hud.HudContext,
  pcx : Int,
  pcy : Int,
) -> Array[@gfx.DrawTrianglesCommand] {
  let (map_size, map_x, map_y, cell_size, radius) = minimap_layout(ctx)
  let grid = self.world.dungeon.grid
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let border_vertices : Array[Double] = []
  let border_indices : Array[Int] = []
  let wall_vertices : Array[Double] = []
  let wall_indices : Array[Int] = []
  let floor_vertices : Array[Double] = []
  let floor_indices : Array[Int] = []
  let fog_vertices : Array[Double] = []
  let fog_indices : Array[Int] = []
  ctx.append_rect_batch_geometry(
    border_vertices,
    border_indices,
    map_x - 2.0,
    map_y - 2.0,
    map_size + 4.0,
    map_size + 4.0,
  )
  for dy = -radius; dy <= radius; dy = dy + 1 {
    for dx = -radius; dx <= radius; dx = dx + 1 {
      let gx = pcx + dx
      let gy = pcy + dy
      if gx >= 0 && gx < grid.width && gy >= 0 && gy < grid.height {
        let tile = grid.get(gx, gy)
        let color = if tile == @terrain.Wall {
          0x444444
        } else if tile == @terrain.Floor || tile == @terrain.Corridor {
          0x223322
        } else {
          continue
        }
        let sx = map_x + (dx + radius).to_double() * cell_size
        let sy = map_y + (dy + radius).to_double() * cell_size
        let room_index = find_room_index_at_minimap_tile(
          self.world.dungeon.rooms,
          gx,
          gy,
        )
        if tile == @terrain.Wall {
          ctx.append_rect_batch_geometry(
            wall_vertices, wall_indices, sx, sy, cell_size, cell_size,
          )
        } else {
          ctx.append_rect_batch_geometry(
            floor_vertices, floor_indices, sx, sy, cell_size, cell_size,
          )
        }
        if room_index >= 0 &&
          room_index < self.world.discovered_rooms.length() &&
          not(self.world.discovered_rooms[room_index]) {
          ctx.append_rect_batch_geometry(
            fog_vertices, fog_indices, sx, sy, cell_size, cell_size,
          )
        }
      }
    }
  }
  ctx.push_rect_batch_command(
    commands,
    border_vertices,
    border_indices,
    @hud.hex_color(0x000000, alpha=0.7),
  )
  ctx.push_rect_batch_command(
    commands,
    wall_vertices,
    wall_indices,
    @hud.hex_color(0x444444, alpha=0.9),
  )
  ctx.push_rect_batch_command(
    commands,
    floor_vertices,
    floor_indices,
    @hud.hex_color(0x223322, alpha=0.9),
  )
  ctx.push_rect_batch_command(
    commands,
    fog_vertices,
    fog_indices,
    @hud.hex_color(0x000000, alpha=0.75),
  )
  commands
}

///|
fn GameState::ensure_minimap_static_cache(
  self : GameState,
  ctx : @hud.HudContext,
  pcx : Int,
  pcy : Int,
) -> Unit {
  if self.minimap_cache_player_tile_x == pcx &&
    self.minimap_cache_player_tile_y == pcy &&
    self.minimap_cache_floor == self.world.floor &&
    self.minimap_cache_dst_id == ctx.dst.id &&
    self.minimap_cache_shader_id == ctx.shader.id &&
    self.minimap_cache_discovery_version == self.world.discovered_rooms_version {
    return
  }
  self.minimap_static_cmds = self.build_minimap_static_cmds(ctx, pcx, pcy)
  self.minimap_cache_player_tile_x = pcx
  self.minimap_cache_player_tile_y = pcy
  self.minimap_cache_floor = self.world.floor
  self.minimap_cache_dst_id = ctx.dst.id
  self.minimap_cache_shader_id = ctx.shader.id
  self.minimap_cache_discovery_version = self.world.discovered_rooms_version
  self.minimap_cache_builds = self.minimap_cache_builds + 1
}

///|
fn GameState::render_hud_cmds(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> Array[@gfx.DrawTrianglesCommand] {
  let sw = screen_w.to_double()
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let hp_ratio = self.world.player.hp.to_double() /
    self.world.player.max_hp.to_double()
  let hp_color = if hp_ratio > 0.5 {
    0x00CC00
  } else if hp_ratio > 0.25 {
    0xCCAA00
  } else {
    0xCC0000
  }
  let mut alive_count = 0
  for enemy in self.world.enemies {
    if enemy.alive {
      alive_count = alive_count + 1
    }
  }
  let ctx = self.make_hud_ctx(dst, shader)
  self.ensure_hud_static_cache(ctx)
  // HP bar background
  ctx.draw_rect(
    cmds,
    8.0,
    8.0,
    124.0,
    16.0,
    @hud.hex_color(0x440000, alpha=0.8),
  )
  // HP bar fill
  ctx.draw_rect(
    cmds,
    10.0,
    10.0,
    60.0 * hp_ratio * 2.0,
    12.0,
    @hud.hex_color(hp_color),
  )
  for cmd in self.hud_static_cmds {
    cmds.push(cmd)
  }
  match self.text_renderer {
    Some(tr) => {
      let _ = tr
      ctx.draw_text(
        cmds,
        self.world.score.to_string(),
        24.0,
        sw - 80.0,
        8.0,
        0xFFCC00,
      )
      ctx.draw_text(
        cmds,
        "x" + alive_count.to_string(),
        16.0,
        sw - 80.0,
        30.0,
        0xCC2222,
      )
      // Floor announce overlay
      if self.world.floor_announce_timer > 0 {
        let sh = screen_h.to_double()
        ctx.draw_text_centered(
          cmds,
          "FLOOR " + self.world.floor.to_string(),
          48.0,
          sw / 2.0,
          sh / 2.0,
          0xFFCC00,
        )
      }
    }
    None => {
      // Fallback: scene-based rendering
      let hud_node = self.render_hud_scene_fallback_dynamic(alive_count)
      let scene_cmds = @scene.render_scene(
        hud_node,
        dst,
        shader,
        sw,
        screen_h.to_double(),
      )
      for cmd in scene_cmds {
        cmds.push(cmd)
      }
    }
  }
  // Dash cooldown indicator
  if self.world.player.dash_cooldown_timer > 0 {
    let cd_ratio = self.world.player.dash_cooldown_timer.to_double() /
      dash_cooldown.to_double()
    ctx.draw_rect(
      cmds,
      10.0,
      28.0,
      120.0 * (1.0 - cd_ratio),
      4.0,
      @hud.hex_color(0x66DDFF, alpha=0.6),
    )
  }
  self.draw_spell_cooldowns(ctx, cmds)
  // Auto-play indicator
  if self.world.auto_play {
    ctx.draw_text(cmds, "AUTO", 14.0, 10.0, 92.0, 0x00FFAA)
  }
  if self.audio_muted {
    ctx.draw_text(
      cmds,
      "MUTE",
      14.0,
      screen_w.to_double() - 56.0,
      10.0,
      0xFF8899,
    )
  }
  self.draw_item_drop_labels(ctx, cmds)
  // Minimap
  self.render_minimap(ctx, cmds)
  cmds
}

///|
fn GameState::render_minimap(
  self : GameState,
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let (map_size, map_x, map_y, cell_size, radius) = minimap_layout(ctx)
  let pcx = (self.world.player.x / tile_size).to_int()
  let pcy = (self.world.player.y / tile_size).to_int()
  self.ensure_minimap_static_cache(ctx, pcx, pcy)
  for cmd in self.minimap_static_cmds {
    cmds.push(cmd)
  }
  let enemy_vertices : Array[Double] = []
  let enemy_indices : Array[Int] = []
  let boss_vertices : Array[Double] = []
  let boss_indices : Array[Int] = []
  for enemy in self.world.enemies {
    if enemy.alive {
      let enemy_room = @game.find_room_at(
        self.world.dungeon.rooms,
        enemy.x,
        enemy.y,
      )
      if enemy_room >= 0 &&
        enemy_room < self.world.discovered_rooms.length() &&
        not(self.world.discovered_rooms[enemy_room]) {
        continue
      }
      let ex = ((enemy.x / tile_size).to_int() - pcx + radius).to_double() *
        cell_size
      let ey = ((enemy.y / tile_size).to_int() - pcy + radius).to_double() *
        cell_size
      if ex >= 0.0 && ex < map_size && ey >= 0.0 && ey < map_size {
        let is_boss = enemy.kind == @game.Boss
        ctx.append_rect_batch_geometry(
          if is_boss {
            boss_vertices
          } else {
            enemy_vertices
          },
          if is_boss {
            boss_indices
          } else {
            enemy_indices
          },
          map_x + ex,
          map_y + ey,
          cell_size + 1.0,
          cell_size + 1.0,
        )
      }
    }
  }
  ctx.push_rect_batch_command(
    cmds,
    enemy_vertices,
    enemy_indices,
    @hud.hex_color(0xCC2222),
  )
  ctx.push_rect_batch_command(
    cmds,
    boss_vertices,
    boss_indices,
    @hud.hex_color(0xFF2266),
  )
  // Player dot (center)
  let px = map_x + radius.to_double() * cell_size
  let py = map_y + radius.to_double() * cell_size
  ctx.draw_rect(
    cmds,
    px - 1.0,
    py - 1.0,
    cell_size + 2.0,
    cell_size + 2.0,
    @hud.hex_color(0x00FFCC),
  )
}

///|
fn GameState::render_hud_scene_fallback(
  self : GameState,
  alive_count : Int,
) -> @scene.SceneNode {
  let sw = screen_w.to_double()
  @scene.fragment([
    @scene.label(
      x=sw - 80.0,
      y=16.0,
      content=self.world.score.to_string(),
      color=0xFFCC00,
      scale=1.5,
    ),
    @scene.label(
      x=sw - 80.0,
      y=36.0,
      content="x" + alive_count.to_string(),
      color=0xCC2222,
    ),
    @scene.show(fn() { self.world.floor_announce_timer > 0 }, fn() {
      let sh = screen_h.to_double()
      @scene.label(
        x=sw / 2.0,
        y=sh / 2.0,
        content="FLOOR " + self.world.floor.to_string(),
        color=0xFFCC00,
        scale=3.0,
      )
    }),
  ])
}

///|
fn GameState::render_hud_scene_fallback_dynamic(
  self : GameState,
  alive_count : Int,
) -> @scene.SceneNode {
  self.render_hud_scene_fallback(alive_count)
}

///|
fn GameState::render_title_cmds(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> Array[@gfx.DrawTrianglesCommand] {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let ctx = self.make_hud_ctx(dst, shader)
  // Background
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x1A1A2E))
  match self.text_renderer {
    Some(tr) => {
      let _ = tr
      ctx.draw_text_centered(
        cmds,
        "HACK N SLASH",
        48.0,
        sw / 2.0,
        sh / 2.0 - 60.0,
        0xFF4444,
      )
      ctx.draw_text_centered(
        cmds,
        "3D",
        32.0,
        sw / 2.0,
        sh / 2.0 - 10.0,
        0x44AAFF,
      )
      if self.world.frame_count / 30 % 2 == 0 {
        ctx.draw_text_centered(
          cmds,
          "PRESS SPACE",
          24.0,
          sw / 2.0,
          sh / 2.0 + 40.0,
          0xFFCC00,
        )
      }
    }
    None => {
      let fallback = @scene.fragment([
        @scene.label(
          x=sw / 2.0,
          y=sh / 2.0 - 60.0,
          content="HACK N SLASH",
          scale=3.0,
          color=0xFF4444,
        ),
        @scene.label(
          x=sw / 2.0,
          y=sh / 2.0 - 10.0,
          content="3D",
          scale=2.0,
          color=0x44AAFF,
        ),
        @scene.show(fn() { self.world.frame_count / 30 % 2 == 0 }, fn() {
          @scene.label(
            x=sw / 2.0,
            y=sh / 2.0 + 40.0,
            content="PRESS SPACE",
            color=0xFFCC00,
            scale=1.5,
          )
        }),
      ])
      let scene_cmds = @scene.render_scene(fallback, dst, shader, sw, sh)
      for cmd in scene_cmds {
        cmds.push(cmd)
      }
    }
  }
  self.draw_debug_reset_button(ctx, cmds, @game.Title)
  cmds
}

///|
fn GameState::render_gameover_cmds(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> Array[@gfx.DrawTrianglesCommand] {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let ctx = self.make_hud_ctx(dst, shader)
  // Background
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x2E0000))
  match self.text_renderer {
    Some(tr) => {
      let _ = tr
      ctx.draw_text_centered(
        cmds,
        "GAME OVER",
        48.0,
        sw / 2.0,
        sh / 2.0 - 60.0,
        0xFF0000,
      )
      ctx.draw_text_centered(
        cmds,
        "FLOOR " + self.world.floor.to_string(),
        24.0,
        sw / 2.0,
        sh / 2.0 + 5.0,
        0xFFCC00,
      )
      ctx.draw_text_centered(
        cmds,
        "SCORE " + self.world.score.to_string(),
        32.0,
        sw / 2.0,
        sh / 2.0 + 40.0,
        0xFFFFFF,
      )
      if self.world.frame_count / 30 % 2 == 0 {
        ctx.draw_text_centered(
          cmds,
          "PRESS SPACE",
          24.0,
          sw / 2.0,
          sh / 2.0 + 80.0,
          0x888888,
        )
      }
    }
    None => {
      let fallback = @scene.fragment([
        @scene.label(
          x=sw / 2.0,
          y=sh / 2.0 - 60.0,
          content="GAME OVER",
          color=0xFF0000,
          scale=3.0,
        ),
        @scene.label(
          x=sw / 2.0,
          y=sh / 2.0 + 5.0,
          content="FLOOR " + self.world.floor.to_string(),
          color=0xFFCC00,
          scale=1.5,
        ),
        @scene.label(
          x=sw / 2.0,
          y=sh / 2.0 + 40.0,
          content="SCORE " + self.world.score.to_string(),
          scale=2.0,
        ),
        @scene.show(fn() { self.world.frame_count / 30 % 2 == 0 }, fn() {
          @scene.label(
            x=sw / 2.0,
            y=sh / 2.0 + 80.0,
            content="PRESS SPACE",
            color=0x888888,
            scale=1.5,
          )
        }),
      ])
      let scene_cmds = @scene.render_scene(fallback, dst, shader, sw, sh)
      for cmd in scene_cmds {
        cmds.push(cmd)
      }
    }
  }
  self.draw_debug_reset_button(ctx, cmds, @game.GameOver)
  cmds
}

///|
/// Flush dirty atlas pages to GPU after text rendering.
fn GameState::flush_text_atlas(self : GameState) -> Unit {
  let renderer = match self.text_renderer {
    Some(r) => r
    None => return
  }
  let dirty_pages = renderer.flush_dirty_pages()
  if dirty_pages.length() > 0 {
    let bindings : Array[@asset.SourceImageBinding] = []
    for page_info in dirty_pages {
      let page_idx = page_info.page_id - renderer.get_page_id()
      let page = renderer.get_page(page_idx)
      let binding = @asset.new_source_image_binding(
        page_info.page_id,
        page_info.width,
        page_info.height,
        1,
        Some(
          @asset.new_source_image_dirty_rect(
            0,
            0,
            page_info.width,
            page_info.height,
          ),
        ),
        @image_palette.checker_palette_from_seed(page_info.page_id),
        page.get_pixels(),
      )
      bindings.push(binding)
    }
    let _ = @web_hooks.sync_source_images(bindings)
  }
}
