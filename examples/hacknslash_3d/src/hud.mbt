// HUD: HP bar, floor, score, enemy count, dash cooldown (no minimap)
// Uses TTF text rendering via TextRenderer when available,
// falls back to @scene.label (dot-matrix) otherwise.

fn hex_to_color(hex : Int, alpha~ : Double = 1.0) -> @gfx.Color {
  let r = ((hex >> 16) & 0xFF).to_double() / 255.0
  let g = ((hex >> 8) & 0xFF).to_double() / 255.0
  let b = (hex & 0xFF).to_double() / 255.0
  @gfx.new_color(r, g, b, alpha)
}

fn hex_to_uniform(hex : Int, alpha~ : Int = 255) -> Array[Int] {
  [(hex >> 16) & 0xFF, (hex >> 8) & 0xFF, hex & 0xFF, alpha]
}

fn add_rect(
  cmds : Array[@gfx.DrawTrianglesCommand],
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  color : @gfx.Color,
) -> Unit {
  cmds.push(
    @debugutil.new_ndc_rect_fill_command(
      dst, shader, x, y, w, h,
      screen_w.to_double(), screen_h.to_double(), color, 0,
    ),
  )
}

fn add_text(
  cmds : Array[@gfx.DrawTrianglesCommand],
  renderer : @text.TextRenderer,
  text : String,
  size : Double,
  x : Double,
  y : Double,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  color_hex : Int,
) -> Unit {
  let blend = @gfx.blend_mode_from_int(1)
  let text_cmds = renderer.render_text(
    text, size, x, y, dst, shader, blend, hex_to_uniform(color_hex),
  )
  for cmd in text_cmds {
    cmds.push(cmd)
  }
}

fn add_text_centered(
  cmds : Array[@gfx.DrawTrianglesCommand],
  renderer : @text.TextRenderer,
  text : String,
  size : Double,
  cx : Double,
  cy : Double,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  color_hex : Int,
) -> Unit {
  let metrics = renderer.measure(text, size)
  let x = cx - metrics.width / 2.0
  let y = cy - metrics.height / 2.0
  add_text(cmds, renderer, text, size, x, y, dst, shader, color_hex)
}

fn GameState::render_hud_cmds(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> Array[@gfx.DrawTrianglesCommand] {
  let sw = screen_w.to_double()
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let hp_ratio = self.player.hp.to_double() / self.player.max_hp.to_double()
  let hp_width = 60.0 * hp_ratio
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
  // HP bar background
  add_rect(cmds, dst, shader, 8.0, 8.0, 124.0, 16.0, hex_to_color(0x440000, alpha=0.8))
  // HP bar fill
  add_rect(cmds, dst, shader, 10.0, 10.0, hp_width * 2.0, 12.0, hex_to_color(hp_color))
  match self.text_renderer {
    Some(tr) => {
      // TTF text
      add_text(cmds, tr, "HP", 16.0, 60.0, 8.0, dst, shader, 0xFFFFFF)
      add_text_centered(
        cmds, tr, "FLOOR " + self.floor.to_string(),
        20.0, sw / 2.0, 16.0, dst, shader, 0xCCCCCC,
      )
      add_text(
        cmds, tr, self.score.to_string(),
        24.0, sw - 80.0, 8.0, dst, shader, 0xFFCC00,
      )
      add_text(
        cmds, tr, "x" + alive_count.to_string(),
        16.0, sw - 80.0, 30.0, dst, shader, 0xCC2222,
      )
      // Floor announce overlay
      if self.floor_announce_timer > 0 {
        let sh = screen_h.to_double()
        add_text_centered(
          cmds, tr, "FLOOR " + self.floor.to_string(),
          48.0, sw / 2.0, sh / 2.0, dst, shader, 0xFFCC00,
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
    add_rect(cmds, dst, shader, 10.0, 28.0, 120.0 * (1.0 - cd_ratio), 4.0, hex_to_color(0x66DDFF, alpha=0.6))
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
  // Background
  add_rect(cmds, dst, shader, 0.0, 0.0, sw, sh, hex_to_color(0x1A1A2E))
  match self.text_renderer {
    Some(tr) => {
      add_text_centered(
        cmds, tr, "HACK N SLASH", 48.0,
        sw / 2.0, sh / 2.0 - 60.0, dst, shader, 0xFF4444,
      )
      add_text_centered(
        cmds, tr, "3D", 32.0,
        sw / 2.0, sh / 2.0 - 10.0, dst, shader, 0x44AAFF,
      )
      if self.frame_count / 30 % 2 == 0 {
        add_text_centered(
          cmds, tr, "PRESS SPACE", 24.0,
          sw / 2.0, sh / 2.0 + 40.0, dst, shader, 0xFFCC00,
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
  // Background
  add_rect(cmds, dst, shader, 0.0, 0.0, sw, sh, hex_to_color(0x2E0000))
  match self.text_renderer {
    Some(tr) => {
      add_text_centered(
        cmds, tr, "GAME OVER", 48.0,
        sw / 2.0, sh / 2.0 - 60.0, dst, shader, 0xFF0000,
      )
      add_text_centered(
        cmds, tr, "FLOOR " + self.floor.to_string(), 24.0,
        sw / 2.0, sh / 2.0 + 5.0, dst, shader, 0xFFCC00,
      )
      add_text_centered(
        cmds, tr, "SCORE " + self.score.to_string(), 32.0,
        sw / 2.0, sh / 2.0 + 40.0, dst, shader, 0xFFFFFF,
      )
      if self.frame_count / 30 % 2 == 0 {
        add_text_centered(
          cmds, tr, "PRESS SPACE", 24.0,
          sw / 2.0, sh / 2.0 + 80.0, dst, shader, 0x888888,
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
