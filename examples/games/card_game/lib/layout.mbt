///|
fn[T : Compare] ui_min(a : T, b : T) -> T {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn[T : Compare] ui_max(a : T, b : T) -> T {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Logical rectangles are shared by rendering and input. No global viewport state.
priv struct UiRect {
  x : Double
  y : Double
  w : Double
  h : Double
}

///|
fn UiRect::contains(self : UiRect, x : Double, y : Double) -> Bool {
  x >= self.x && x <= self.x + self.w && y >= self.y && y <= self.y + self.h
}

///|
struct GameLayout {
  w : Double
  h : Double
  card_h : Double
  hand_y : Double
  command_y : Double
  stack_enemies : Bool
}

///|
fn GameLayout::new(width : Int, height : Int) -> GameLayout {
  let w = width.to_double()
  let h = height.to_double()
  let card_h = if height < 440 { 100.0 } else { 150.0 }
  let hand_y = h - card_h - 24.0
  {
    w,
    h,
    card_h,
    hand_y,
    command_y: hand_y - 58.0,
    stack_enemies: width < 540 && height >= 560,
  }
}

///|
fn GameLayout::card_rect(self : GameLayout, index : Int, count : Int) -> UiRect {
  let n = ui_max(count, 1).to_double()
  let width = ui_min(120.0, ui_max(64.0, (self.w - 32.0 - (n - 1.0) * 8.0) / n))
  let step = if count <= 1 {
    0.0
  } else {
    ui_min(width + 8.0, (self.w - 32.0 - width) / (n - 1.0))
  }
  let total = width + step * (n - 1.0)
  {
    x: (self.w - total) / 2.0 + step * index.to_double(),
    y: self.hand_y,
    w: width,
    h: self.card_h,
  }
}

///|
fn GameLayout::enemy_rect(
  self : GameLayout,
  index : Int,
  count : Int,
) -> UiRect {
  let n = ui_max(count, 1).to_double()
  let region_x = self.w * 0.4
  let region_w = self.w - region_x - 16.0
  if self.stack_enemies {
    let arena = self.play_area()
    let width = ui_min(144.0, region_w)
    let height = ui_min(170.0, (arena.h - (n - 1.0) * 12.0) / n)
    let total_h = height * n + (n - 1.0) * 12.0
    return {
      x: region_x + (region_w - width) / 2.0,
      y: arena.y +
      (arena.h - total_h) / 2.0 +
      index.to_double() * (height + 12.0),
      w: width,
      h: height,
    }
  }
  let width = ui_min(144.0, (region_w - (n - 1.0) * 12.0) / n)
  let total = n * width + (n - 1.0) * 12.0
  let bottom = self.command_y - (if self.h >= 440.0 { 36.0 } else { 8.0 })
  let height = ui_min(170.0, bottom - 80.0)
  let y = 80.0 + (bottom - 80.0 - height) / 2.0
  {
    x: region_x + (region_w - total) / 2.0 + index.to_double() * (width + 12.0),
    y,
    w: width,
    h: height,
  }
}

///|
fn GameLayout::player_rect(self : GameLayout) -> UiRect {
  let arena = self.play_area()
  let height = ui_min(170.0, arena.h)
  {
    x: 24.0,
    y: arena.y + (arena.h - height) / 2.0,
    w: self.w * 0.3,
    h: height,
  }
}

///|
fn GameLayout::play_area(self : GameLayout) -> UiRect {
  {
    x: 12.0,
    y: 80.0,
    w: self.w - 24.0,
    h: self.command_y - 80.0 - (if self.h >= 440.0 { 36.0 } else { 8.0 }),
  }
}

///|
fn GameLayout::end_turn_rect(self : GameLayout) -> UiRect {
  { x: self.w - 116.0, y: self.command_y, w: 100.0, h: 44.0, }
}

///|
fn GameLayout::reward_rect(
  self : GameLayout,
  index : Int,
  count : Int,
) -> UiRect {
  let n = ui_max(count, 1).to_double()
  let width = ui_min(150.0, (self.w - 40.0 - (n - 1.0) * 12.0) / n)
  let height = ui_min(210.0, self.h * 0.42)
  let total = width * n + (n - 1.0) * 12.0
  {
    x: (self.w - total) / 2.0 + index.to_double() * (width + 12.0),
    y: self.h * 0.36,
    w: width,
    h: height,
  }
}

///|
fn GameLayout::continue_rect(self : GameLayout) -> UiRect {
  { x: self.w / 2.0 - 84.0, y: self.h - 72.0, w: 168.0, h: 44.0, }
}

///|
fn hit_card(layout : GameLayout, count : Int, x : Double, y : Double) -> Int {
  // Later cards are painted on top in a crowded hand.
  for i = count - 1; i >= 0; i = i - 1 {
    let rect = layout.card_rect(i, count)
    if x >= rect.x &&
      x <= rect.x + rect.w &&
      y >= rect.y - 8.0 &&
      y <= rect.y + rect.h {
      return i
    }
  }
  -1
}

///|
fn hit_enemy(
  layout : GameLayout,
  state : BattleState,
  x : Double,
  y : Double,
) -> Int {
  for i = 0; i < state.enemies.length(); i = i + 1 {
    if !state.enemies[i].fighter.is_dead() &&
      layout.enemy_rect(i, state.enemies.length()).contains(x, y) {
      return i
    }
  }
  -1
}

///|
fn rects_overlap(a : UiRect, b : UiRect) -> Bool {
  a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y
}

///|
fn preview_is_clear(l : GameLayout, state : BattleState, r : UiRect) -> Bool {
  let area = l.play_area()
  if !area.contains(r.x, r.y) ||
    !area.contains(r.x + r.w, r.y + r.h) ||
    rects_overlap(r, l.player_rect()) {
    return false
  }
  for i = 0; i < state.enemies.length(); i = i + 1 {
    if !state.enemies[i].fighter.is_dead() &&
      rects_overlap(r, l.enemy_rect(i, state.enemies.length())) {
      return false
    }
  }
  true
}

///|
fn drag_card_rect(
  l : GameLayout,
  state : BattleState,
  index : Int,
  x : Double,
  y : Double,
) -> UiRect {
  let r : UiRect = {
    x: ui_max(8.0, ui_min(l.w - 120.0, x + 24.0)),
    y: ui_max(82.0, ui_min(l.command_y - 194.0, y - 75.0)),
    w: 112.0,
    h: 150.0,
  }
  if preview_is_clear(l, state, r) {
    return r
  }
  let beside_player : UiRect = {
    ..r,
    x: l.player_rect().x + l.player_rect().w + 12.0,
  }
  if preview_is_clear(l, state, beside_player) {
    return beside_player
  }
  // On a compact battlefield the vacated hand slot is the only unobscured space.
  l.card_rect(index, state.hand.length())
}
