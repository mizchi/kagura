// RPG UI: inventory and skill tree screens

fn GameState::update_ui(self : GameState) -> Unit {
  match self.ui_mode {
    m if m == ui_mode_inventory => self.update_inventory_ui()
    m if m == ui_mode_skills => self.update_skills_ui()
    _ => ()
  }
}

fn is_up_just_pressed(input : @inpututil.InputHelper) -> Bool {
  @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_w) ||
  @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_up_web)
}

fn is_down_just_pressed(input : @inpututil.InputHelper) -> Bool {
  @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_s) ||
  @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_down_web)
}

fn GameState::update_inventory_ui(self : GameState) -> Unit {
  let cap = self.inventory.capacity
  if is_up_just_pressed(self.input) {
    self.ui_cursor = (self.ui_cursor - 1 + cap) % cap
  }
  if is_down_just_pressed(self.input) {
    self.ui_cursor = (self.ui_cursor + 1) % cap
  }
  // Equip with E
  if @inpututil.is_key_just_pressed(self.input.key_state, key_e) {
    match self.inventory.items[self.ui_cursor] {
      Some(item) => {
        let prev = self.equipment.equip(item)
        self.inventory.items[self.ui_cursor] = prev
        self.player_stats = compute_player_stats(self.equipment, self.skills)
        // Update player max_hp
        self.player.hp = @cmp.minimum(self.player.hp, self.player_stats.max_hp)
      }
      None => ()
    }
  }
}

fn GameState::update_skills_ui(self : GameState) -> Unit {
  let node_count = self.skills.nodes.length()
  if is_up_just_pressed(self.input) {
    self.ui_cursor = (self.ui_cursor - 1 + node_count) % node_count
  }
  if is_down_just_pressed(self.input) {
    self.ui_cursor = (self.ui_cursor + 1) % node_count
  }
  // Learn with Space/Enter
  if @inpututil.is_confirm_just_pressed(self.input) {
    let node = self.skills.nodes[self.ui_cursor]
    if self.skills.learn(node.id) {
      self.player_stats = compute_player_stats(self.equipment, self.skills)
    }
  }
}

fn GameState::render_rpg_ui_cmds(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  match self.ui_mode {
    m if m == ui_mode_inventory => self.render_inventory_ui(dst, shader, cmds)
    m if m == ui_mode_skills => self.render_skills_ui(dst, shader, cmds)
    _ => ()
  }
  cmds
}

fn GameState::render_inventory_ui(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let ctx = self.make_hud_ctx(dst, shader)
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  // Semi-transparent backdrop
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x000000, alpha=0.6))
  // Inventory panel
  let panel_w = 300.0
  let panel_h = 380.0
  let px = (sw - panel_w) / 2.0
  let py = (sh - panel_h) / 2.0
  let panel : @hud.Panel = {
    x: px, y: py, width: panel_w, height: panel_h,
    bg_color: 0x1A1A2E, border_color: 0x4444AA, border_width: 2.0,
    title: "INVENTORY", title_size: 20.0, title_color: 0xFFCC00,
    title_bg_color: 0x2A2A4E,
  }
  let (_, cy, cw, _) = panel.render(ctx, cmds)
  let _ = cw
  // Equipment slots
  let eq_y = cy + 8.0
  ctx.draw_text(cmds, "EQUIPMENT", 14.0, px + 10.0, eq_y, 0xCCCCCC)
  let slot_labels = ["WPN", "ARM", "ACC"]
  let slot_items = [self.equipment.weapon, self.equipment.armor, self.equipment.accessory]
  for i, label in slot_labels {
    let sy = eq_y + 20.0 + i.to_double() * 22.0
    ctx.draw_rect(cmds, px + 10.0, sy, 280.0, 20.0, @hud.hex_color(0x222244))
    ctx.draw_text(cmds, label, 12.0, px + 14.0, sy + 2.0, 0x888888)
    match slot_items[i] {
      Some(item) => {
        let color = item.rarity.color()
        ctx.draw_text(cmds, item.name, 12.0, px + 50.0, sy + 2.0, color)
        ctx.draw_text(
          cmds,
          "A:" + item.atk_bonus.to_string() + " D:" + item.def_bonus.to_string() + " H:" + item.hp_bonus.to_string(),
          10.0, px + 180.0, sy + 4.0, 0xAAAAAA,
        )
      }
      None => ctx.draw_text(cmds, "---", 12.0, px + 50.0, sy + 2.0, 0x555555)
    }
  }
  // Inventory list
  let inv_y = eq_y + 90.0
  ctx.draw_text(cmds, "ITEMS (" + self.inventory.count().to_string() + "/" + self.inventory.capacity.to_string() + ")", 14.0, px + 10.0, inv_y, 0xCCCCCC)
  ctx.draw_text(cmds, "[E] Equip  [I] Close", 10.0, px + 10.0, inv_y + 16.0, 0x666666)
  let list_y = inv_y + 32.0
  let visible = @cmp.minimum(self.inventory.capacity, 10)
  // Scroll offset
  let scroll = if self.ui_cursor >= visible { self.ui_cursor - visible + 1 } else { 0 }
  for i in 0..<visible {
    let idx = scroll + i
    if idx >= self.inventory.capacity {
      break
    }
    let iy = list_y + i.to_double() * 20.0
    let is_selected = idx == self.ui_cursor
    let bg = if is_selected { 0x3333AA } else { 0x222233 }
    ctx.draw_rect(cmds, px + 10.0, iy, 280.0, 18.0, @hud.hex_color(bg))
    match self.inventory.items[idx] {
      Some(item) => {
        let color = item.rarity.color()
        ctx.draw_text(cmds, item.name, 12.0, px + 14.0, iy + 2.0, color)
        ctx.draw_text(
          cmds,
          "A:" + item.atk_bonus.to_string() + " D:" + item.def_bonus.to_string(),
          10.0, px + 200.0, iy + 3.0, 0xAAAAAA,
        )
      }
      None => ctx.draw_text(cmds, "---", 12.0, px + 14.0, iy + 2.0, 0x333333)
    }
  }
  // Stats summary
  let stats_y = list_y + visible.to_double() * 20.0 + 8.0
  let s = self.player_stats
  ctx.draw_text(
    cmds,
    "ATK:" + s.atk.to_string() + "  DEF:" + s.def.to_string() + "  HP:" + s.max_hp.to_string(),
    12.0, px + 10.0, stats_y, 0x88FF88,
  )
}

fn GameState::render_skills_ui(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let ctx = self.make_hud_ctx(dst, shader)
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x000000, alpha=0.6))
  let panel_w = 320.0
  let panel_h = 340.0
  let px = (sw - panel_w) / 2.0
  let py = (sh - panel_h) / 2.0
  let panel : @hud.Panel = {
    x: px, y: py, width: panel_w, height: panel_h,
    bg_color: 0x1A1A2E, border_color: 0xAA44AA, border_width: 2.0,
    title: "SKILL TREE", title_size: 20.0, title_color: 0xFFCC00,
    title_bg_color: 0x2E1A2E,
  }
  let (_, cy, _, _) = panel.render(ctx, cmds)
  // Skill points
  ctx.draw_text(
    cmds,
    "Skill Points: " + self.skills.skill_points.to_string(),
    14.0, px + 10.0, cy + 8.0, 0xFFCC00,
  )
  ctx.draw_text(cmds, "[Space] Learn  [K] Close", 10.0, px + 10.0, cy + 26.0, 0x666666)
  let list_y = cy + 44.0
  for i, node in self.skills.nodes {
    let ny = list_y + i.to_double() * 42.0
    let is_selected = i == self.ui_cursor
    let can_learn = self.skills.can_learn(node.id)
    let bg = if is_selected { 0x3333AA } else { 0x222233 }
    ctx.draw_rect(cmds, px + 10.0, ny, 300.0, 38.0, @hud.hex_color(bg))
    // Skill name + level
    let name_color = if node.level > 0 { 0x44FF44 } else if can_learn { 0xFFCC00 } else { 0x666666 }
    ctx.draw_text(cmds, node.name, 14.0, px + 14.0, ny + 2.0, name_color)
    // Level bar
    let level_text = node.level.to_string() + "/" + node.max_level.to_string()
    ctx.draw_text(cmds, "Lv " + level_text, 12.0, px + 200.0, ny + 2.0, 0xCCCCCC)
    // Cost
    ctx.draw_text(
      cmds,
      "Cost: " + node.cost.to_string() + "SP",
      10.0, px + 14.0, ny + 20.0, 0x888888,
    )
    // Level progress bar
    if node.max_level > 0 {
      let bar_ratio = node.level.to_double() / node.max_level.to_double()
      ctx.draw_rect(cmds, px + 200.0, ny + 22.0, 100.0, 8.0, @hud.hex_color(0x333333))
      if bar_ratio > 0.0 {
        ctx.draw_rect(cmds, px + 200.0, ny + 22.0, 100.0 * bar_ratio, 8.0, @hud.hex_color(0x44AA44))
      }
    }
  }
}
