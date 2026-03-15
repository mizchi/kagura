// RPG UI: inventory and skill tree screens

// Layout constants — sized for dot-matrix font at 640x480
// Dot-matrix: px_size=3*scale, char_w=9*scale, gap=3*scale, char_h=15*scale
// size=10 → scale=1.0 → chars 9x15px per char, 12px stride
// size=8  → scale=0.8 → chars 7x12px per char, 10px stride

///|
let ui_font : Double = 10.0

///|
let ui_font_sm : Double = 8.0

///|
let ui_font_lg : Double = 14.0

///|
let ui_row_h : Double = 20.0

///|
let ui_pad : Double = 8.0

///|
fn format_affix_stats(a : @game.Affix) -> String {
  let parts : Array[String] = []
  if a.atk != 0 {
    parts.push("ATK" + format_signed(a.atk))
  }
  if a.def != 0 {
    parts.push("DEF" + format_signed(a.def))
  }
  if a.hp != 0 {
    parts.push("HP" + format_signed(a.hp))
  }
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
    if i > 0 {
      result = result + " "
    }
    result = result + p
  }
  result
}

///|
fn format_signed(v : Int) -> String {
  if v > 0 {
    "+" + v.to_string()
  } else {
    v.to_string()
  }
}

///|
fn diff_color(diff : Int) -> Int {
  if diff > 0 {
    0x44FF44 // green = improvement
  } else {
    0xFF4444 // red = worse
  }
}

///|
fn format_diff(diff : Int) -> String {
  if diff > 0 {
    "+" + diff.to_string()
  } else {
    diff.to_string()
  }
}

///|
fn draw_stat_with_diff(
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
  label : String,
  current : Int,
  preview : Int?,
  x : Double,
  y : Double,
  color : Int,
) -> Unit {
  let base_text = label + ":" + current.to_string()
  ctx.draw_text(cmds, base_text, ui_font, x, y, color)
  match preview {
    Some(pv) => {
      let diff = pv - current
      if diff != 0 {
        let diff_text = format_diff(diff)
        // Estimate text width: ~7px per char at ui_font size
        let offset = (base_text.length().to_double()) * 7.0 + 2.0
        ctx.draw_text(cmds, diff_text, ui_font_sm, x + offset, y + 2.0, diff_color(diff))
      }
    }
    None => ()
  }
}

///|
fn draw_stat_pct_with_diff(
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
  label : String,
  current_pct : Int,
  preview_pct : Int?,
  x : Double,
  y : Double,
  color : Int,
) -> Unit {
  let base_text = label + ":" + current_pct.to_string() + "%"
  ctx.draw_text(cmds, base_text, ui_font, x, y, color)
  match preview_pct {
    Some(pv) => {
      let diff = pv - current_pct
      if diff != 0 {
        let diff_text = format_diff(diff)
        let offset = (base_text.length().to_double()) * 7.0 + 2.0
        ctx.draw_text(cmds, diff_text, ui_font_sm, x + offset, y + 2.0, diff_color(diff))
      }
    }
    None => ()
  }
}

///|
fn GameState::update_ui(self : GameState) -> Unit {
  match self.world.ui_mode {
    @game.Inventory => self.update_inventory_ui()
    @game.Skills => self.update_skills_ui()
    @game.LevelUp => self.update_levelup_ui()
    @game.UIMode::None => ()
  }
}

///|
fn is_up_just_pressed(input : @inpututil.InputHelper) -> Bool {
  @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_w) ||
  @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_up_web)
}

///|
fn is_down_just_pressed(input : @inpututil.InputHelper) -> Bool {
  @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_s) ||
  @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_down_web)
}

///|
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
        self.world.player_stats = @game.compute_player_stats(
          self.world.equipment,
          self.world.skills,
          base_hp=self.world.params.player_base_hp.to_int(),
        )
        self.world.player.hp = @cmp.minimum(
          self.world.player.hp,
          self.world.player_stats.max_hp,
        )
      }
      None => ()
    }
  }
}

///|
fn GameState::update_skills_ui(self : GameState) -> Unit {
  let nodes = self.world.skills.nodes
  let cur = self.world.ui_cursor
  if cur >= nodes.length() {
    self.world.ui_cursor = 0
    return
  }
  // Mouse hover: find nearest node to cursor
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let margin = 30.0
  // cursor_x/cursor_y are CSS pixels relative to canvas top-left.
  // Scale to logical game coordinates (screen_w x screen_h).
  // The CSS canvas size may differ from logical size due to DPR scaling,
  // but cursor coords are already in CSS space which maps 1:1 to logical.
  let mx = self.world.cursor_x
  let my = self.world.cursor_y
  if mx > 1.0 || my > 1.0 {
    let mut hover_best = -1
    let mut hover_best_dist = 9999.0
    for i, node in nodes {
      let nx = margin + node.tree_x * (sw - margin * 2.0)
      let ny = margin + 20.0 + node.tree_y * (sh - margin * 2.0 - 20.0)
      let dx = mx - nx
      let dy = my - ny
      let dist = (dx * dx + dy * dy).sqrt()
      let hit_radius = match node.node_size {
        2 => 28.0
        1 => 22.0
        _ => 18.0
      }
      if dist < hit_radius && dist < hover_best_dist {
        hover_best_dist = dist
        hover_best = i
      }
    }
    if hover_best >= 0 {
      self.world.ui_cursor = hover_best
    }
  }
  // Mouse click or Space/Enter: learn the selected skill
  let try_learn = @inpututil.is_mouse_button_just_pressed(
      self.input.mouse_state,
      0,
    ) ||
    @inpututil.is_confirm_just_pressed(self.input)
  if try_learn {
    let sel_idx = self.world.ui_cursor
    if sel_idx >= 0 && sel_idx < nodes.length() {
      let skill_id = nodes[sel_idx].id
      if self.world.archetype.can_learn_skill(skill_id) &&
        self.world.skills.learn(skill_id) {
        self.world.player_stats = @game.compute_player_stats(
          self.world.equipment,
          self.world.skills,
          base_hp=self.world.params.player_base_hp.to_int(),
          archetype=Some(self.world.archetype),
        )
        self.world.player.hp = @cmp.minimum(
          self.world.player.hp,
          self.world.player_stats.max_hp,
        )
      }
    }
  }
  let cur_x = nodes[self.world.ui_cursor].tree_x
  let cur_y = nodes[self.world.ui_cursor].tree_y
  // Navigate to nearest node in the pressed direction
  if is_up_just_pressed(self.input) {
    let mut best = -1
    let mut best_dist = 9999.0
    for i, node in nodes {
      if node.tree_y < cur_y - 0.01 {
        let dist = (node.tree_x - cur_x).abs() +
          (cur_y - node.tree_y) * 2.0
        if dist < best_dist {
          best_dist = dist
          best = i
        }
      }
    }
    if best >= 0 {
      self.world.ui_cursor = best
    }
  }
  if is_down_just_pressed(self.input) {
    let mut best = -1
    let mut best_dist = 9999.0
    for i, node in nodes {
      if node.tree_y > cur_y + 0.01 {
        let dist = (node.tree_x - cur_x).abs() +
          (node.tree_y - cur_y) * 2.0
        if dist < best_dist {
          best_dist = dist
          best = i
        }
      }
    }
    if best >= 0 {
      self.world.ui_cursor = best
    }
  }
  if @inpututil.is_key_just_pressed(
      self.input.key_state,
      @inpututil.key_a,
    ) ||
    @inpututil.is_key_just_pressed(
      self.input.key_state,
      @inpututil.key_left_web,
    ) {
    let mut best = -1
    let mut best_dist = 9999.0
    for i, node in nodes {
      if node.tree_x < cur_x - 0.01 {
        let dist = (cur_x - node.tree_x) * 2.0 +
          (node.tree_y - cur_y).abs()
        if dist < best_dist {
          best_dist = dist
          best = i
        }
      }
    }
    if best >= 0 {
      self.world.ui_cursor = best
    }
  }
  if @inpututil.is_key_just_pressed(
      self.input.key_state,
      @inpututil.key_d,
    ) ||
    @inpututil.is_key_just_pressed(
      self.input.key_state,
      @inpututil.key_right_web,
    ) {
    let mut best = -1
    let mut best_dist = 9999.0
    for i, node in nodes {
      if node.tree_x > cur_x + 0.01 {
        let dist = (node.tree_x - cur_x) * 2.0 +
          (node.tree_y - cur_y).abs()
        if dist < best_dist {
          best_dist = dist
          best = i
        }
      }
    }
    if best >= 0 {
      self.world.ui_cursor = best
    }
  }
}

///|
fn GameState::update_levelup_ui(self : GameState) -> Unit {
  let offer_count = self.world.level_progress.current_offers.length()
  if offer_count == 0 {
    self.world.ui_mode = @game.UIMode::None
    self.world.ui_cursor = 0
    return
  }
  if is_up_just_pressed(self.input) {
    self.world.ui_cursor = (self.world.ui_cursor - 1 + offer_count) %
      offer_count
  }
  if is_down_just_pressed(self.input) {
    self.world.ui_cursor = (self.world.ui_cursor + 1) % offer_count
  }
  let mut chosen_index = -1
  if @inpututil.is_key_just_pressed(self.input.key_state, key_1) {
    chosen_index = 0
  } else if @inpututil.is_key_just_pressed(self.input.key_state, key_2) {
    chosen_index = 1
  } else if @inpututil.is_key_just_pressed(self.input.key_state, key_3) {
    chosen_index = 2
  } else if @inpututil.is_confirm_just_pressed(self.input) {
    chosen_index = self.world.ui_cursor
  }
  if chosen_index >= 0 && chosen_index < offer_count {
    let _ = self.world.apply_levelup_offer_choice(
      chosen_index,
      self.world.seed + self.world.frame_count,
    )
  }
}

///|
fn GameState::render_rpg_ui_cmds(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  self.sync_icon_atlas()
  match self.world.ui_mode {
    @game.Inventory => self.render_inventory_ui(dst, shader, cmds)
    @game.Skills => self.render_skills_ui(dst, shader, cmds)
    @game.LevelUp => self.render_levelup_ui(dst, shader, cmds)
    @game.UIMode::None => ()
  }
  cmds
}

///|
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
  let slot_items = [
    self.world.equipment.weapon,
    self.world.equipment.armor,
    self.world.equipment.accessory,
  ]
  for i, label in slot_labels {
    let row_y = y + i.to_double() * rh
    ctx.draw_rect(
      cmds,
      p,
      row_y,
      sw - p * 2.0,
      rh - 2.0,
      @hud.hex_color(0x1A1A33),
    )
    ctx.draw_text(cmds, label, ui_font_sm, p + 4.0, row_y + 4.0, 0x666688)
    match slot_items[i] {
      Some(item) => {
        let _ = self.append_item_icon(
          cmds,
          dst,
          shader,
          item,
          p + 30.0,
          row_y + 2.0,
        )
        ctx.draw_text(
          cmds,
          item.display_name(),
          ui_font_sm,
          p + 52.0,
          row_y + 4.0,
          item.rarity.color(),
        )
      }
      None =>
        ctx.draw_text(cmds, "---", ui_font_sm, p + 52.0, row_y + 4.0, 0x444444)
    }
  }
  y = y + 3.0 * rh + 4.0
  // ---- Stats panel with equip preview ----
  let s = self.world.player_stats
  // Compute preview stats if cursor is on an equippable item
  let preview : @game.PlayerStats? = if self.world.ui_cursor <
    self.world.inventory.capacity {
    match self.world.inventory.items[self.world.ui_cursor] {
      Some(item) => {
        let tmp_equip = self.world.equipment.clone()
        let _ = tmp_equip.equip(item)
        Some(
          @game.compute_player_stats(
            tmp_equip,
            self.world.skills,
            base_hp=self.world.params.player_base_hp.to_int(),
            archetype=Some(self.world.archetype),
          ),
        )
      }
      None => None
    }
  } else {
    None
  }
  let stats_h = rh * 3.0 + 4.0
  ctx.draw_rect(
    cmds,
    p,
    y,
    sw - p * 2.0,
    stats_h,
    @hud.hex_color(0x112211),
  )
  ctx.draw_text(cmds, "STATS", ui_font_sm, p + 4.0, y + 2.0, 0x448844)
  // Row 1: core stats
  let row1_y = y + 14.0
  draw_stat_with_diff(ctx, cmds, "STR", s.strength, preview.map(fn(ps) {
    ps.strength
  }), p + 4.0, row1_y, 0xFF8866)
  draw_stat_with_diff(ctx, cmds, "INT", s.intelligence, preview.map(fn(ps) {
    ps.intelligence
  }), p + 100.0, row1_y, 0x66AAFF)
  draw_stat_with_diff(ctx, cmds, "DEX", s.dexterity, preview.map(fn(ps) {
    ps.dexterity
  }), p + 196.0, row1_y, 0x66FF66)
  draw_stat_with_diff(ctx, cmds, "HP", s.max_hp, preview.map(fn(ps) {
    ps.max_hp
  }), p + 292.0, row1_y, 0xFFFFFF)
  // Row 2: derived powers
  let row2_y = row1_y + rh
  draw_stat_with_diff(ctx, cmds, "ATK", s.attack_power, preview.map(fn(ps) {
    ps.attack_power
  }), p + 4.0, row2_y, 0xFF8866)
  draw_stat_with_diff(ctx, cmds, "SPL", s.spell_power, preview.map(fn(ps) {
    ps.spell_power
  }), p + 100.0, row2_y, 0x66AAFF)
  draw_stat_with_diff(ctx, cmds, "RNG", s.ranged_power, preview.map(fn(ps) {
    ps.ranged_power
  }), p + 196.0, row2_y, 0x66FF66)
  draw_stat_with_diff(ctx, cmds, "DEF", s.def, preview.map(fn(ps) {
    ps.def
  }), p + 292.0, row2_y, 0xFFFFFF)
  // Row 3: secondary stats
  let row3_y = row2_y + rh
  let crit_pct = (s.crit_chance * 100.0).to_int()
  let preview_crit_pct = preview.map(fn(ps) {
    (ps.crit_chance * 100.0).to_int()
  })
  draw_stat_pct_with_diff(
    ctx, cmds, "CRIT", crit_pct, preview_crit_pct, p + 4.0, row3_y, 0xFFCC00,
  )
  let ls_pct = (s.life_steal * 100.0).to_int()
  let preview_ls_pct = preview.map(fn(ps) {
    (ps.life_steal * 100.0).to_int()
  })
  draw_stat_pct_with_diff(
    ctx, cmds, "LS", ls_pct, preview_ls_pct, p + 100.0, row3_y, 0xFF66AA,
  )
  let spd_pct = (s.speed_bonus * 100.0).to_int()
  let preview_spd_pct = preview.map(fn(ps) {
    (ps.speed_bonus * 100.0).to_int()
  })
  draw_stat_pct_with_diff(
    ctx, cmds, "SPD", spd_pct, preview_spd_pct, p + 196.0, row3_y, 0x88DDFF,
  )
  let cdr_pct = (s.cooldown_reduction * 100.0).to_int()
  let preview_cdr_pct = preview.map(fn(ps) {
    (ps.cooldown_reduction * 100.0).to_int()
  })
  draw_stat_pct_with_diff(
    ctx, cmds, "CDR", cdr_pct, preview_cdr_pct, p + 292.0, row3_y, 0xAAFF88,
  )
  y = y + stats_h + 4.0
  // ---- Item list ----
  let count_str = "ITEMS " +
    self.world.inventory.count().to_string() +
    "/" +
    self.world.inventory.capacity.to_string()
  ctx.draw_text(cmds, count_str, ui_font_sm, p, y, 0x888888)
  ctx.draw_text(cmds, "E:EQUIP I:CLOSE", ui_font_sm, sw - 200.0, y, 0x555555)
  y = y + 18.0
  let max_rows = ((sh - y - 24.0) / rh).to_int()
  let visible = @cmp.minimum(self.world.inventory.capacity, max_rows)
  let scroll = if self.world.ui_cursor >= visible {
    self.world.ui_cursor - visible + 1
  } else {
    0
  }
  for i in 0..<visible {
    let idx = scroll + i
    if idx >= self.world.inventory.capacity {
      break
    }
    let row_y = y + i.to_double() * rh
    let sel = idx == self.world.ui_cursor
    let bg = if sel {
      0x2222AA
    } else if idx % 2 == 0 {
      0x141428
    } else {
      0x1A1A33
    }
    ctx.draw_rect(cmds, p, row_y, sw - p * 2.0, rh - 2.0, @hud.hex_color(bg))
    if sel {
      ctx.draw_rect(cmds, p, row_y, 3.0, rh - 2.0, @hud.hex_color(0xFFCC00))
    }
    match self.world.inventory.items[idx] {
      Some(item) => {
        let _ = self.append_item_icon(
          cmds,
          dst,
          shader,
          item,
          p + 8.0,
          row_y + 2.0,
        )
        ctx.draw_text(
          cmds,
          item.display_name(),
          ui_font,
          p + 30.0,
          row_y + 4.0,
          item.rarity.color(),
        )
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
            ctx.draw_text(
              cmds,
              format_affix_stats(a),
              ui_font_sm,
              dx,
              detail_y,
              0x66CCFF,
            )
            dx = dx + 120.0
          }
          None => ()
        }
        match item.suffix {
          Some(a) =>
            ctx.draw_text(
              cmds,
              format_affix_stats(a),
              ui_font_sm,
              dx,
              detail_y,
              0xFFCC66,
            )
          None => ()
        }
      }
      None => ()
    }
  }
}

///|
///|
fn draw_circle_node(
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
  cx : Double,
  cy : Double,
  radius : Double,
  color : Int,
) -> Unit {
  // Approximate circle with overlapping rects (cross pattern)
  let r = radius
  let r2 = r * 0.7
  ctx.draw_rect(cmds, cx - r, cy - r2, r * 2.0, r2 * 2.0, @hud.hex_color(color))
  ctx.draw_rect(cmds, cx - r2, cy - r, r2 * 2.0, r * 2.0, @hud.hex_color(color))
  // Corner fills for rounder shape
  let r3 = r * 0.5
  ctx.draw_rect(
    cmds,
    cx - r * 0.85,
    cy - r * 0.85,
    r * 1.7,
    r * 1.7,
    @hud.hex_color(color),
  )
}

///|
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
  let margin = 30.0
  // Dark starfield background
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x050510))
  // Scatter subtle background stars
  for star_i = 0; star_i < 40; star_i = star_i + 1 {
    let sx = ((star_i * 137 + 29) % 620).to_double() + 10.0
    let sy = ((star_i * 97 + 53) % 460).to_double() + 10.0
    let brightness = 0x181825 + (star_i * 7) % 0x10
    ctx.draw_rect(cmds, sx, sy, 1.0, 1.0, @hud.hex_color(brightness))
  }
  // Header
  ctx.draw_text(cmds, "PASSIVE TREE", ui_font_lg, p, p, 0xBBA855)
  let sp_text = "SP:" + self.world.skills.skill_points.to_string()
  let sp_color = if self.world.skills.skill_points > 0 {
    0x44FF44
  } else {
    0x666666
  }
  ctx.draw_text(cmds, sp_text, ui_font, sw / 2.0 - 20.0, p + 2.0, sp_color)
  ctx.draw_text(
    cmds,
    "LV " + self.world.level_progress.level.to_string(),
    ui_font,
    sw - 60.0,
    p + 2.0,
    0xBBA855,
  )
  ctx.draw_text(cmds, "K:CLOSE", ui_font_sm, sw - 60.0, p + 16.0, 0x444455)
  // === Draw connection lines (behind nodes) ===
  for node in self.world.skills.nodes {
    let nx = margin + node.tree_x * (sw - margin * 2.0)
    let ny = margin + 20.0 + node.tree_y * (sh - margin * 2.0 - 20.0)
    for conn_id in node.connections {
      match self.world.skills.find(conn_id) {
        Some(pn) => {
          let px = margin + pn.tree_x * (sw - margin * 2.0)
          let py = margin + 20.0 + pn.tree_y * (sh - margin * 2.0 - 20.0)
          // Line color: golden if both allocated, dim otherwise
          let line_color = if pn.level > 0 && node.level > 0 {
            0x8B7530
          } else if pn.level > 0 {
            0x443820
          } else {
            0x1A1A28
          }
          // Draw line segments (subdivide for smoother look)
          let steps = 8
          for s = 0; s < steps; s = s + 1 {
            let t0 = s.to_double() / steps.to_double()
            let t1 = (s + 1).to_double() / steps.to_double()
            let x0 = px + (nx - px) * t0
            let y0 = py + (ny - py) * t0
            let x1 = px + (nx - px) * t1
            let y1 = py + (ny - py) * t1
            let lx = @cmp.minimum(x0, x1)
            let ly = @cmp.minimum(y0, y1)
            let lw = (x1 - x0).abs().max(1.5)
            let lh = (y1 - y0).abs().max(1.5)
            ctx.draw_rect(cmds, lx, ly, lw, lh, @hud.hex_color(line_color))
          }
        }
        None => ()
      }
    }
  }
  // === Draw nodes ===
  for i, node in self.world.skills.nodes {
    let nx = margin + node.tree_x * (sw - margin * 2.0)
    let ny = margin + 20.0 + node.tree_y * (sh - margin * 2.0 - 20.0)
    let sel = i == self.world.ui_cursor
    let archetype_allowed = self.world.archetype.can_learn_skill(node.id)
    let can_learn = archetype_allowed && self.world.skills.can_learn(node.id)
    // Node radius by size
    let base_r = match node.node_size {
      2 => 14.0 // keystone
      1 => 10.0 // notable
      _ => 7.0 // small passive
    }
    // Outer glow ring for allocated nodes
    if node.level > 0 {
      let glow_color = if node.level >= node.max_level {
        0x44BBAA // maxed: cyan glow
      } else {
        0x448844 // partial: green glow
      }
      draw_circle_node(ctx, cmds, nx, ny, base_r + 3.0, glow_color)
    }
    // Selection highlight ring
    if sel {
      draw_circle_node(ctx, cmds, nx, ny, base_r + 4.0, 0xCCAA33)
    }
    // Node border
    let border_color = if not(archetype_allowed) {
      0x1A1A22 // locked: very dim
    } else if node.level > 0 {
      0x88AA66
    } else if can_learn {
      0x997733
    } else {
      0x333344
    }
    draw_circle_node(ctx, cmds, nx, ny, base_r, border_color)
    // Node fill
    let fill_color = if not(archetype_allowed) {
      0x0A0A10 // locked: nearly invisible
    } else if node.level > 0 {
      0x2A3A1A
    } else {
      0x12121E
    }
    draw_circle_node(ctx, cmds, nx, ny, base_r - 2.0, fill_color)
    // Level pips inside node (small dots)
    if node.max_level > 1 {
      let pip_count = node.max_level
      let pip_w = @cmp.minimum(base_r * 1.2, (pip_count * 4).to_double())
      let pip_start = nx - pip_w / 2.0
      for pip = 0; pip < pip_count; pip = pip + 1 {
        let pip_x = pip_start + pip.to_double() * (pip_w / pip_count.to_double())
        let pip_color = if pip < node.level { 0x66FF66 } else { 0x333344 }
        ctx.draw_rect(cmds, pip_x, ny + 2.0, 2.0, 2.0, @hud.hex_color(pip_color))
      }
    }
    // Name label below node
    let name_color = if not(archetype_allowed) {
      0x222233
    } else if node.level > 0 {
      0x88DD88
    } else if can_learn {
      0xCCAA44
    } else {
      0x445566
    }
    ctx.draw_text_centered(
      cmds,
      node.name,
      ui_font_sm,
      nx,
      ny + base_r + 4.0,
      name_color,
    )
  }
}

///|
fn skill_levelup_summary(
  skills : @game.SkillTree,
  id : @game.SkillId,
) -> String {
  match skills.find(id) {
    None => "---"
    Some(node) => {
      let prereq_text = if node.prereqs.length() == 0 { "OPEN" } else { "REQ" }
      "Lv " +
      node.level.to_string() +
      " -> " +
      (node.level + 1).to_string() +
      " / " +
      node.max_level.to_string() +
      "  " +
      prereq_text
    }
  }
}

///|
fn GameState::render_levelup_ui(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let ctx = self.make_hud_ctx(dst, shader)
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let p = ui_pad
  let panel_w = 360.0
  let panel_h = 190.0
  let panel_x = (sw - panel_w) / 2.0
  let panel_y = (sh - panel_h) / 2.0
  ctx.draw_rect(cmds, 0.0, 0.0, sw, sh, @hud.hex_color(0x050510))
  ctx.draw_rect(
    cmds,
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @hud.hex_color(0x11162A),
  )
  ctx.draw_rect(cmds, panel_x, panel_y, panel_w, 3.0, @hud.hex_color(0xFFCC00))
  let mut y = panel_y + 10.0
  ctx.draw_text(cmds, "LEVEL UP", ui_font_lg, panel_x + p, y, 0xFFCC00)
  ctx.draw_text(
    cmds,
    "1-3 / SPACE SELECT",
    ui_font_sm,
    panel_x + panel_w - 132.0,
    y + 4.0,
    0x777788,
  )
  y = y + 26.0
  ctx.draw_text(
    cmds,
    "Choose 1 of " +
    self.world.level_progress.current_offers.length().to_string(),
    ui_font_sm,
    panel_x + p,
    y,
    0xAABBDD,
  )
  y = y + 18.0
  for i, offer in self.world.level_progress.current_offers {
    let row_y = y + i.to_double() * 42.0
    let selected = i == self.world.ui_cursor
    let bg = if selected { 0x223366 } else { 0x171B2D }
    ctx.draw_rect(
      cmds,
      panel_x + p,
      row_y,
      panel_w - p * 2.0,
      36.0,
      @hud.hex_color(bg),
    )
    if selected {
      ctx.draw_rect(
        cmds,
        panel_x + p,
        row_y,
        4.0,
        36.0,
        @hud.hex_color(0xFFCC00),
      )
    }
    match self.world.skills.find(offer) {
      None => ()
      Some(node) => {
        let _ = self.append_skill_icon(
          cmds,
          dst,
          shader,
          node,
          panel_x + p + 10.0,
          row_y + 9.0,
        )
        ctx.draw_text(
          cmds,
          (i + 1).to_string() + ". " + node.name,
          ui_font,
          panel_x + p + 34.0,
          row_y + 4.0,
          0xE8F0FF,
        )
        ctx.draw_text(
          cmds,
          skill_levelup_summary(self.world.skills, offer),
          ui_font_sm,
          panel_x + p + 34.0,
          row_y + 19.0,
          0x88AADD,
        )
      }
    }
  }
}
