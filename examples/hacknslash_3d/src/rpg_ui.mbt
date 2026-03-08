// RPG UI: inventory and skill tree screens

fn format_affix_stats(a : @game.Affix) -> String {
  let parts : Array[String] = []
  if a.atk != 0 { parts.push("ATK" + format_signed(a.atk)) }
  if a.def != 0 { parts.push("DEF" + format_signed(a.def)) }
  if a.hp != 0 { parts.push("HP" + format_signed(a.hp)) }
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
  // Backdrop
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x000000, alpha=0.7))
  // Title
  ctx.draw_text(cmds, "INVENTORY", 20.0, 16.0, 8.0, 0xFFCC00)
  ctx.draw_text(cmds, "[E]Equip [I]Close", 14.0, sw - 160.0, 12.0, 0x666666)
  // Equipment slots (top section)
  let eq_y = 32.0
  let slot_labels = ["WPN", "ARM", "ACC"]
  let slot_items = [self.world.equipment.weapon, self.world.equipment.armor, self.world.equipment.accessory]
  for i, label in slot_labels {
    let sy = eq_y + i.to_double() * 20.0
    ctx.draw_rect(cmds, 8.0, sy, sw - 16.0, 18.0, @hud.hex_color(0x222244))
    ctx.draw_text(cmds, label, 14.0, 12.0, sy + 2.0, 0x888888)
    match slot_items[i] {
      Some(item) => {
        let color = item.rarity.color()
        ctx.draw_text(cmds, item.display_name(), 14.0, 52.0, sy + 2.0, color)
        let stats = "A:" + item.total_atk().to_string() + " D:" + item.total_def().to_string() + " H:" + item.total_hp().to_string()
        ctx.draw_text(cmds, stats, 14.0, sw - 130.0, sy + 2.0, 0xAAAAAA)
      }
      None => ctx.draw_text(cmds, "---", 14.0, 52.0, sy + 2.0, 0x555555)
    }
  }
  // Stats bar
  let stats_y = eq_y + 62.0
  let s = self.world.player_stats
  ctx.draw_rect(cmds, 8.0, stats_y, sw - 16.0, 16.0, @hud.hex_color(0x113311))
  ctx.draw_text(
    cmds,
    "ATK:" + s.atk.to_string() + "  DEF:" + s.def.to_string() + "  HP:" + s.max_hp.to_string(),
    14.0, 12.0, stats_y + 1.0, 0x88FF88,
  )
  // Inventory list
  let inv_y = stats_y + 20.0
  let count_text = "ITEMS " + self.world.inventory.count().to_string() + "/" + self.world.inventory.capacity.to_string()
  ctx.draw_text(cmds, count_text, 14.0, 12.0, inv_y, 0xCCCCCC)
  let list_y = inv_y + 18.0
  let row_h = 18.0
  let max_visible = ((sh - list_y - 30.0) / row_h).to_int()
  let visible = @cmp.minimum(self.world.inventory.capacity, max_visible)
  let scroll = if self.world.ui_cursor >= visible { self.world.ui_cursor - visible + 1 } else { 0 }
  for i in 0..<visible {
    let idx = scroll + i
    if idx >= self.world.inventory.capacity { break }
    let iy = list_y + i.to_double() * row_h
    let is_selected = idx == self.world.ui_cursor
    let bg = if is_selected { 0x3333AA } else if idx % 2 == 0 { 0x1A1A2E } else { 0x222233 }
    ctx.draw_rect(cmds, 8.0, iy, sw - 16.0, row_h - 2.0, @hud.hex_color(bg))
    if is_selected {
      ctx.draw_rect(cmds, 8.0, iy, 3.0, row_h - 2.0, @hud.hex_color(0xFFCC00))
    }
    match self.world.inventory.items[idx] {
      Some(item) => {
        let color = item.rarity.color()
        ctx.draw_text(cmds, item.display_name(), 14.0, 16.0, iy + 1.0, color)
        let stats = "A:" + item.total_atk().to_string() + " D:" + item.total_def().to_string()
        ctx.draw_text(cmds, stats, 14.0, sw - 100.0, iy + 1.0, 0xAAAAAA)
      }
      None => ()
    }
  }
  // Selected item detail (bottom)
  if self.world.ui_cursor < self.world.inventory.capacity {
    match self.world.inventory.items[self.world.ui_cursor] {
      Some(item) => {
        let detail_y = sh - 28.0
        let mut dx = 12.0
        match item.prefix {
          Some(a) => {
            let text = "+" + a.name + " " + format_affix_stats(a)
            ctx.draw_text(cmds, text, 14.0, dx, detail_y, 0x66CCFF)
            dx = dx + text.length().to_double() * 7.0 + 8.0
          }
          None => ()
        }
        match item.suffix {
          Some(a) => {
            let text = a.name + " " + format_affix_stats(a)
            ctx.draw_text(cmds, text, 14.0, dx, detail_y, 0xFFCC66)
          }
          None => ()
        }
      }
      None => ()
    }
  }
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
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x000000, alpha=0.7))
  // Title
  ctx.draw_text(cmds, "SKILLS", 20.0, 16.0, 8.0, 0xFFCC00)
  ctx.draw_text(
    cmds,
    "SP:" + self.world.skills.skill_points.to_string(),
    16.0, sw - 80.0, 10.0, 0xFFCC00,
  )
  ctx.draw_text(cmds, "[Space]Learn [K]Close", 14.0, 16.0, 28.0, 0x666666)
  let list_y = 48.0
  let row_h = 36.0
  for i, node in self.world.skills.nodes {
    let ny = list_y + i.to_double() * row_h
    if ny + row_h > sh { break }
    let is_selected = i == self.world.ui_cursor
    let can_learn = self.world.skills.can_learn(node.id)
    let bg = if is_selected { 0x3333AA } else { 0x1A1A2E }
    ctx.draw_rect(cmds, 8.0, ny, sw - 16.0, row_h - 2.0, @hud.hex_color(bg))
    if is_selected {
      ctx.draw_rect(cmds, 8.0, ny, 3.0, row_h - 2.0, @hud.hex_color(0xFFCC00))
    }
    // Skill name
    let name_color = if node.level > 0 { 0x44FF44 } else if can_learn { 0xFFCC00 } else { 0x666666 }
    ctx.draw_text(cmds, node.name, 16.0, 16.0, ny + 2.0, name_color)
    // Level
    let level_text = "Lv " + node.level.to_string() + "/" + node.max_level.to_string()
    ctx.draw_text(cmds, level_text, 14.0, sw - 100.0, ny + 2.0, 0xCCCCCC)
    // Cost + progress bar
    ctx.draw_text(
      cmds,
      "Cost:" + node.cost.to_string() + "SP",
      14.0, 16.0, ny + 18.0, 0x888888,
    )
    if node.max_level > 0 {
      let bar_w = 80.0
      let bar_x = sw - 100.0
      let bar_y = ny + 20.0
      let bar_ratio = node.level.to_double() / node.max_level.to_double()
      ctx.draw_rect(cmds, bar_x, bar_y, bar_w, 8.0, @hud.hex_color(0x333333))
      if bar_ratio > 0.0 {
        ctx.draw_rect(cmds, bar_x, bar_y, bar_w * bar_ratio, 8.0, @hud.hex_color(0x44AA44))
      }
    }
  }
}
