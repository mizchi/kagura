///|
fn minimap_layout(
  ctx : @hud.HudContext,
) -> (Double, Double, Double, Double, Int) {
  let map_size = 100.0
  let map_x = ctx.screen_w - map_size - 8.0
  let map_y = 8.0 // top-right
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
          !(self.world.discovered_rooms[room_index]) {
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
  let hp_ratio = hp_bar_ratio_clamped(
    self.world.player.hp,
    self.world.player.max_hp,
  )
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
  let sh = screen_h.to_double()
  // HP bar at bottom-left (above skill bar)
  let hp_y = sh - 46.0
  ctx.draw_rect(
    cmds,
    8.0,
    hp_y,
    140.0,
    14.0,
    @hud.hex_color(0x440000, alpha=0.8),
  )
  ctx.draw_rect(
    cmds,
    10.0,
    hp_y + 2.0,
    68.0 * hp_ratio * 2.0,
    10.0,
    @hud.hex_color(hp_color),
  )
  for cmd in self.hud_static_cmds {
    cmds.push(cmd)
  }
  match self.text_renderer {
    Some(tr) => {
      let _ = tr
      // Score + enemy count at top-left (clear of minimap)
      ctx.draw_text(
        cmds,
        self.world.score.to_string() + "G",
        16.0,
        8.0,
        8.0,
        0xFFCC00,
      )
      ctx.draw_text(
        cmds,
        "x" + alive_count.to_string(),
        12.0,
        8.0,
        24.0,
        0xCC2222,
      )
      // HP text next to HP bar (bottom-left)
      ctx.draw_text(
        cmds,
        hp_status_text(self.world.player.hp, self.world.player.max_hp),
        12.0,
        152.0,
        hp_y + 1.0,
        0xFFFFFF,
      )
      // Floor announce overlay
      if self.world.floor_announce_timer > 0 {
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
      let hud_node = self.render_hud_scene_fallback_dynamic(alive_count)
      let scene_cmds = @scene.render_scene(hud_node, dst, shader, sw, sh)
      for cmd in scene_cmds {
        cmds.push(cmd)
      }
      ctx.draw_text(
        cmds,
        hp_status_text(self.world.player.hp, self.world.player.max_hp),
        12.0,
        152.0,
        hp_y + 1.0,
        0xFFFFFF,
      )
    }
  }
  // Skill cooldowns at bottom-center
  self.draw_spell_cooldowns(ctx, cmds)
  // Dash cooldown at bottom-center (below skills)
  if self.world.player.dash_cooldown_timer > 0 {
    let cd_ratio = self.world.player.dash_cooldown_timer.to_double() /
      dash_cooldown.to_double()
    let dash_x = sw / 2.0 - 60.0
    ctx.draw_rect(
      cmds,
      dash_x,
      sh - 10.0,
      120.0 * (1.0 - cd_ratio),
      4.0,
      @hud.hex_color(0x66DDFF, alpha=0.6),
    )
  }
  // Meteor warning: flash when any enemy is casting
  let mut meteor_active = false
  for enemy in self.world.enemies {
    if enemy.alive && enemy.meteor_cast_timer > 0 {
      meteor_active = true
      break
    }
  }
  if meteor_active && self.world.frame_count / 15 % 2 == 0 {
    ctx.draw_text_centered(
      cmds,
      "!! METEOR !!",
      16.0,
      sw / 2.0,
      sh - 60.0,
      0xFF2222,
    )
  }
  // Pause indicator
  if self.paused {
    ctx.draw_text_centered(
      cmds,
      "PAUSED",
      24.0,
      sw / 2.0,
      sh / 2.0 - 20.0,
      0xFFFFFF,
    )
  }
  // Auto-play indicator at top-left
  if self.world.auto_play {
    ctx.draw_text(cmds, "AUTO", 10.0, 8.0, 38.0, 0x00FFAA)
  }
  if self.audio_muted {
    ctx.draw_text(cmds, "MUTE", 12.0, sw - 56.0, sh - 10.0, 0xFF8899)
  }
  self.draw_damage_popups(ctx, cmds)
  self.draw_item_drop_labels(ctx, cmds)
  // Minimap
  self.render_minimap(ctx, cmds)
  // Item acquisition log (below minimap, flows top to bottom)
  self.draw_item_log(ctx, cmds)
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
        !(self.world.discovered_rooms[enemy_room]) {
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
fn GameState::draw_item_log(
  self : GameState,
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let log = self.world.item_log
  if log.length() == 0 {
    return
  }
  // Position: right side, below minimap (minimap is at top-right, 100x100 + 8px padding)
  let log_x = ctx.screen_w - 108.0
  let log_top = 116.0 // 8 (minimap top) + 100 (minimap size) + 8 (gap)
  let line_height = 14.0
  let font_size = 10.0
  for i, entry in log {
    let y = log_top + i.to_double() * line_height
    ctx.draw_text(cmds, entry.text, font_size, log_x, y, entry.color)
  }
}
