///|
pub fn Game::view(self : Game) -> @scene.SceneNode {
  let run = self.run.get()
  let l = self.layout
  let nodes : Array[@scene.SceneNode] = [
    @scene.rect(w=l.w, h=l.h, fill=0x10151C),
    @scene.rect(y=52.0, w=l.w, h=l.h - 52.0, fill=0x151E2A),
  ]
  if self.deck_open {
    nodes.push(view_deck(run, l, self.deck_page))
  } else {
    match run.phase {
      Battle =>
        match run.battle {
          Some(state) =>
            if state.phase == Victory || state.phase == Defeat {
              nodes.push(
                view_result(
                  l,
                  if state.phase == Victory {
                    "BATTLE WON"
                  } else {
                    "YOU HAVE FALLEN"
                  },
                  if state.phase == Victory {
                    "CHOOSE A CARD AND CONTINUE"
                  } else {
                    "YOUR JOURNEY ENDS HERE"
                  },
                  "CONTINUE",
                ),
              )
            } else {
              nodes.push(self.view_battle(state))
            }
          None => ()
        }
      CardReward => nodes.push(view_reward(run, l))
      RestSite => nodes.push(view_rest(run, l))
      RunVictory | RunDefeat =>
        nodes.push(
          view_result(
            l,
            if run.phase == RunVictory {
              "SUMMIT REACHED"
            } else {
              "RUN ENDED"
            },
            "FLOOR " +
            run.floor.to_string() +
            " / DECK " +
            run.deck.length().to_string(),
            "NEW RUN",
          ),
        )
    }
  }
  nodes.push(view_header(run, l))
  @scene.fragment(nodes)
}

///|
fn view_header(run : RunState, l : GameLayout) -> @scene.SceneNode {
  let hp = match run.battle {
    Some(b) => if run.phase == Battle { b.player.hp } else { run.player_hp }
    None => run.player_hp
  }
  @scene.fragment([
    @scene.rect(w=l.w, h=52.0, fill=0x0C1119),
    fit_text("title", 80.0, 17.0, "EMBER ASCENT", 136.0, scale=0.95, color=gold),
    ui_text(
      "floor",
      80.0,
      37.0,
      "ACT " +
      floor_act(run.floor).to_string() +
      " / FLOOR " +
      run.floor.to_string(),
      scale=0.55,
      color=muted_ink,
    ),
    fit_text(
      "run_hp",
      (160.0 + l.w - 112.0) / 2.0,
      26.0,
      "HP " + hp.to_string() + "/" + run.player_max_hp.to_string(),
      l.w - 284.0,
      scale=0.75,
    ),
    ui_button(
      "deck_btn",
      deck_button_rect(l),
      "DECK " + run.deck.length().to_string(),
      accent=cyan,
    ),
  ])
}

///|
fn view_route(run : RunState, l : GameLayout) -> @scene.SceneNode {
  let nodes : Array[@scene.SceneNode] = []
  let act_start = if run.floor <= 15 { 1 } else { 16 }
  let step = ui_min(36.0, (l.w - 32.0) / 15.0)
  let start_x = (l.w - step * 15.0) / 2.0
  for i = 0; i < 15; i = i + 1 {
    let floor = act_start + i
    let color = if floor < run.floor {
      cyan
    } else if floor == run.floor {
      gold
    } else {
      muted_ink
    }
    let label = match floor_type(floor) {
      Rest => "R"
      Boss | Combat(Boss) => "B"
      Combat(Elite) => "E"
      _ => "+"
    }
    nodes.push(
      @scene.rect(
        x=start_x + i.to_double() * step + 3.0,
        y=61.0,
        w=step - 6.0,
        h=14.0,
        fill=if floor == run.floor { 0x3B3024 } else { 0x222C3B },
      ),
    )
    nodes.push(
      ui_text(
        "route_" + floor.to_string(),
        start_x + (i.to_double() + 0.5) * step,
        68.0,
        label,
        scale=0.6,
        color~,
      ),
    )
  }
  @scene.fragment(nodes)
}

///|
fn Game::view_battle(self : Game, state : BattleState) -> @scene.SceneNode {
  let l = self.layout
  let selected = self.selected_card.get()
  let dragging = self.gesture is Some({ dragged: true, .. })
  let hovered = hit_card(l, state.hand.length(), self.cursor_x, self.cursor_y)
  let nodes : Array[@scene.SceneNode] = [view_route(self.run.get(), l)]
  let area = l.play_area()
  nodes.push(@scene.rect(x=area.x, y=area.y, w=area.w, h=area.h, fill=0x1A2533))
  if dragging && selected >= 0 && !card_needs_target(state.hand[selected]) {
    nodes.push(
      @scene.rect_outline(
        x=area.x,
        y=area.y,
        w=area.w,
        h=area.h,
        line_width=2.0,
        color=cyan,
      ),
    )
  }
  let player = l.player_rect()
  let count = state.hand.length()
  let crowded = count > 1 &&
    l.card_rect(1, count).x - l.card_rect(0, count).x <
    l.card_rect(0, count).w - 8.0
  let inspecting = crowded && hovered >= 0 && !dragging
  if inspecting {
    nodes.push(view_card_detail(state.hand[hovered], area))
  } else {
    nodes.push(view_player(state, player))
    for i = 0; i < state.enemies.length(); i = i + 1 {
      if !state.enemies[i].fighter.is_dead() {
        let enemy = state.enemies[i]
        nodes.push(
          view_enemy(
            enemy,
            l.enemy_rect(i, state.enemies.length()),
            i,
            self.need_target && self.target_enemy.get() == i,
          ),
        )
      }
    }
  }
  let energy_text = "ENERGY " +
    state.player.energy.to_string() +
    "/" +
    state.player.max_energy.to_string()
  nodes.push(
    ui_panel(
      "energy_panel",
      {
        x: 16.0,
        y: l.command_y,
        w: if l.w < 400.0 {
          104.0
        } else {
          130.0
        },
        h: 44.0,
      },
      0x253044,
      cyan,
      [
        fit_text(
          "energy",
          if l.w < 400.0 {
            52.0
          } else {
            65.0
          },
          22.0,
          energy_text,
          if l.w < 400.0 {
            92.0
          } else {
            118.0
          },
          scale=0.85,
          color=cyan,
        ),
      ],
    ),
  )
  let pile_x = if l.w < 400.0 { 178.0 } else { 212.0 }
  nodes.push(
    ui_text(
      "piles",
      pile_x,
      l.command_y + 13.0,
      "DRAW " +
      state.draw_pile.length().to_string() +
      " / DISC " +
      state.discard_pile.length().to_string(),
      scale=if l.w < 400.0 { 0.45 } else { 0.55 },
      color=muted_ink,
    ),
  )
  nodes.push(
    ui_text(
      "turn",
      pile_x,
      l.command_y + 31.0,
      "TURN " +
      state.turn.to_string() +
      " / EXH " +
      state.exhaust_pile.length().to_string(),
      scale=0.5,
      color=muted_ink,
    ),
  )
  nodes.push(ui_button("end_turn_btn", l.end_turn_rect(), "END TURN"))
  if l.h >= 440.0 {
    let log = if state.logs.length() > 0 {
      state.logs[state.logs.length() - 1]
    } else {
      ""
    }
    nodes.push(
      fit_text(
        "battle_log",
        l.w / 2.0,
        l.command_y - 16.0,
        log,
        l.w - 40.0,
        scale=0.6,
        color=muted_ink,
      ),
    )
  }
  for i = 0; i < count; i = i + 1 {
    if !(dragging && selected == i) {
      let r = l.card_rect(i, count)
      let raised : UiRect = {
        ..r,
        y: r.y -
        (if !crowded && (i == selected || i == hovered) { 8.0 } else { 0.0 }),
      }
      nodes.push(
        ui_card(
          "card_frame_" + i.to_string(),
          raised,
          state.hand[i],
          card_play_cost(state, state.hand[i]),
          can_play_card(state, i),
          i == selected,
          spine=crowded,
        ),
      )
    }
  }
  if dragging && selected >= 0 {
    // Keep the dragged preview clear of the target's intent and HP.
    let card = state.hand[selected]
    let preview = drag_card_rect(
      l,
      state,
      selected,
      self.cursor_x,
      self.cursor_y,
    )
    nodes.push(
      @scene.line(
        x0=self.gesture.unwrap().start_x,
        y0=l.hand_y,
        x1=self.cursor_x,
        y1=self.cursor_y,
        width=2.0,
        color=gold,
      ),
    )
    nodes.push(
      ui_card(
        "drag_card",
        preview,
        card,
        card_play_cost(state, card),
        true,
        true,
      ),
    )
    nodes.push(
      @scene.rect_outline(
        x=self.cursor_x - 5.0,
        y=self.cursor_y - 5.0,
        w=10.0,
        h=10.0,
        line_width=2.0,
        color=gold,
      ),
    )
  }
  let hint = if selected >= 0 {
    self.hint
  } else if hovered >= 0 && !can_play_card(state, hovered) {
    "NOT ENOUGH ENERGY"
  } else if crowded {
    "HOVER TO INSPECT / DRAG TO PLAY"
  } else {
    self.hint
  }
  nodes.push(
    fit_text(
      "hint",
      l.w / 2.0,
      l.h - 10.0,
      hint,
      l.w - 24.0,
      scale=0.55,
      color=gold,
    ),
  )
  @scene.fragment(nodes)
}

///|
fn view_player(state : BattleState, r : UiRect) -> @scene.SceneNode {
  let p = state.player
  let compact = r.h < 110.0
  let nodes : Array[@scene.SceneNode] = [
    ui_text("name", r.w / 2.0, 13.0, "IRONCLAD", scale=0.7, color=cyan),
    ui_meter("hp_bar", 10.0, r.h - 23.0, r.w - 20.0, p.hp, p.max_hp, 0x86453D),
  ]
  if !compact {
    nodes.push(
      pixel_actor(
        "hero",
        r.w / 2.0 - 27.0,
        34.0,
        if r.h < 150.0 {
          42.0
        } else {
          54.0
        },
        0xC98A65,
        false,
      ),
    )
    nodes.push(
      fit_text(
        "block",
        r.w / 2.0,
        r.h - 43.0,
        "BLOCK " +
        p.block.to_string() +
        " / STR " +
        p.status.strength.to_string(),
        r.w - 12.0,
        scale=0.55,
        color=cyan,
      ),
    )
  } else {
    nodes.push(
      pixel_actor("hero", r.w / 2.0 - 7.0, 22.0, 14.0, 0xC98A65, false),
    )
    nodes.push(
      fit_text(
        "block",
        r.w / 2.0,
        r.h / 2.0 - 2.0,
        "BLOCK " + p.block.to_string() + " STR " + p.status.strength.to_string(),
        r.w - 12.0,
        scale=0.55,
        color=cyan,
      ),
    )
  }
  let status = "WK " +
    p.status.weak.to_string() +
    " / VUL " +
    p.status.vulnerable.to_string()
  nodes.push(
    fit_text(
      "status",
      r.w / 2.0,
      r.h - 7.0,
      status,
      r.w - 12.0,
      scale=0.45,
      color=muted_ink,
    ),
  )
  ui_panel("player", r, 0x202E3E, 0x456277, nodes)
}

///|
fn view_enemy(
  enemy : Enemy,
  r : UiRect,
  index : Int,
  targeted : Bool,
) -> @scene.SceneNode {
  let intent = match enemy.intent {
    AttackIntent(n) =>
      "ATTACK " + (n + enemy.fighter.status.strength).to_string()
    MultiAttack(n, t) =>
      "ATK " +
      (n + enemy.fighter.status.strength).to_string() +
      " X" +
      t.to_string()
    DefendIntent(n) => "BLOCK " + n.to_string()
    BuffIntent => "BUFF"
    DebuffIntent => "DEBUFF"
  }
  let nodes : Array[@scene.SceneNode] = [
    fit_text(
      "name",
      r.w / 2.0,
      12.0,
      enemy.fighter.name,
      r.w - 12.0,
      scale=0.65,
    ),
    fit_text(
      "intent",
      r.w / 2.0,
      30.0,
      intent,
      r.w - 12.0,
      scale=0.65,
      color=gold,
    ),
    ui_meter(
      "hp",
      8.0,
      r.h - 28.0,
      r.w - 16.0,
      enemy.fighter.hp,
      enemy.fighter.max_hp,
      0x86453D,
    ),
    fit_text(
      "status",
      r.w / 2.0,
      r.h - 10.0,
      "B " +
      enemy.fighter.block.to_string() +
      " V " +
      enemy.fighter.status.vulnerable.to_string() +
      " W " +
      enemy.fighter.status.weak.to_string(),
      r.w - 10.0,
      scale=0.45,
      color=muted_ink,
    ),
  ]
  let sprite_size = ui_min(48.0, ui_max(0.0, r.h - 72.0))
  if sprite_size > 0.0 {
    nodes.push(
      pixel_actor(
        "foe",
        r.w / 2.0 - sprite_size / 2.0,
        if r.h >= 130.0 {
          48.0
        } else {
          40.0
        },
        sprite_size,
        if enemy.fighter.status.vulnerable > 0 {
          0xE1997E
        } else {
          0xB2829B
        },
        true,
      ),
    )
  }
  ui_panel(
    "enemy_body_" + index.to_string(),
    r,
    0x302A36,
    if targeted {
      gold
    } else {
      0x806776
    },
    nodes,
  )
}

///|
fn pixel_actor(
  _key : String,
  x : Double,
  y : Double,
  size : Double,
  color : Int,
  monster : Bool,
) -> @scene.SceneNode {
  let pattern = if monster {
    [
      "00100100", "01111110", "11011011", "11111111", "01111110", "00111100", "01100110",
      "11000011",
    ]
  } else {
    [
      "00111100", "00111100", "00011000", "01111110", "10111101", "00111100", "00100100",
      "01100110",
    ]
  }
  let p = size / 8.0
  let nodes : Array[@scene.SceneNode] = []
  for row = 0; row < 8; row = row + 1 {
    for col = 0; col < 8; col = col + 1 {
      if pattern[row][col] == '1' {
        nodes.push(
          @scene.rect(
            x=x + col.to_double() * p,
            y=y + row.to_double() * p,
            w=p,
            h=p,
            fill=color,
          ),
        )
      }
    }
  }
  @scene.fragment(nodes)
}

///|
fn view_reward(run : RunState, l : GameLayout) -> @scene.SceneNode {
  let nodes : Array[@scene.SceneNode] = [
    fit_text(
      "reward_title",
      l.w / 2.0,
      l.h * 0.19,
      "CHOOSE YOUR NEXT CARD",
      l.w - 32.0,
      scale=1.15,
      color=gold,
    ),
    fit_text(
      "reward_hint",
      l.w / 2.0,
      l.h * 0.27,
      "ADD ONE TO YOUR DECK / 1 2 3",
      l.w - 32.0,
      scale=0.6,
      color=muted_ink,
    ),
    ui_button("skip_reward", l.continue_rect(), "SKIP / S", accent=muted_ink),
  ]
  for i = 0; i < run.card_rewards.length(); i = i + 1 {
    let card = run.card_rewards[i]
    nodes.push(
      ui_card(
        "reward_" + i.to_string(),
        l.reward_rect(i, run.card_rewards.length()),
        card,
        card_def(card).cost,
        true,
        false,
        detailed=true,
      ),
    )
  }
  @scene.fragment(nodes)
}

///|
fn view_rest(run : RunState, l : GameLayout) -> @scene.SceneNode {
  let heal = ui_min(run.player_max_hp - run.player_hp, run.player_max_hp / 4)
  @scene.fragment([
    fit_text(
      "rest_title",
      l.w / 2.0,
      l.h * 0.23,
      "A MOMENT OF REST",
      l.w - 32.0,
      scale=1.3,
      color=gold,
    ),
    card_icon(Inflame, l.w / 2.0 - 35.0, l.h * 0.35, 70.0, gold),
    ui_text(
      "rest_heal",
      l.w / 2.0,
      l.h * 0.57,
      "RECOVER " + heal.to_string() + " HP",
      scale=0.9,
      color=cyan,
    ),
    fit_text(
      "rest_hp",
      l.w / 2.0,
      l.h * 0.66,
      "HP " +
      run.player_hp.to_string() +
      " > " +
      (run.player_hp + heal).to_string(),
      l.w - 32.0,
      scale=0.65,
      color=muted_ink,
    ),
    ui_button("rest_btn", l.continue_rect(), "REST / ENTER"),
  ])
}

///|
fn view_result(
  l : GameLayout,
  title : String,
  subtitle : String,
  action : String,
) -> @scene.SceneNode {
  @scene.fragment([
    fit_text(
      "result_title",
      l.w / 2.0,
      l.h * 0.35,
      title,
      l.w - 32.0,
      scale=1.6,
      color=gold,
    ),
    fit_text(
      "result_detail",
      l.w / 2.0,
      l.h * 0.5,
      subtitle,
      l.w - 32.0,
      scale=0.7,
      color=muted_ink,
    ),
    ui_button("continue_btn", l.continue_rect(), action),
  ])
}

///|
fn view_deck(run : RunState, l : GameLayout, page : Int) -> @scene.SceneNode {
  let nodes : Array[@scene.SceneNode] = [
    fit_text(
      "deck_title",
      l.w / 2.0,
      90.0,
      "DECK AND RELICS",
      l.w - 24.0,
      scale=1.15,
      color=gold,
    ),
    fit_text(
      "relics",
      l.w / 2.0,
      110.0,
      "RELICS " +
      run.relics.length().to_string() +
      " / PAGE " +
      (page + 1).to_string() +
      "/" +
      deck_page_count(run).to_string(),
      l.w - 32.0,
      scale=0.5,
      color=cyan,
    ),
    ui_button("deck_close", l.continue_rect(), "CLOSE / ESC", accent=cyan),
    ui_button("deck_next", deck_next_rect(l), "NEXT PAGE >"),
  ]
  let start = page * 8
  for i = 0
      i < 8 && start + i < run.deck.length() + run.relics.length()
      i = i + 1 {
    let y = 125.0 + i.to_double() * ui_min(30.0, (l.h - 265.0) / 8.0)
    if start + i < run.deck.length() {
      let card = run.deck[start + i]
      nodes.push(
        fit_text(
          "deck_card_" + i.to_string(),
          l.w / 2.0,
          y,
          (start + i + 1).to_string() +
          " " +
          card_def(card).name +
          " / " +
          card_def(card).cost.to_string() +
          " E",
          l.w - 40.0,
          scale=0.65,
          color=card_accent(card),
        ),
      )
    } else {
      let relic = run.relics[start + i - run.deck.length()]
      nodes.push(
        fit_text(
          "deck_relic_" + i.to_string(),
          l.w / 2.0,
          y,
          "RELIC / " + relic_def(relic).name,
          l.w - 40.0,
          scale=0.65,
          color=cyan,
        ),
      )
    }
  }
  @scene.fragment(nodes)
}

///|
fn deck_page_count(run : RunState) -> Int {
  ui_max(1, (run.deck.length() + run.relics.length() + 7) / 8)
}
