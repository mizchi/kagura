///|
let card_w : Double = 70.0

///|
let card_h : Double = 90.0

///|
let card_gap : Double = 8.0

///|
/// Main game struct wrapping battle state with UI state
pub(all) struct Game {
  battle : @signals.Signal[BattleState]
  selected_card : @signals.Signal[Int] // -1 = none
  target_enemy : @signals.Signal[Int] // -1 = none
  input : @inpututil.InputHelper
  mut cursor_x : Double
  mut cursor_y : Double
  mut need_target : Bool // waiting for target selection
}

///|
fn Game::new() -> Game {
  let battle = BattleState::new([JawWorm], relics=[BurningBlood, Vajra])
  {
    battle: @signals.signal(battle),
    selected_card: @signals.signal(-1),
    target_enemy: @signals.signal(-1),
    input: @inpututil.new_input_helper(),
    cursor_x: 0.0,
    cursor_y: 0.0,
    need_target: false,
  }
}

///|
fn Game::update(self : Game, input : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, input)
  self.cursor_x = input.cursor_x
  self.cursor_y = input.cursor_y
  let clicked = @inpututil.is_mouse_button_just_pressed(
    self.input.mouse_state,
    0,
  )
  if not(clicked) {
    return
  }
  @signals.batch(fn() {
    let state = self.battle.get()
    match state.phase {
      Victory | Defeat => {
        let new_state = BattleState::new(
          [JawWorm],
          seed=state.rng_seed + 1,
          relics=state.relics,
        )
        self.battle.set(new_state)
        self.selected_card.set(-1)
        self.target_enemy.set(-1)
        self.need_target = false
      }
      PlayerTurn => {
        let cx = self.cursor_x
        let cy = self.cursor_y
        if hit_test_end_turn(cx, cy) {
          end_player_turn(state)
          self.battle.set(state)
          self.selected_card.set(-1)
          self.need_target = false
          return
        }
        if self.need_target {
          let enemy_idx = hit_test_enemy(state, cx, cy)
          if enemy_idx >= 0 {
            let card_idx = self.selected_card.get()
            let result = play_card(state, card_idx, enemy_idx)
            if result == Ok {
              self.battle.set(state)
            }
            self.selected_card.set(-1)
            self.need_target = false
          } else {
            self.selected_card.set(-1)
            self.need_target = false
          }
        } else {
          let card_idx = hit_test_card(state, cx, cy)
          if card_idx >= 0 {
            let card_id = state.hand[card_idx]
            let def = card_def(card_id)
            if state.player.energy >= def.cost {
              if card_needs_target(card_id) {
                if alive_enemy_count(state) == 1 {
                  let target = first_alive_enemy(state)
                  let result = play_card(state, card_idx, target)
                  if result == Ok {
                    self.battle.set(state)
                  }
                } else {
                  self.selected_card.set(card_idx)
                  self.need_target = true
                }
              } else {
                let result = play_card(state, card_idx, 0)
                if result == Ok {
                  self.battle.set(state)
                }
              }
            }
          }
        }
      }
      _ => ()
    }
  })
}

///|
fn hit_test_card(state : BattleState, cx : Double, cy : Double) -> Int {
  let hand_count = state.hand.length()
  if hand_count == 0 {
    return -1
  }
  let total_w = hand_count.to_double() * card_w +
    (hand_count - 1).to_double() * card_gap
  let start_x = (screen_w.to_double() - total_w) / 2.0
  let card_y = screen_h.to_double() - card_h - 10.0
  let mut i = 0
  while i < hand_count {
    let x = start_x + i.to_double() * (card_w + card_gap)
    if cx >= x && cx <= x + card_w && cy >= card_y && cy <= card_y + card_h {
      return i
    }
    i += 1
  }
  -1
}

///|
fn hit_test_enemy(state : BattleState, cx : Double, cy : Double) -> Int {
  let enemy_w = 60.0
  let enemy_h = 80.0
  let count = state.enemies.length()
  let total_w = count.to_double() * enemy_w + (count - 1).to_double() * 20.0
  let start_x = (screen_w.to_double() - total_w) / 2.0
  let enemy_y = 40.0
  let mut i = 0
  while i < count {
    if not(state.enemies[i].fighter.is_dead()) {
      let x = start_x + i.to_double() * (enemy_w + 20.0)
      if cx >= x &&
        cx <= x + enemy_w &&
        cy >= enemy_y &&
        cy <= enemy_y + enemy_h {
        return i
      }
    }
    i += 1
  }
  -1
}

///|
fn hit_test_end_turn(cx : Double, cy : Double) -> Bool {
  let bx = screen_w.to_double() - 90.0
  let by = screen_h.to_double() - card_h - 50.0
  cx >= bx && cx <= bx + 80.0 && cy >= by && cy <= by + 30.0
}

///|
fn Game::view(self : Game) -> @scene.SceneNode {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let state = self.battle.get()
  @scene.fragment([
    @scene.rect(w=sw, h=sh, fill=0x1a1a2e),
    view_enemies(state),
    view_player_info(state),
    view_relics(state),
    view_hand(state, self.selected_card.get()),
    @scene.show(fn() { self.battle.get().phase == PlayerTurn }, fn() {
      view_end_turn_button()
    }),
    @scene.show(fn() { self.need_target }, fn() {
      @scene.label(
        x=sw / 2.0 - 40.0,
        y=sh / 2.0 - 10.0,
        content="Select target",
        color=0xFFFF00,
      )
    }),
    view_logs(state),
    @scene.show(
      fn() {
        let p = self.battle.get().phase
        p == Victory || p == Defeat
      },
      fn() { view_game_over(self.battle.get()) },
    ),
  ])
}

///|
fn view_enemies(state : BattleState) -> @scene.SceneNode {
  let enemy_w = 60.0
  let enemy_h = 80.0
  let count = state.enemies.length()
  let total_w = count.to_double() * enemy_w + (count - 1).to_double() * 20.0
  let start_x = (screen_w.to_double() - total_w) / 2.0
  let enemy_y = 40.0
  @scene.for_each(fn() {
    let nodes : Array[@scene.SceneNode] = []
    let mut i = 0
    while i < count {
      let enemy = state.enemies[i]
      let x = start_x + i.to_double() * (enemy_w + 20.0)
      if not(enemy.fighter.is_dead()) {
        let body_color = if enemy.fighter.status.vulnerable > 0 {
          0xFF6666
        } else {
          0xCC4444
        }
        nodes.push(
          @scene.rect(x~, y=enemy_y, w=enemy_w, h=enemy_h, fill=body_color),
        )
        nodes.push(
          @scene.label(
            x=x + 2.0,
            y=enemy_y + 2.0,
            content=enemy.fighter.name,
            scale=0.6,
          ),
        )
        // HP bar
        nodes.push(
          @scene.rect(
            x~,
            y=enemy_y + enemy_h + 2.0,
            w=enemy_w,
            h=8.0,
            fill=0x333333,
          ),
        )
        let hp_ratio = enemy.fighter.hp.to_double() /
          enemy.fighter.max_hp.to_double()
        nodes.push(
          @scene.rect(
            x~,
            y=enemy_y + enemy_h + 2.0,
            w=enemy_w * hp_ratio,
            h=8.0,
            fill=0x44CC44,
          ),
        )
        nodes.push(
          @scene.label(
            x=x + 2.0,
            y=enemy_y + enemy_h + 2.0,
            content=enemy.fighter.hp.to_string() +
              "/" +
              enemy.fighter.max_hp.to_string(),
            scale=0.5,
          ),
        )
        // Block
        if enemy.fighter.block > 0 {
          nodes.push(
            @scene.rect(
              x=x + enemy_w - 20.0,
              y=enemy_y,
              w=20.0,
              h=16.0,
              fill=0x4488CC,
            ),
          )
          nodes.push(
            @scene.label(
              x=x + enemy_w - 18.0,
              y=enemy_y + 1.0,
              content=enemy.fighter.block.to_string(),
              scale=0.6,
            ),
          )
        }
        // Intent
        let intent_text = match enemy.intent {
          AttackIntent(n) => "ATK " + n.to_string()
          DefendIntent(n) => "DEF " + n.to_string()
          BuffIntent => "BUFF"
          MultiAttack(n, t) => "ATK " + n.to_string() + "x" + t.to_string()
        }
        nodes.push(
          @scene.label(
            x=x + 2.0,
            y=enemy_y - 14.0,
            content=intent_text,
            color=0xFF8800,
            scale=0.6,
          ),
        )
        // Status effects
        let mut status_x = x + 2.0
        if enemy.fighter.status.strength > 0 {
          nodes.push(
            @scene.label(
              x=status_x,
              y=enemy_y + enemy_h + 14.0,
              content="STR+" + enemy.fighter.status.strength.to_string(),
              color=0xFF4444,
              scale=0.5,
            ),
          )
          status_x += 30.0
        }
        if enemy.fighter.status.vulnerable > 0 {
          nodes.push(
            @scene.label(
              x=status_x,
              y=enemy_y + enemy_h + 14.0,
              content="VUL" + enemy.fighter.status.vulnerable.to_string(),
              color=0xFFAA00,
              scale=0.5,
            ),
          )
          status_x += 28.0
        }
        if enemy.fighter.status.weak > 0 {
          nodes.push(
            @scene.label(
              x=status_x,
              y=enemy_y + enemy_h + 14.0,
              content="WK" + enemy.fighter.status.weak.to_string(),
              color=0xAA88FF,
              scale=0.5,
            ),
          )
        }
      }
      i += 1
    }
    nodes
  })
}

///|
fn view_player_info(state : BattleState) -> @scene.SceneNode {
  let p = state.player
  let info_x = 10.0
  let info_y = screen_h.to_double() - card_h - 60.0
  @scene.fragment([
    // HP bar
    @scene.rect(x=info_x, y=info_y, w=100.0, h=12.0, fill=0x333333),
    @scene.rect(
      x=info_x,
      y=info_y,
      w=100.0 * p.hp.to_double() / p.max_hp.to_double(),
      h=12.0,
      fill=0xCC4444,
    ),
    @scene.label(
      x=info_x + 2.0,
      y=info_y,
      content="HP " + p.hp.to_string() + "/" + p.max_hp.to_string(),
      scale=0.6,
    ),
    // Energy
    @scene.rect(x=info_x, y=info_y + 16.0, w=40.0, h=20.0, fill=0x2244AA),
    @scene.label(
      x=info_x + 4.0,
      y=info_y + 18.0,
      content=p.energy.to_string() + "/" + p.max_energy.to_string(),
      color=0xFFDD44,
      scale=0.8,
    ),
    // Block
    @scene.show(fn() { state.player.block > 0 }, fn() {
      @scene.fragment([
        @scene.rect(
          x=info_x + 50.0,
          y=info_y + 16.0,
          w=40.0,
          h=20.0,
          fill=0x4488CC,
        ),
        @scene.label(
          x=info_x + 54.0,
          y=info_y + 18.0,
          content="BLK " + state.player.block.to_string(),
          scale=0.6,
        ),
      ])
    }),
    // Status effects
    @scene.for_each(fn() {
      let nodes : Array[@scene.SceneNode] = []
      let mut sx = info_x
      let sy = info_y + 40.0
      if state.player.status.strength > 0 {
        nodes.push(
          @scene.label(
            x=sx,
            y=sy,
            content="STR+" + state.player.status.strength.to_string(),
            color=0xFF4444,
            scale=0.5,
          ),
        )
        sx += 35.0
      }
      if state.player.status.weak > 0 {
        nodes.push(
          @scene.label(
            x=sx,
            y=sy,
            content="WK" + state.player.status.weak.to_string(),
            color=0xAA88FF,
            scale=0.5,
          ),
        )
        sx += 25.0
      }
      if state.player.status.vulnerable > 0 {
        nodes.push(
          @scene.label(
            x=sx,
            y=sy,
            content="VUL" + state.player.status.vulnerable.to_string(),
            color=0xFFAA00,
            scale=0.5,
          ),
        )
      }
      nodes
    }),
    // Deck info
    @scene.label(
      x=info_x + 110.0,
      y=info_y,
      content="Deck:" + state.draw_pile.length().to_string(),
      scale=0.5,
      color=0x888888,
    ),
    @scene.label(
      x=info_x + 110.0,
      y=info_y + 10.0,
      content="Disc:" + state.discard_pile.length().to_string(),
      scale=0.5,
      color=0x888888,
    ),
    @scene.label(
      x=info_x + 110.0,
      y=info_y + 20.0,
      content="Exh:" + state.exhaust_pile.length().to_string(),
      scale=0.5,
      color=0x666666,
    ),
  ])
}

///|
fn view_relics(state : BattleState) -> @scene.SceneNode {
  let relic_y = screen_h.to_double() - card_h - 80.0
  let relic_size = 16.0
  let gap = 4.0
  @scene.for_each(fn() {
    let nodes : Array[@scene.SceneNode] = []
    let mut i = 0
    let base_x = screen_w.to_double() - 100.0
    while i < state.relics.length() {
      let def = relic_def(state.relics[i])
      let x = base_x + i.to_double() * (relic_size + gap)
      let color = relic_color(state.relics[i])
      nodes.push(
        @scene.rect(x~, y=relic_y, w=relic_size, h=relic_size, fill=color),
      )
      nodes.push(
        @scene.rect_outline(
          x~,
          y=relic_y,
          w=relic_size,
          h=relic_size,
          color=0xAAAAAA,
        ),
      )
      // First letter as icon
      let initial = def.name[:1].to_string()
      nodes.push(
        @scene.label(x=x + 2.0, y=relic_y + 1.0, content=initial, scale=0.5),
      )
      i += 1
    }
    // Label
    if state.relics.length() > 0 {
      nodes.push(
        @scene.label(
          x=base_x,
          y=relic_y - 12.0,
          content="Relics",
          scale=0.45,
          color=0x888888,
        ),
      )
    }
    nodes
  })
}

///|
fn relic_color(id : RelicId) -> Int {
  match id {
    BurningBlood => 0x882222
    Vajra => 0x884422
    Anchor => 0x224488
    Orichalcum => 0x448844
    BagOfMarbles => 0x664488
    Lantern => 0x888844
    PenNib => 0x444488
    MeatOnTheBone => 0x884444
  }
}

///|
fn view_hand(state : BattleState, selected : Int) -> @scene.SceneNode {
  let hand_count = state.hand.length()
  let total_w = hand_count.to_double() * card_w +
    (hand_count - 1).to_double() * card_gap
  let start_x = (screen_w.to_double() - total_w) / 2.0
  let base_y = screen_h.to_double() - card_h - 10.0
  @scene.for_each(fn() {
    let nodes : Array[@scene.SceneNode] = []
    let mut i = 0
    while i < hand_count {
      let card_id = state.hand[i]
      let def = card_def(card_id)
      let x = start_x + i.to_double() * (card_w + card_gap)
      let y = if i == selected { base_y - 10.0 } else { base_y }
      let can_play = state.player.energy >= def.cost &&
        state.phase == PlayerTurn
      // Card background
      let bg_color = if not(can_play) {
        0x333344
      } else {
        match def.card_type {
          Attack => 0x884444
          Skill => 0x448844
          Power => 0x444488
        }
      }
      nodes.push(@scene.rect(x~, y~, w=card_w, h=card_h, fill=bg_color))
      let border_color = if i == selected { 0xFFFF00 } else { 0x666666 }
      nodes.push(
        @scene.rect_outline(x~, y~, w=card_w, h=card_h, color=border_color),
      )
      // Card name
      nodes.push(
        @scene.label(x=x + 3.0, y=y + 4.0, content=def.name, scale=0.55),
      )
      // Cost
      nodes.push(@scene.rect(x~, y~, w=16.0, h=16.0, fill=0x2244AA))
      nodes.push(
        @scene.label(
          x=x + 4.0,
          y=y + 1.0,
          content=def.cost.to_string(),
          color=0xFFDD44,
          scale=0.7,
        ),
      )
      // Description
      nodes.push(
        @scene.label(
          x=x + 3.0,
          y=y + 24.0,
          content=short_desc(def),
          scale=0.4,
          color=0xCCCCCC,
        ),
      )
      // Exhaust indicator
      if def.exhaust {
        nodes.push(
          @scene.label(
            x=x + 3.0,
            y=y + card_h - 14.0,
            content="Exhaust",
            scale=0.35,
            color=0xFF6666,
          ),
        )
      }
      i += 1
    }
    nodes
  })
}

///|
fn short_desc(def : CardDef) -> String {
  match def.id {
    Strike => "DMG 6"
    Defend => "BLK 5"
    Bash => "DMG 8 VUL2"
    Cleave => "DMG 8 ALL"
    Pommel_Strike => "DMG 9 +1"
    Shrug_It_Off => "BLK 8 +1"
    Inflame => "STR +2"
    Body_Slam => "DMG=BLK"
    Twin_Strike => "DMG 5x2"
    Clothesline => "DMG 12 WK2"
    Iron_Wave => "BLK5 DMG5"
    Bloodletting => "-3HP +2E"
    Offering => "-6HP +2E +3"
    Uppercut => "D13 WK1 VU1"
    Seeing_Red => "+2 Energy"
    Armaments => "BLK 5"
  }
}

///|
fn view_end_turn_button() -> @scene.SceneNode {
  let bx = screen_w.to_double() - 90.0
  let by = screen_h.to_double() - card_h - 50.0
  @scene.fragment([
    @scene.rect(x=bx, y=by, w=80.0, h=30.0, fill=0x885522),
    @scene.rect_outline(x=bx, y=by, w=80.0, h=30.0, color=0xAA7744),
    @scene.label(x=bx + 6.0, y=by + 6.0, content="End Turn", scale=0.7),
  ])
}

///|
fn view_logs(state : BattleState) -> @scene.SceneNode {
  let log_x = 10.0
  let log_y = 150.0
  @scene.for_each(fn() {
    let nodes : Array[@scene.SceneNode] = []
    let logs = state.logs
    let start = if logs.length() > 4 { logs.length() - 4 } else { 0 }
    let mut idx = 0
    let mut i = start
    while i < logs.length() {
      nodes.push(
        @scene.label(
          x=log_x,
          y=log_y + idx.to_double() * 12.0,
          content=logs[i],
          scale=0.45,
          color=0x999999,
        ),
      )
      idx += 1
      i += 1
    }
    nodes
  })
}

///|
fn view_game_over(state : BattleState) -> @scene.SceneNode {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let (text, color) = match state.phase {
    Victory => ("VICTORY!", 0x44FF44)
    Defeat => ("DEFEAT", 0xFF4444)
    _ => ("", 0xFFFFFF)
  }
  @scene.fragment([
    @scene.rect(w=sw, h=sh, fill=0x000000, alpha=0.6),
    @scene.label(
      x=sw / 2.0 - 40.0,
      y=sh / 2.0 - 10.0,
      content=text,
      color~,
      scale=2.0,
    ),
    @scene.label(
      x=sw / 2.0 - 40.0,
      y=sh / 2.0 + 20.0,
      content="Click to restart",
      scale=0.7,
    ),
  ])
}
