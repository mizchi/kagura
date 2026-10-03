///|
pub fn Game::view(self : Game) -> @scene.SceneNode {
  let run = self.run.get()
  let l = self.layout
  let nodes : Array[@scene.SceneNode] = [
    @scene.rect(w=l.w, h=l.h, fill=0x10151C),
    @scene.rect(y=52.0, w=l.w, h=l.h - 52.0, fill=0x151E2A),
  ]
  if self.scene != Playing {
    return @scene.fragment([self.view_app_scene(), self.view_screen_fade()])
  }
  match run.phase {
    RouteMap | EventRoom | ShopRoom | CardRemoval | TreasureRoom =>
      nodes.push(self.view_adventure())
    Battle =>
      match run.battle {
        Some(state) =>
          if (state.phase == Victory || state.phase == Defeat) &&
            !self.keep_battlefield() {
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
    CardReward =>
      nodes.push(
        view_reward(
          run,
          l,
          focused=if self.combat_focus is Some(DeckButton) {
            -1
          } else {
            self.scene_focus
          },
        ),
      )
    RestSite => nodes.push(view_rest(run, l))
    RunVictory | RunDefeat =>
      nodes.push(
        view_result(
          l,
          if run.phase == RunVictory {
            if run.stage == GuardianTrial {
              "GUARDIAN DEFEATED"
            } else {
              "SUMMIT REACHED"
            }
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
  nodes.push(self.view_header(run, l))
  if self.popup is Some(_) {
    return @scene.fragment([
      @scene.group(ui_hidden=true, children=nodes),
      self.view_pile(),
      self.view_screen_fade(),
    ])
  }
  nodes.push(self.view_screen_fade())
  @scene.fragment(nodes)
}

///|
fn Game::view_header(
  self : Game,
  run : RunState,
  l : GameLayout,
) -> @scene.SceneNode {
  let hp = match run.battle {
    Some(b) =>
      if run.phase == Battle {
        self.shown_hp(b.player, -1)
      } else {
        run.player_hp
      }
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
      17.0,
      "HP " + hp.to_string() + "/" + run.player_max_hp.to_string(),
      l.w - 284.0,
      scale=0.75,
    ),
    fit_text(
      "run_gold",
      (160.0 + l.w - 112.0) / 2.0,
      37.0,
      "GOLD " + run.gold.to_string(),
      l.w - 284.0,
      scale=0.6,
      color=gold,
    ),
    ui_button(
      "deck_btn",
      deck_button_rect(l),
      "DECK " + run.deck.length().to_string(),
      focused=self.combat_focus is Some(DeckButton),
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
    let label = if run.route is Some(route) {
      let mut symbol = if floor % 15 == 0 {
        "B"
      } else if floor % 15 == 14 {
        "R"
      } else {
        "?"
      }
      for node in route.nodes {
        if node.floor == floor && route.visited.contains(node.id) {
          symbol = room_symbol(node.kind)
          break
        }
      }
      symbol
    } else {
      match floor_type(floor) {
        Rest => "R"
        Boss | Combat(Boss) => "B"
        Combat(Elite) => "E"
        _ => "+"
      }
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
  let drag = self.drag.snapshot()
  let dragging = drag is Some({ dragging: true, .. })
  let drop_targets = if drag is Some({ dragging: true, source, .. }) {
    self.card_drop_targets(source)
  } else if self.combat_focus is Some(Target(_)) && selected >= 0 {
    self.card_drop_targets(@ui.UINodeId::new(selected))
  } else {
    []
  }
  let drop_target = match self.combat_focus {
    Some(Target(index)) =>
      Some(
        @ui.UINodeId::new(
          if index < 0 {
            battlefield_drag_id
          } else {
            enemy_drag_id_base + index
          },
        ),
      )
    _ => drag.bind(d => d.target)
  }
  let accepting = drop_targets.any(t => Some(t.id) == drop_target)
  let drag_color = if drop_targets.is_empty() {
    0xFFB0A5
  } else if accepting {
    gold
  } else {
    cyan
  }
  let busy = self.presentation is Some(_)
  let end_focused = self.end_turn_focused() ||
    (self.combat_focus is Some(EndTurn) && !busy)
  let hovered = if busy || self.combat_focus is Some(Target(_)) {
    -1
  } else if self.combat_focus is Some(Hand(index)) {
    index
  } else {
    hit_card(l, state.hand.length(), self.cursor_x, self.cursor_y)
  }
  let nodes : Array[@scene.SceneNode] = [view_route(self.run.get(), l)]
  let area = l.play_area()
  nodes.push(@scene.rect(x=area.x, y=area.y, w=area.w, h=area.h, fill=0x1A2533))
  let player = l.player_rect()
  let outcome = self.presentation is Some({ step: BattleOutcome(_), .. })
  let count = if outcome { 0 } else { state.hand.length() }
  let crowded = count > 1 &&
    l.card_rect(1, count).x - l.card_rect(0, count).x <
    l.card_rect(0, count).w - 8.0
  let inspecting = crowded && hovered >= 0 && !dragging
  if inspecting {
    nodes.push(view_card_detail(state.hand[hovered], area))
  } else {
    nodes.push(self.view_player(state, player))
    for i = 0; i < state.enemies.length(); i = i + 1 {
      if self.show_enemy(state.enemies[i].fighter, i) {
        let enemy = state.enemies[i]
        nodes.push(
          self.view_enemy(
            enemy,
            l.enemy_rect(i, state.enemies.length()),
            i,
            self.need_target && self.target_enemy.get() == i,
            drop=drop_targets
              .iter()
              .find_first(t => t.id.value == enemy_drag_id_base + i)
              .map(t => {
                if Some(t.id) == drop_target {
                  Active
                } else {
                  Available
                }
              }),
          ),
        )
      }
    }
  }
  for target in drop_targets {
    nodes.push(
      ui_drop_zone(
        "drop_zone_" + target.id.value.to_string(),
        target.rect,
        if Some(target.id) == drop_target {
          Active
        } else {
          Available
        },
      ),
    )
  }
  if dragging && drag is Some(gesture) {
    // Targets are below the tether; command controls remain above it.
    nodes.push(
      @scene.line(
        key="target_tether",
        x0=gesture.start_x,
        y0=l.hand_y,
        x1=self.cursor_x,
        y1=self.cursor_y,
        width=2.0,
        color=drag_color,
      ),
    )
  }
  if self.combat_focus is Some(Target(index)) && selected >= 0 {
    let source = l.card_rect(selected, state.hand.length())
    let target = if index < 0 {
      l.player_rect()
    } else {
      l.enemy_rect(index, state.enemies.length())
    }
    nodes.push(
      @scene.line(
        key="target_tether",
        x0=source.x + source.w / 2.0,
        y0=source.y,
        x1=target.x + target.w / 2.0,
        y1=target.y + target.h / 2.0,
        width=2.0,
        color=gold,
      ),
    )
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
          15.0,
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
  nodes.push(
    fit_text(
      "turn",
      if l.w < 400.0 {
        68.0
      } else {
        81.0
      },
      l.command_y + 33.0,
      "TURN " +
      state.turn.to_string() +
      " / EXH " +
      state.exhaust_pile.length().to_string(),
      if l.w < 400.0 {
        92.0
      } else {
        118.0
      },
      scale=0.5,
      color=muted_ink,
    ),
  )
  nodes.push(
    ui_button(
      "draw_pile_btn",
      l.draw_pile_rect(),
      "DRAW " + state.draw_pile.length().to_string(),
      accent=cyan,
      focused=self.combat_focus is Some(DrawPile),
    ),
  )
  nodes.push(
    ui_button(
      "discard_pile_btn",
      l.discard_pile_rect(),
      "DISC " + state.discard_pile.length().to_string(),
      accent=cyan,
      focused=self.combat_focus is Some(DiscardPile),
    ),
  )
  nodes.push(
    ui_button(
      "end_turn_btn",
      l.end_turn_rect(),
      if state.phase == EnemyTurn {
        "ENEMY TURN"
      } else if busy {
        "WAIT"
      } else {
        "END TURN"
      },
      accent=if busy { muted_ink } else { gold },
      focused=end_focused,
    ),
  )
  if l.h >= 440.0 {
    let log = if state.logs.length() > 0 {
      state.logs[state.logs.length() - 1]
    } else {
      ""
    }
    let battlefield_drop = drop_targets.any(t => {
      t.id.value == battlefield_drag_id
    })
    nodes.push(
      fit_text(
        if battlefield_drop {
          "drop_status"
        } else {
          "battle_log"
        },
        l.w / 2.0,
        l.command_y - 16.0,
        if battlefield_drop {
          if accepting {
            if self.combat_focus is Some(Target(_)) {
              "CONFIRM TO PLAY"
            } else {
              "RELEASE TO PLAY"
            }
          } else {
            "DROP IN THE BATTLEFIELD"
          }
        } else {
          log
        },
        l.w - 40.0,
        scale=0.6,
        color=if battlefield_drop { drag_color } else { muted_ink },
      ),
    )
  }
  for i = 0; i < count; i = i + 1 {
    if !(dragging && selected == i) {
      let r = l.card_rect(i, count)
      let draw_offset = self.draw_card_offset(i)
      let raised : UiRect = {
        ..r,
        y: r.y +
        draw_offset -
        (if !crowded && (i == selected || i == hovered) { 8.0 } else { 0.0 }),
      }
      nodes.push(
        ui_card(
          "card_frame_" + i.to_string(),
          raised,
          state.hand[i],
          card_play_cost(state, state.hand[i]),
          can_play_card(state, i),
          i == selected ||
          (self.combat_focus is Some(Hand(index)) && index == i),
          spine=crowded,
          focused=self.combat_focus is Some(Hand(index)) && index == i,
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
        key=if accepting {
          "drop_cursor_accepted"
        } else {
          "drop_cursor_pending"
        },
        x=self.cursor_x - 5.0,
        y=self.cursor_y - 5.0,
        w=10.0,
        h=10.0,
        line_width=2.0,
        color=drag_color,
      ),
    )
  }
  nodes.push(self.view_combat_effects(state))
  let hint = if dragging {
    drag_feedback_hint(drop_targets, drop_target)
  } else if end_focused {
    "ENERGY 0 - ENTER / E TO END TURN"
  } else if busy || selected >= 0 || self.combat_focus is Some(_) {
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
      color=if dragging { drag_color } else { gold },
    ),
  )
  @scene.fragment(nodes)
}

///|
fn Game::view_player(
  self : Game,
  state : BattleState,
  r : UiRect,
) -> @scene.SceneNode {
  let p = state.player
  let compact = r.h < 110.0
  let pose = self.actor_pose(p, -1)
  let hero_color = self.actor_color(
    p,
    -1,
    if self.run.get().character == Warden {
      0x79CEC8
    } else {
      0xC98A65
    },
  )
  let nodes : Array[@scene.SceneNode] = [
    fit_text("name", r.w / 2.0, 13.0, p.name, r.w - 12.0, scale=0.7, color=cyan),
    ui_meter(
      "hp_bar",
      10.0,
      r.h - 23.0,
      r.w - 20.0,
      self.shown_hp(p, -1),
      p.max_hp,
      0x86453D,
    ),
  ]
  if !compact {
    nodes.push(
      pixel_actor(
        "hero",
        r.w / 2.0 - (if r.h < 150.0 { 21.0 } else { 27.0 }) + pose.x,
        34.0 + pose.y,
        if r.h < 150.0 {
          42.0
        } else {
          54.0
        },
        hero_color,
        false,
        alpha=self.actor_alpha(p),
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
      pixel_actor(
        "hero",
        r.w / 2.0 - 7.0 + pose.x,
        22.0 + pose.y,
        14.0,
        hero_color,
        false,
        alpha=self.actor_alpha(p),
      ),
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
  ui_panel(
    "player",
    r,
    0x202E3E,
    if self.combat_focus is Some(Target(-1)) {
      gold
    } else {
      0x456277
    },
    nodes,
    focused=self.combat_focus is Some(Target(-1)),
  )
}

///|
fn Game::view_enemy(
  self : Game,
  enemy : Enemy,
  r : UiRect,
  index : Int,
  targeted : Bool,
  drop? : DropFeedback? = None,
) -> @scene.SceneNode {
  let unique_accent = match enemy.id {
    CinderDuelist => 0xFFA082
    GildedSentinel => gold
    HollowOracle => 0xCAB2FF
    _ => 0xB2829B
  }
  let intent = if enemy.fighter.is_dead() {
    "DEFEATED"
  } else {
    match self.shown_intent(enemy, index) {
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
  }
  let nodes : Array[@scene.SceneNode] = [
    fit_text(
      "name",
      r.w / 2.0,
      12.0,
      (if is_unique_enemy(enemy.id) { "U / " } else { "" }) + enemy.fighter.name,
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
      self.shown_hp(enemy.fighter, index),
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
  let pose = self.actor_pose(enemy.fighter, index)
  let show_drop_badge = drop is Some(_) && r.h >= 120.0
  // Reserve badge space without replacing the enemy on a compact battlefield.
  let body_space = if show_drop_badge {
    if r.h >= 130.0 {
      102.0
    } else {
      94.0
    }
  } else {
    72.0
  }
  let sprite_size = ui_min(48.0, ui_max(0.0, r.h - body_space))
  if sprite_size > 0.0 {
    nodes.push(
      pixel_actor(
        "foe",
        r.w / 2.0 - sprite_size / 2.0 + pose.x,
        if r.h >= 130.0 {
          48.0 + pose.y
        } else {
          40.0 + pose.y
        },
        sprite_size,
        self.actor_color(
          enemy.fighter,
          index,
          if enemy.fighter.status.vulnerable > 0 {
            0xE1997E
          } else {
            unique_accent
          },
        ),
        true,
        enemy=Some(enemy.id),
        alpha=self.actor_alpha(enemy.fighter),
      ),
    )
  }
  if show_drop_badge && drop is Some(feedback) {
    let width = ui_min(r.w - 16.0, 86.0)
    nodes.push(
      ui_drop_badge(
        "drop_badge_" + index.to_string(),
        "drop_badge_text_" + index.to_string(),
        { x: (r.w - width) / 2.0, y: r.h - 50.0, w: width, h: 14.0, },
        feedback,
        controller=self.combat_focus is Some(Target(_)),
      ),
    )
  }
  ui_panel(
    "enemy_body_" + index.to_string(),
    r,
    0x302A36,
    if drop is Some(feedback) {
      drop_feedback_color(feedback)
    } else if targeted {
      gold
    } else if is_unique_enemy(enemy.id) {
      unique_accent
    } else {
      0x806776
    },
    nodes,
    focused=self.combat_focus is Some(Target(target)) && target == index,
  )
}

///|
fn pixel_actor(
  key : String,
  x : Double,
  y : Double,
  size : Double,
  color : Int,
  monster : Bool,
  enemy? : EnemyId? = None,
  alpha? : Double = 1.0,
) -> @scene.SceneNode {
  let pattern = match enemy {
    Some(CinderDuelist) =>
      [
        "00011001", "00111101", "00011010", "01111110", "10111000", "00111100", "00100100",
        "01100110",
      ]
    Some(GildedSentinel) =>
      [
        "00111100", "01111110", "01011010", "11111111", "11111111", "01111110", "01100110",
        "11100111",
      ]
    Some(HollowOracle) =>
      [
        "00011000", "00111100", "01100110", "00111100", "01111110", "11011011", "01111110",
        "11111111",
      ]
    _ =>
      if monster {
        [
          "00100100", "01111110", "11011011", "11111111", "01111110", "00111100",
          "01100110", "11000011",
        ]
      } else {
        [
          "00111100", "00111100", "00011000", "01111110", "10111101", "00111100",
          "00100100", "01100110",
        ]
      }
  }
  let p = size / 8.0
  let nodes : Array[@scene.SceneNode] = []
  for row = 0; row < 8; row = row + 1 {
    for col = 0; col < 8; col = col + 1 {
      if pattern[row][col] == '1' {
        nodes.push(
          @scene.rect(
            x=col.to_double() * p,
            y=row.to_double() * p,
            w=p,
            h=p,
            fill=color,
            alpha~,
          ),
        )
      }
    }
  }
  @scene.rect(key~, x~, y~, w=size, h=size, alpha=0.0, children=nodes)
}

///|
fn view_reward(
  run : RunState,
  l : GameLayout,
  focused? : Int = -1,
) -> @scene.SceneNode {
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
      "+" +
      run.last_gold.to_string() +
      " GOLD" +
      run.last_relic.map(id => " / " + relic_def(id).name).unwrap_or(""),
      l.w - 32.0,
      scale=0.6,
      color=muted_ink,
    ),
    ui_button(
      "skip_reward",
      l.continue_rect(),
      "SKIP / S",
      accent=muted_ink,
      focused=focused == run.card_rewards.length(),
    ),
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
        focused == i,
        detailed=true,
        focused=focused == i,
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
fn view_deck(
  run : RunState,
  l : GameLayout,
  page : Int,
  focused_id? : Int = -1,
) -> @scene.SceneNode {
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
    ui_button(
      "deck_close",
      l.pile_close_rect(),
      "CLOSE / ESC",
      accent=cyan,
      focused=focused_id == pile_close_id,
      focusable=true,
    ),
    ui_button(
      "deck_next",
      deck_next_rect(l),
      "NEXT PAGE >",
      focused=focused_id == pile_next_id,
      focusable=true,
      focus_index=1,
    ),
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
