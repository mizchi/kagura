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
fn hp_bar_ratio_clamped(current : Int, max_hp : Int) -> Double {
  if max_hp <= 0 {
    return 0.0
  }
  let clamped_current = @cmp.maximum(0, @cmp.minimum(current, max_hp))
  clamped_current.to_double() / max_hp.to_double()
}

///|
fn hp_status_text(current : Int, max_hp : Int) -> String {
  let shown_max = @cmp.maximum(0, max_hp)
  let shown_current = @cmp.maximum(0, @cmp.minimum(current, shown_max))
  shown_current.to_string() + "/" + shown_max.to_string()
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
  let sh = screen_h.to_double()
  let sw = screen_w.to_double()
  // Horizontal skill bar at bottom-center
  let bar_y = sh - 26.0
  let slot_w = 80.0
  let total_w = slot_w * 4.0
  let start_x = (sw - total_w) / 2.0
  // Background
  ctx.draw_rect(
    cmds,
    start_x - 4.0,
    bar_y - 2.0,
    total_w + 8.0,
    18.0,
    @hud.hex_color(0x0A0A14, alpha=0.7),
  )
  self.draw_spell_cooldown_widget(
    ctx,
    cmds,
    "CL",
    start_x,
    bar_y,
    46.0,
    self.world.chain_lightning_cooldown_timer,
    self.world.params.chain_lightning_cooldown_frames(),
    0x77CCFF,
  )
  self.draw_spell_cooldown_widget(
    ctx,
    cmds,
    "FB",
    start_x + slot_w,
    bar_y,
    46.0,
    self.world.splitting_fireball_cooldown_timer,
    self.world.params.splitting_fireball_cooldown_frames(),
    0xFF9944,
  )
  self.draw_spell_cooldown_widget(
    ctx,
    cmds,
    "IN",
    start_x + slot_w * 2.0,
    bar_y,
    46.0,
    self.world.ice_nova_cooldown_timer,
    self.world.params.ice_nova_cooldown_frames(),
    0x99EEFF,
  )
  self.draw_spell_cooldown_widget(
    ctx,
    cmds,
    "HM",
    start_x + slot_w * 3.0,
    bar_y,
    46.0,
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
fn GameState::draw_damage_popups(
  self : GameState,
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  if self.damage_popups.is_empty() {
    return
  }
  let camera = self.camera.to_camera3d()
  for popup in self.damage_popups {
    let world_pos = @math3d.Vec3::new(
      popup.x / tile_size,
      @game.get_tile_height(self.world.dungeon, popup.x, popup.y) +
      1.1 +
      popup.rise,
      popup.y / tile_size,
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
          popup.amount.to_string(),
          12.0,
          sx,
          sy - 8.0,
          popup.color_hex,
        )
      None => ()
    }
  }
}

///|
fn GameState::draw_telegraph_markers(
  self : GameState,
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  if self.world.telegraph_markers.is_empty() {
    return
  }
  let camera = self.camera.to_camera3d()
  for marker in self.world.telegraph_markers {
    let progress = marker.progress()
    let world_y = @game.get_tile_height(
      self.world.dungeon,
      marker.x,
      marker.y,
    )
    let world_pos = @math3d.Vec3::new(
      marker.x / tile_size,
      world_y + 0.05,
      marker.y / tile_size,
    )
    match
      project_world_label_position(
        camera,
        world_pos,
        ctx.screen_w,
        ctx.screen_h,
      ) {
      Some((sx, sy)) => {
        // Scale radius from world to screen (approximate)
        let screen_radius = marker.radius / tile_size * 12.0
        // Color: orange fill that gets more red as progress increases
        let r_int = (255.0 * (0.6 + progress * 0.4)).to_int().min(255)
        let g_int = (100.0 * (1.0 - progress * 0.7)).to_int().max(0)
        let fill_color = (r_int << 16) | (g_int << 8) | 0x10
        let alpha = 0.15 + progress * 0.25
        // Draw filled circle (cross-rect approximation)
        let r = screen_radius * (0.3 + progress * 0.7) // grows with progress
        ctx.draw_rect(
          cmds,
          sx - r,
          sy - r * 0.7,
          r * 2.0,
          r * 1.4,
          @hud.hex_color(fill_color, alpha~),
        )
        ctx.draw_rect(
          cmds,
          sx - r * 0.7,
          sy - r,
          r * 1.4,
          r * 2.0,
          @hud.hex_color(fill_color, alpha~),
        )
        // Outer border (always full size, brighter)
        let border_alpha = 0.4 + progress * 0.4
        let border_r = screen_radius
        ctx.draw_rect(
          cmds,
          sx - border_r,
          sy - 1.0,
          border_r * 2.0,
          2.0,
          @hud.hex_color(0xFF3322, alpha=border_alpha),
        )
        ctx.draw_rect(
          cmds,
          sx - 1.0,
          sy - border_r,
          2.0,
          border_r * 2.0,
          @hud.hex_color(0xFF3322, alpha=border_alpha),
        )
        // Progress text for long casts (meteor)
        if marker.total_frames > 30 {
          let seconds_left = (marker.frames_remaining.to_double() / 60.0 *
            10.0).to_int().to_double() /
            10.0
          let time_text = seconds_left.to_int().to_string() + "s"
          ctx.draw_text_centered(
            cmds,
            time_text,
            12.0,
            sx,
            sy - screen_radius - 8.0,
            0xFF4422,
          )
        }
      }
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
  let sh = screen_h.to_double()
  match self.text_renderer {
    Some(tr) => {
      let _ = tr
      // HP label at bottom-left (above skill bar)
      ctx.draw_text(cmds, "HP", 12.0, 8.0, sh - 48.0, 0xFFFFFF)
      // FLOOR at top-center
      ctx.draw_text_centered(
        cmds,
        "FLOOR " + self.world.floor.to_string(),
        16.0,
        sw / 2.0,
        8.0,
        0xCCCCCC,
      )
    }
    None => {
      let fallback = @scene.fragment([
        @scene.label(x=24.0, y=sh - 48.0, content="HP", color=0xFFFFFF),
        @scene.label(
          x=sw / 2.0,
          y=8.0,
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
fn GameState::render_character_select_cmds(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> Array[@gfx.DrawTrianglesCommand] {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let ctx = self.make_hud_ctx(dst, shader)
  // Background
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x0E1020))
  let archetypes = @game.selectable_archetypes()
  let cursor = self.world.select_cursor
  let title_y = sh / 2.0 - 120.0
  let start_y = sh / 2.0 - 50.0
  let row_height = 60.0
  match self.text_renderer {
    Some(tr) => {
      let _ = tr
      ctx.draw_text_centered(
        cmds,
        "SELECT CLASS",
        36.0,
        sw / 2.0,
        title_y,
        0xFFCC00,
      )
      for i, archetype in archetypes {
        let y = start_y + i.to_double() * row_height
        let is_selected = i == cursor
        let name_color = if is_selected { 0xFFFFFF } else { 0x888888 }
        let stat_color = if is_selected { 0xAADDFF } else { 0x556677 }
        // Selection indicator
        if is_selected {
          ctx.draw_rect(
            cmds,
            sw / 2.0 - 140.0,
            y - 6.0,
            280.0,
            48.0,
            @hud.hex_color(0x334466, alpha=0.6),
          )
          ctx.draw_text(cmds, ">", 20.0, sw / 2.0 - 130.0, y, 0xFFCC00)
        }
        ctx.draw_text_centered(
          cmds,
          archetype.display_name(),
          24.0,
          sw / 2.0,
          y,
          name_color,
        )
        let stats_text = "STR " +
          archetype.base_strength().to_string() +
          "  INT " +
          archetype.base_intelligence().to_string() +
          "  DEX " +
          archetype.base_dexterity().to_string()
        ctx.draw_text_centered(
          cmds,
          stats_text,
          14.0,
          sw / 2.0,
          y + 24.0,
          stat_color,
        )
      }
      // Instructions
      if self.world.frame_count / 30 % 2 == 0 {
        ctx.draw_text_centered(
          cmds,
          "UP/DOWN + SPACE",
          16.0,
          sw / 2.0,
          start_y + archetypes.length().to_double() * row_height + 20.0,
          0x666666,
        )
      }
    }
    None => {
      let nodes : Array[@scene.SceneNode] = []
      nodes.push(
        @scene.label(
          x=sw / 2.0,
          y=title_y,
          content="SELECT CLASS",
          scale=2.5,
          color=0xFFCC00,
        ),
      )
      for i, archetype in archetypes {
        let y = start_y + i.to_double() * row_height
        let is_selected = i == cursor
        let name_color = if is_selected { 0xFFFFFF } else { 0x888888 }
        let prefix = if is_selected { "> " } else { "  " }
        nodes.push(
          @scene.label(
            x=sw / 2.0,
            y=y,
            content=prefix + archetype.display_name(),
            scale=1.5,
            color=name_color,
          ),
        )
        let stats_text = "STR " +
          archetype.base_strength().to_string() +
          " INT " +
          archetype.base_intelligence().to_string() +
          " DEX " +
          archetype.base_dexterity().to_string()
        nodes.push(
          @scene.label(
            x=sw / 2.0,
            y=y + 24.0,
            content=stats_text,
            color=0x556677,
          ),
        )
      }
      let fallback = @scene.fragment(nodes)
      let scene_cmds = @scene.render_scene(fallback, dst, shader, sw, sh)
      for cmd in scene_cmds {
        cmds.push(cmd)
      }
    }
  }
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
