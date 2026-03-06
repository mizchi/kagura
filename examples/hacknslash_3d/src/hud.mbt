// HUD: HP bar, floor, score, enemy count, dash cooldown (no minimap)
// Uses @hud.HudContext for rendering, falls back to @scene.label when TextRenderer is unavailable.

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

fn GameState::render_hud_cmds(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> Array[@gfx.DrawTrianglesCommand] {
  let sw = screen_w.to_double()
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let hp_ratio = self.player.hp.to_double() / self.player.max_hp.to_double()
  let hp_color = if hp_ratio > 0.5 {
    0x00CC00
  } else if hp_ratio > 0.25 {
    0xCCAA00
  } else {
    0xCC0000
  }
  let mut alive_count = 0
  for enemy in self.enemies {
    if enemy.alive {
      alive_count = alive_count + 1
    }
  }
  let ctx = self.make_hud_ctx(dst, shader)
  // HP bar background
  ctx.draw_rect(cmds, 8.0, 8.0, 124.0, 16.0, @hud.hex_color(0x440000, alpha=0.8))
  // HP bar fill
  ctx.draw_rect(cmds, 10.0, 10.0, 60.0 * hp_ratio * 2.0, 12.0, @hud.hex_color(hp_color))
  match self.text_renderer {
    Some(tr) => {
      let _ = tr
      // TTF text
      ctx.draw_text(cmds, "HP", 16.0, 60.0, 8.0, 0xFFFFFF)
      ctx.draw_text_centered(
        cmds, "FLOOR " + self.floor.to_string(),
        20.0, sw / 2.0, 16.0, 0xCCCCCC,
      )
      ctx.draw_text(
        cmds, self.score.to_string(),
        24.0, sw - 80.0, 8.0, 0xFFCC00,
      )
      ctx.draw_text(
        cmds, "x" + alive_count.to_string(),
        16.0, sw - 80.0, 30.0, 0xCC2222,
      )
      // Floor announce overlay
      if self.floor_announce_timer > 0 {
        let sh = screen_h.to_double()
        ctx.draw_text_centered(
          cmds, "FLOOR " + self.floor.to_string(),
          48.0, sw / 2.0, sh / 2.0, 0xFFCC00,
        )
      }
    }
    None => {
      // Fallback: scene-based rendering
      let hud_node = self.render_hud_scene_fallback(alive_count)
      let scene_cmds = @scene.render_scene(hud_node, dst, shader, sw, screen_h.to_double())
      for cmd in scene_cmds {
        cmds.push(cmd)
      }
    }
  }
  // Dash cooldown indicator
  if self.player.dash_cooldown_timer > 0 {
    let cd_ratio = self.player.dash_cooldown_timer.to_double() / dash_cooldown.to_double()
    ctx.draw_rect(cmds, 10.0, 28.0, 120.0 * (1.0 - cd_ratio), 4.0, @hud.hex_color(0x66DDFF, alpha=0.6))
  }
  cmds
}

fn GameState::render_hud_scene_fallback(
  self : GameState,
  alive_count : Int,
) -> @scene.SceneNode {
  let sw = screen_w.to_double()
  @scene.fragment([
    @scene.label(x=72.0, y=16.0, content="HP", color=0xFFFFFF),
    @scene.label(
      x=sw / 2.0, y=16.0,
      content="FLOOR " + self.floor.to_string(),
      color=0xCCCCCC, scale=1.2,
    ),
    @scene.label(
      x=sw - 80.0, y=16.0,
      content=self.score.to_string(),
      color=0xFFCC00, scale=1.5,
    ),
    @scene.label(
      x=sw - 80.0, y=36.0,
      content="x" + alive_count.to_string(),
      color=0xCC2222,
    ),
    @scene.show(fn() { self.floor_announce_timer > 0 }, fn() {
      let sh = screen_h.to_double()
      @scene.label(
        x=sw / 2.0, y=sh / 2.0,
        content="FLOOR " + self.floor.to_string(),
        color=0xFFCC00, scale=3.0,
      )
    }),
  ])
}

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
        cmds, "HACK N SLASH", 48.0,
        sw / 2.0, sh / 2.0 - 60.0, 0xFF4444,
      )
      ctx.draw_text_centered(
        cmds, "3D", 32.0,
        sw / 2.0, sh / 2.0 - 10.0, 0x44AAFF,
      )
      if self.frame_count / 30 % 2 == 0 {
        ctx.draw_text_centered(
          cmds, "PRESS SPACE", 24.0,
          sw / 2.0, sh / 2.0 + 40.0, 0xFFCC00,
        )
      }
    }
    None => {
      let fallback = @scene.fragment([
        @scene.label(
          x=sw / 2.0, y=sh / 2.0 - 60.0,
          content="HACK N SLASH", scale=3.0, color=0xFF4444,
        ),
        @scene.label(
          x=sw / 2.0, y=sh / 2.0 - 10.0,
          content="3D", scale=2.0, color=0x44AAFF,
        ),
        @scene.show(fn() { self.frame_count / 30 % 2 == 0 }, fn() {
          @scene.label(
            x=sw / 2.0, y=sh / 2.0 + 40.0,
            content="PRESS SPACE", color=0xFFCC00, scale=1.5,
          )
        }),
      ])
      let scene_cmds = @scene.render_scene(fallback, dst, shader, sw, sh)
      for cmd in scene_cmds {
        cmds.push(cmd)
      }
    }
  }
  cmds
}

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
        cmds, "GAME OVER", 48.0,
        sw / 2.0, sh / 2.0 - 60.0, 0xFF0000,
      )
      ctx.draw_text_centered(
        cmds, "FLOOR " + self.floor.to_string(), 24.0,
        sw / 2.0, sh / 2.0 + 5.0, 0xFFCC00,
      )
      ctx.draw_text_centered(
        cmds, "SCORE " + self.score.to_string(), 32.0,
        sw / 2.0, sh / 2.0 + 40.0, 0xFFFFFF,
      )
      if self.frame_count / 30 % 2 == 0 {
        ctx.draw_text_centered(
          cmds, "PRESS SPACE", 24.0,
          sw / 2.0, sh / 2.0 + 80.0, 0x888888,
        )
      }
    }
    None => {
      let fallback = @scene.fragment([
        @scene.label(
          x=sw / 2.0, y=sh / 2.0 - 60.0,
          content="GAME OVER", color=0xFF0000, scale=3.0,
        ),
        @scene.label(
          x=sw / 2.0, y=sh / 2.0 + 5.0,
          content="FLOOR " + self.floor.to_string(),
          color=0xFFCC00, scale=1.5,
        ),
        @scene.label(
          x=sw / 2.0, y=sh / 2.0 + 40.0,
          content="SCORE " + self.score.to_string(), scale=2.0,
        ),
        @scene.show(fn() { self.frame_count / 30 % 2 == 0 }, fn() {
          @scene.label(
            x=sw / 2.0, y=sh / 2.0 + 80.0,
            content="PRESS SPACE", color=0x888888, scale=1.5,
          )
        }),
      ])
      let scene_cmds = @scene.render_scene(fallback, dst, shader, sw, sh)
      for cmd in scene_cmds {
        cmds.push(cmd)
      }
    }
  }
  cmds
}

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
            0, 0, page_info.width, page_info.height,
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
