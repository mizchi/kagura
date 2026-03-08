// RPG UI: inventory and skill tree screens

// Layout constants — sized for dot-matrix font at 640x480
// Dot-matrix: px_size=3*scale, char_w=9*scale, gap=3*scale, char_h=15*scale
// size=10 → scale=1.0 → chars 9x15px per char, 12px stride
// size=8  → scale=0.8 → chars 7x12px per char, 10px stride
let ui_font : Double = 10.0

let ui_font_sm : Double = 8.0

let ui_font_lg : Double = 14.0

let ui_row_h : Double = 20.0

let ui_pad : Double = 8.0

fn format_affix_stats(a : @game.Affix) -> String {
  let parts : Array[String] = []
  if a.atk != 0 { parts.push("ATK" + format_signed(a.atk)) }
  if a.def != 0 { parts.push("DEF" + format_signed(a.def)) }
  if a.hp != 0 { parts.push("HP" + format_signed(a.hp)) }
  if a.crit > 0.001 {
    let pct = (a.crit * 100.0).to_int()
    parts.push("C+" + pct.to_string() + "%")
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
  let p = ui_pad
  let rh = ui_row_h
  // Fully opaque backdrop
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x0D0D1A))
  // ---- Header ----
  let mut y = p
  ctx.draw_text(cmds, "INVENTORY", ui_font_lg, p, y, 0xFFCC00)
  y = y + 24.0
  // ---- Equipment section ----
  ctx.draw_text(cmds, "EQUIPPED", ui_font_sm, p, y, 0x888888)
  y = y + 18.0
  let slot_labels = ["WPN", "ARM", "ACC"]
  let slot_items = [self.world.equipment.weapon, self.world.equipment.armor, self.world.equipment.accessory]
  for i, label in slot_labels {
    let row_y = y + i.to_double() * rh
    ctx.draw_rect(cmds, p, row_y, sw - p * 2.0, rh - 2.0, @hud.hex_color(0x1A1A33))
    ctx.draw_text(cmds, label, ui_font_sm, p + 4.0, row_y + 4.0, 0x666688)
    match slot_items[i] {
      Some(item) => {
        ctx.draw_text(cmds, item.display_name(), ui_font_sm, p + 50.0, row_y + 4.0, item.rarity.color())
      }
      None => ctx.draw_text(cmds, "---", ui_font_sm, p + 50.0, row_y + 4.0, 0x444444)
    }
  }
  y = y + 3.0 * rh + 4.0
  // ---- Stats ----
  let s = self.world.player_stats
  ctx.draw_rect(cmds, p, y, sw - p * 2.0, rh - 2.0, @hud.hex_color(0x112211))
  ctx.draw_text(
    cmds,
    "ATK:" + s.atk.to_string() + " DEF:" + s.def.to_string() + " HP:" + s.max_hp.to_string(),
    ui_font, p + 4.0, y + 4.0, 0x66DD66,
  )
  y = y + rh + 4.0
  // ---- Item list ----
  let count_str = "ITEMS " + self.world.inventory.count().to_string() + "/" + self.world.inventory.capacity.to_string()
  ctx.draw_text(cmds, count_str, ui_font_sm, p, y, 0x888888)
  ctx.draw_text(cmds, "E:EQUIP I:CLOSE", ui_font_sm, sw - 200.0, y, 0x555555)
  y = y + 18.0
  let max_rows = ((sh - y - 24.0) / rh).to_int()
  let visible = @cmp.minimum(self.world.inventory.capacity, max_rows)
  let scroll = if self.world.ui_cursor >= visible { self.world.ui_cursor - visible + 1 } else { 0 }
  for i in 0..<visible {
    let idx = scroll + i
    if idx >= self.world.inventory.capacity { break }
    let row_y = y + i.to_double() * rh
    let sel = idx == self.world.ui_cursor
    let bg = if sel { 0x2222AA } else if idx % 2 == 0 { 0x141428 } else { 0x1A1A33 }
    ctx.draw_rect(cmds, p, row_y, sw - p * 2.0, rh - 2.0, @hud.hex_color(bg))
    if sel {
      ctx.draw_rect(cmds, p, row_y, 3.0, rh - 2.0, @hud.hex_color(0xFFCC00))
    }
    match self.world.inventory.items[idx] {
      Some(item) => {
        ctx.draw_text(cmds, item.display_name(), ui_font, p + 8.0, row_y + 4.0, item.rarity.color())
      }
      None => ()
    }
  }
  // ---- Selected detail (bottom) ----
  if self.world.ui_cursor < self.world.inventory.capacity {
    match self.world.inventory.items[self.world.ui_cursor] {
      Some(item) => {
        let detail_y = sh - 20.0
        let mut dx = p
        let slot_name = match item.slot {
          @game.Weapon => "WPN"
          @game.Armor => "ARM"
          @game.Accessory => "ACC"
        }
        ctx.draw_text(cmds, slot_name, ui_font_sm, dx, detail_y, 0x888888)
        dx = dx + 80.0
        match item.prefix {
          Some(a) => {
            ctx.draw_text(cmds, format_affix_stats(a), ui_font_sm, dx, detail_y, 0x66CCFF)
            dx = dx + 120.0
          }
          None => ()
        }
        match item.suffix {
          Some(a) => {
            ctx.draw_text(cmds, format_affix_stats(a), ui_font_sm, dx, detail_y, 0xFFCC66)
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
  let p = ui_pad
  let rh = 32.0
  // Fully opaque backdrop
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x0D0D1A))
  // Header
  let mut y = p
  ctx.draw_text(cmds, "SKILLS", ui_font_lg, p, y, 0xFFCC00)
  ctx.draw_text(
    cmds,
    "SP:" + self.world.skills.skill_points.to_string(),
    ui_font, sw - 100.0, y + 4.0, 0xFFCC00,
  )
  y = y + 24.0
  ctx.draw_text(cmds, "SPACE:LEARN K:CLOSE", ui_font_sm, p, y, 0x555555)
  y = y + 16.0
  for i, node in self.world.skills.nodes {
    let row_y = y + i.to_double() * rh
    if row_y + rh > sh { break }
    let sel = i == self.world.ui_cursor
    let can_learn = self.world.skills.can_learn(node.id)
    let bg = if sel { 0x2222AA } else { 0x141428 }
    ctx.draw_rect(cmds, p, row_y, sw - p * 2.0, rh - 2.0, @hud.hex_color(bg))
    if sel {
      ctx.draw_rect(cmds, p, row_y, 3.0, rh - 2.0, @hud.hex_color(0xFFCC00))
    }
    let name_color = if node.level > 0 { 0x44FF44 } else if can_learn { 0xFFCC00 } else { 0x666666 }
    ctx.draw_text(cmds, node.name, ui_font, p + 8.0, row_y + 4.0, name_color)
    let level_text = "Lv " + node.level.to_string() + "/" + node.max_level.to_string()
    ctx.draw_text(cmds, level_text, ui_font_sm, sw - 120.0, row_y + 4.0, 0xCCCCCC)
    ctx.draw_text(
      cmds,
      "Cost:" + node.cost.to_string(),
      ui_font_sm, p + 8.0, row_y + 18.0, 0x666666,
    )
    // Progress bar
    if node.max_level > 0 {
      let bar_w = 80.0
      let bar_x = sw - 120.0
      let bar_ratio = node.level.to_double() / node.max_level.to_double()
      ctx.draw_rect(cmds, bar_x, row_y + 20.0, bar_w, 8.0, @hud.hex_color(0x333333))
      if bar_ratio > 0.0 {
        ctx.draw_rect(cmds, bar_x, row_y + 20.0, bar_w * bar_ratio, 8.0, @hud.hex_color(0x44AA44))
      }
    }
  }
}
