// RPG UI: inventory and skill tree screens

fn format_affix_stats(a : @game.Affix) -> String {
  let parts : Array[String] = []
  if a.atk != 0 { parts.push("A" + format_signed(a.atk)) }
  if a.def != 0 { parts.push("D" + format_signed(a.def)) }
  if a.hp != 0 { parts.push("H" + format_signed(a.hp)) }
  if a.crit > 0.001 {
    let pct = (a.crit * 100.0).to_int()
    parts.push("Crit+" + pct.to_string() + "%")
  }
  if a.life_steal > 0.001 {
    let pct = (a.life_steal * 100.0).to_int()
    parts.push("LS+" + pct.to_string() + "%")
  }
  let mut result = ""
  for i, p in parts {
    if i > 0 { result = result + " " }
    result = result + p
  }
  result
}

fn format_signed(v : Int) -> String {
  if v > 0 { "+" + v.to_string() } else { v.to_string() }
}

fn GameState::update_ui(self : GameState) -> Unit {
  match self.world.ui_mode {
    @game.Inventory => self.update_inventory_ui()
    @game.Skills => self.update_skills_ui()
    @game.UIMode::None => ()
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
  let cap = self.world.inventory.capacity
  if is_up_just_pressed(self.input) {
    self.world.ui_cursor = (self.world.ui_cursor - 1 + cap) % cap
  }
  if is_down_just_pressed(self.input) {
    self.world.ui_cursor = (self.world.ui_cursor + 1) % cap
  }
  // Equip with E
  if @inpututil.is_key_just_pressed(self.input.key_state, key_e) {
    match self.world.inventory.items[self.world.ui_cursor] {
      Some(item) => {
        let prev = self.world.equipment.equip(item)
        self.world.inventory.items[self.world.ui_cursor] = prev
        self.world.player_stats = @game.compute_player_stats(self.world.equipment, self.world.skills)
        // Update player max_hp
        self.world.player.hp = @cmp.minimum(self.world.player.hp, self.world.player_stats.max_hp)
      }
      None => ()
    }
  }
}

fn GameState::update_skills_ui(self : GameState) -> Unit {
  let node_count = self.world.skills.nodes.length()
  if is_up_just_pressed(self.input) {
    self.world.ui_cursor = (self.world.ui_cursor - 1 + node_count) % node_count
  }
  if is_down_just_pressed(self.input) {
    self.world.ui_cursor = (self.world.ui_cursor + 1) % node_count
  }
  // Learn with Space/Enter
  if @inpututil.is_confirm_just_pressed(self.input) {
    let node = self.world.skills.nodes[self.world.ui_cursor]
    if self.world.skills.learn(node.id) {
      self.world.player_stats = @game.compute_player_stats(self.world.equipment, self.world.skills)
    }
  }
}

fn GameState::render_rpg_ui_cmds(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  match self.world.ui_mode {
    @game.Inventory => self.render_inventory_ui(dst, shader, cmds)
    @game.Skills => self.render_skills_ui(dst, shader, cmds)
    @game.UIMode::None => ()
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
  let slot_items = [self.world.equipment.weapon, self.world.equipment.armor, self.world.equipment.accessory]
  for i, label in slot_labels {
    let sy = eq_y + 20.0 + i.to_double() * 22.0
    ctx.draw_rect(cmds, px + 10.0, sy, 280.0, 20.0, @hud.hex_color(0x222244))
    ctx.draw_text(cmds, label, 12.0, px + 14.0, sy + 2.0, 0x888888)
    match slot_items[i] {
      Some(item) => {
        let color = item.rarity.color()
        ctx.draw_text(cmds, item.display_name(), 12.0, px + 50.0, sy + 2.0, color)
        ctx.draw_text(
          cmds,
          "A:" + item.total_atk().to_string() + " D:" + item.total_def().to_string() + " H:" + item.total_hp().to_string(),
          10.0, px + 180.0, sy + 4.0, 0xAAAAAA,
        )
      }
      None => ctx.draw_text(cmds, "---", 12.0, px + 50.0, sy + 2.0, 0x555555)
    }
  }
  // Inventory list
  let inv_y = eq_y + 90.0
  ctx.draw_text(cmds, "ITEMS (" + self.world.inventory.count().to_string() + "/" + self.world.inventory.capacity.to_string() + ")", 14.0, px + 10.0, inv_y, 0xCCCCCC)
  ctx.draw_text(cmds, "[E] Equip  [I] Close", 10.0, px + 10.0, inv_y + 16.0, 0x666666)
  let list_y = inv_y + 32.0
  let visible = @cmp.minimum(self.world.inventory.capacity, 10)
  // Scroll offset
  let scroll = if self.world.ui_cursor >= visible { self.world.ui_cursor - visible + 1 } else { 0 }
  for i in 0..<visible {
    let idx = scroll + i
    if idx >= self.world.inventory.capacity {
      break
    }
    let iy = list_y + i.to_double() * 20.0
    let is_selected = idx == self.world.ui_cursor
    let bg = if is_selected { 0x3333AA } else { 0x222233 }
    ctx.draw_rect(cmds, px + 10.0, iy, 280.0, 18.0, @hud.hex_color(bg))
    match self.world.inventory.items[idx] {
      Some(item) => {
        let color = item.rarity.color()
        ctx.draw_text(cmds, item.display_name(), 12.0, px + 14.0, iy + 2.0, color)
        ctx.draw_text(
          cmds,
          "A:" + item.total_atk().to_string() + " D:" + item.total_def().to_string(),
          10.0, px + 200.0, iy + 3.0, 0xAAAAAA,
        )
      }
      None => ctx.draw_text(cmds, "---", 12.0, px + 14.0, iy + 2.0, 0x333333)
    }
  }
  // Selected item detail
  let detail_y = list_y + visible.to_double() * 20.0 + 4.0
  match self.world.inventory.items[self.world.ui_cursor] {
    Some(item) => {
      let mut dy = detail_y
      match item.prefix {
        Some(a) => {
          ctx.draw_text(cmds, "Prefix: " + a.name, 10.0, px + 10.0, dy, 0x66CCFF)
          ctx.draw_text(cmds, format_affix_stats(a), 10.0, px + 80.0, dy, 0x88AACC)
          dy = dy + 14.0
        }
        None => ()
      }
      match item.suffix {
        Some(a) => {
          ctx.draw_text(cmds, "Suffix: " + a.name, 10.0, px + 10.0, dy, 0xFFCC66)
          ctx.draw_text(cmds, format_affix_stats(a), 10.0, px + 80.0, dy, 0xCCAA88)
          dy = dy + 14.0
        }
        None => ()
      }
      let _ = dy
    }
    None => ()
  }
  // Stats summary
  let stats_y = detail_y + 30.0
  let s = self.world.player_stats
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
    "Skill Points: " + self.world.skills.skill_points.to_string(),
    14.0, px + 10.0, cy + 8.0, 0xFFCC00,
  )
  ctx.draw_text(cmds, "[Space] Learn  [K] Close", 10.0, px + 10.0, cy + 26.0, 0x666666)
  let list_y = cy + 44.0
  for i, node in self.world.skills.nodes {
    let ny = list_y + i.to_double() * 42.0
    let is_selected = i == self.world.ui_cursor
    let can_learn = self.world.skills.can_learn(node.id)
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
