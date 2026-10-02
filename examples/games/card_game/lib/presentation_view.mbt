///|
priv struct ActorPose {
  x : Double
  y : Double
}

///|
fn ease_out(t : Double) -> Double {
  let clamped = ui_max(0.0, ui_min(1.0, t))
  1.0 - (1.0 - clamped) * (1.0 - clamped) * (1.0 - clamped)
}

///|
fn Game::actor_pose(self : Game, fighter : Fighter, index : Int) -> ActorPose {
  if self.reduced_motion {
    return { x: 0.0, y: 0.0, }
  }
  let mut x = 0.0
  let mut y = 0.0
  if self.presentation is Some(p) {
    let t = p.progress()
    match p.step {
      EnemyWindup(actor) =>
        if index == actor {
          x = -12.0 * @math.sin(t * @math.PI)
        }
      CardPlay(flight, _) =>
        if index < 0 && card_def(flight.card).card_type == Attack {
          x = 10.0 * @math.sin(t * @math.PI)
        }
      BattleOutcome(_) => if fighter.is_dead() { y = 5.0 * ease_out(t) }
      _ => ()
    }
    if self.feedback() is Some(before) {
      let old = if index < 0 { before.player } else { before.enemies[index] }
      let effect_t = self.effect_progress()
      if fighter.hp < old.hp && effect_t > 0.0 {
        x += 4.0 * @math.sin(effect_t * @math.PI * 6.0) * (1.0 - effect_t)
      }
    }
  }
  { x, y, }
}

///|
fn Game::actor_color(
  self : Game,
  fighter : Fighter,
  index : Int,
  base : Int,
) -> Int {
  if fighter.is_dead() {
    return 0x806776
  }
  if self.feedback() is Some(before) {
    let old = if index < 0 { before.player } else { before.enemies[index] }
    let t = self.effect_progress()
    if !self.reduced_motion && t > 0.0 && t < 0.18 && fighter.hp < old.hp {
      return ink
    }
    if fighter.block > old.block {
      return cyan
    }
    if fighter.status.strength > old.strength {
      return gold
    }
  }
  base
}

///|
fn Game::show_enemy(self : Game, fighter : Fighter, index : Int) -> Bool {
  if !fighter.is_dead() {
    return true
  }
  if self.feedback() is Some(before) && before.enemies[index].hp > 0 {
    return true
  }
  match self.presentation {
    Some({ step: BattleOutcome(defeated), .. }) => defeated.contains(index)
    _ => false
  }
}

///|
fn Game::draw_card_offset(self : Game, index : Int) -> Double {
  if self.reduced_motion {
    return 0.0
  }
  match self.presentation {
    Some({ step: DrawHand, elapsed_ms, .. }) =>
      12.0 *
      (
        1.0 -
        ease_out((elapsed_ms - ui_min(index, 4).to_double() * 30.0) / 240.0)
      )
    _ => 0.0
  }
}

///|
/// Effect labels occupy the sprite space; the name, intent and HP rows stay legible.
fn effect_center(rect : UiRect, hero : Bool) -> (Double, Double) {
  let y = if hero {
    if rect.h < 110.0 {
      29.0
    } else {
      56.0
    }
  } else {
    let size = ui_min(48.0, ui_max(0.0, rect.h - 72.0))
    (if rect.h >= 130.0 { 48.0 } else { 40.0 }) + size / 2.0
  }
  (rect.x + rect.w / 2.0, rect.y + y)
}

///|
fn Game::view_fighter_feedback(
  self : Game,
  fighter : Fighter,
  before : FighterFrame,
  rect : UiRect,
  index : Int,
  action : String,
) -> @scene.SceneNode {
  let delta = fighter.hp - before.hp
  let gained_block = fighter.block - before.block
  let lost_block = before.block - fighter.block
  let gained_strength = fighter.status.strength - before.strength
  let (text, color) = if delta < 0 {
    (delta.to_string(), 0xFFAF95)
  } else if delta > 0 {
    ("+" + delta.to_string(), cyan)
  } else if gained_block > 0 {
    ("+" + gained_block.to_string() + " B", cyan)
  } else if lost_block > 0 {
    ("BLOCK", cyan)
  } else if gained_strength > 0 {
    ("+" + gained_strength.to_string() + " S", gold)
  } else {
    (action, gold)
  }
  let t = self.effect_progress()
  if text == "" || (!self.reduced_motion && (t <= 0.0 || t >= 0.92)) {
    return @scene.fragment([])
  }
  let (cx, cy) = effect_center(rect, index < 0)
  let rise = if self.reduced_motion { 0.0 } else { 4.0 * ease_out(t) }
  let width = ui_min(rect.w - 12.0, 66.0)
  let nodes : Array[@scene.SceneNode] = []
  if !self.reduced_motion && delta < 0 {
    // A short diagonal slash and sparks, inside the actor's body region.
    let reach = ui_min(20.0, ui_max(5.0, rect.h / 8.0))
    nodes.push(
      @scene.line(
        x0=cx - reach,
        y0=cy + reach * 0.3,
        x1=cx + reach,
        y1=cy - reach * 0.3,
        width=3.0 * (1.0 - t),
        color=gold,
      ),
    )
    for i in 0..<4 {
      let angle = i.to_double() * @math.PI / 2.0 + 0.4
      let distance = reach * ease_out(t)
      nodes.push(
        @scene.rect(
          x=cx + @math.cos(angle) * distance - 1.5,
          y=cy + @math.sin(angle) * distance * 0.3 - 1.5,
          w=3.0,
          h=3.0,
          fill=gold,
          alpha=1.0 - t,
        ),
      )
    }
  }
  if gained_block > 0 || lost_block > 0 {
    nodes.push(
      @scene.rect_outline(
        x=cx - width / 2.0 - 2.0,
        y=cy - rise - 9.0,
        w=width + 4.0,
        h=18.0,
        line_width=2.0,
        color=cyan,
      ),
    )
  }
  nodes.push(
    ui_panel(
      "combat_popup_" + index.to_string(),
      { x: cx - width / 2.0, y: cy - rise - 7.0, w: width, h: 14.0, },
      0x10151C,
      color,
      [
        fit_text(
          "amount",
          width / 2.0,
          7.0,
          text,
          width - 6.0,
          scale=0.65,
          color~,
        ),
      ],
    ),
  )
  @scene.fragment(nodes)
}

///|
fn Game::view_combat_effects(
  self : Game,
  state : BattleState,
) -> @scene.SceneNode {
  let nodes : Array[@scene.SceneNode] = []
  if self.feedback() is Some(before) {
    nodes.push(
      self.view_fighter_feedback(
        state.player,
        before.player,
        self.layout.player_rect(),
        -1,
        "",
      ),
    )
    for i in 0..<state.enemies.length() {
      let action = match self.presentation {
        Some({ step: EnemyImpact(index, _), .. }) =>
          if index == i {
            match before.intents[i] {
              DefendIntent(_) => "GUARD"
              BuffIntent => "BUFF"
              DebuffIntent => "HEX"
              _ => ""
            }
          } else {
            ""
          }
        _ => ""
      }
      nodes.push(
        self.view_fighter_feedback(
          state.enemies[i].fighter,
          before.enemies[i],
          self.layout.enemy_rect(i, state.enemies.length()),
          i,
          action,
        ),
      )
    }
  }
  if self.presentation is Some(p) {
    match p.step {
      CardPlay(flight, _) =>
        if !self.reduced_motion {
          let start = self.layout.card_rect(flight.slot, flight.hand_count)
          let t = ease_out(p.progress())
          let size = 30.0 * (1.0 - t) + 3.0
          let x = (start.x + start.w / 2.0) * (1.0 - t) +
            (self.layout.w - 22.0) * t
          let y = (start.y + 40.0) * (1.0 - t) + (self.layout.h - 42.0) * t
          nodes.push(
            @scene.rect(
              key="played_card",
              x=x - size / 2.0,
              y=y - size / 2.0,
              w=size,
              h=size * 1.3,
              fill=gold,
              alpha=1.0 - p.progress(),
            ),
          )
        }
      BattleOutcome(_) => {
        let won = state.phase == Victory
        nodes.push(
          fit_text(
            "outcome_title",
            self.layout.w / 2.0,
            self.layout.hand_y + 38.0,
            if won {
              "VICTORY"
            } else {
              "DEFEAT"
            },
            self.layout.w - 40.0,
            scale=1.6,
            color=if won { gold } else { 0xFFAF95 },
          ),
        )
        nodes.push(
          fit_text(
            "outcome_hint",
            self.layout.w / 2.0,
            self.layout.hand_y + 72.0,
            if won {
              "THE PATH AHEAD OPENS"
            } else {
              "YOUR JOURNEY ENDS HERE"
            },
            self.layout.w - 40.0,
            scale=0.65,
            color=muted_ink,
          ),
        )
      }
      _ => ()
    }
  }
  @scene.fragment(nodes)
}

///|
fn Game::view_screen_fade(self : Game) -> @scene.SceneNode {
  if !self.reduced_motion &&
    self.presentation is Some({ step: Travel(_), .. } as p) {
    let alpha = 1.0 - (p.progress() * 2.0 - 1.0).abs()
    return @scene.rect(
      key="screen_fade",
      w=self.layout.w,
      h=self.layout.h,
      fill=0x0C1119,
      alpha~,
    )
  }
  @scene.fragment([])
}

///|
fn Game::actor_alpha(self : Game, fighter : Fighter) -> Double {
  if !self.reduced_motion &&
    fighter.is_dead() &&
    self.presentation is Some({ step: BattleOutcome(_), .. } as p) {
    return 1.0 - ease_out(p.progress())
  }
  1.0
}

///|
fn Game::shown_intent(self : Game, enemy : Enemy, index : Int) -> Intent {
  match self.presentation {
    Some({ step: EnemyImpact(actor, before), .. }) =>
      if actor == index {
        before.intents[index]
      } else {
        enemy.intent
      }
    _ => enemy.intent
  }
}
