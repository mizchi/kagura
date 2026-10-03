///|
fn room_symbol(kind : RoomKind) -> String {
  match kind {
    RoomBattle => "X"
    RoomElite => "E"
    RoomUnique => "U"
    RoomBoss => "B"
    RoomRest => "R"
    RoomEvent => "?"
    RoomShop => "$"
    RoomTreasure => "T"
  }
}

///|
fn room_color(kind : RoomKind) -> Int {
  match kind {
    RoomElite | RoomBoss => 0xFFB0A5
    RoomUnique => 0xCAB2FF
    RoomRest => cyan
    _ => gold
  }
}

///|
fn Game::choice_focused(self : Game, id : String) -> Bool {
  let choices = run_choices(self.run.get())
  self.combat_focus is None &&
  self.scene_focus < choices.length() &&
  choices[self.scene_focus].id == id
}

///|
fn room_option(
  key : String,
  rect : UiRect,
  label : String,
  detail : String,
  enabled : Bool,
  focused : Bool,
  accent : Int,
) -> @scene.SceneNode {
  let color = if enabled { accent } else { 0xA0ADBF }
  let children = [
    fit_text(
      "name",
      rect.w / 2.0,
      if rect.h < 70.0 {
        12.0
      } else {
        20.0
      },
      label,
      rect.w - 20.0,
      scale=0.75,
      color~,
    ),
    if rect.h < 70.0 {
      fit_text(
        "detail",
        rect.w / 2.0,
        rect.h - 14.0,
        render_copy(detail),
        rect.w - 24.0,
        scale=0.5,
        color=muted_ink,
      )
    } else {
      copy_lines(
        "detail_",
        render_copy(detail),
        rect.w / 2.0,
        44.0,
        rect.w - 24.0,
        0.5,
        muted_ink,
      )
    },
  ]
  if focused {
    children.push(
      @scene.rect_outline(
        x=3.0,
        y=3.0,
        w=rect.w - 6.0,
        h=rect.h - 6.0,
        color=gold,
        line_width=2.0,
      ),
    )
  }
  ui_panel(
    key,
    rect,
    if focused {
      0x4C3825
    } else if enabled {
      0x222C3B
    } else {
      0x1C2430
    },
    color,
    children,
    role=if enabled { "button" } else { "rect" },
    focusable=enabled,
    focused~,
  )
}

///|
fn Game::view_adventure(self : Game) -> @scene.SceneNode {
  let run = self.run.get()
  if run.phase == RouteMap {
    return self.view_branch_map()
  }
  let l = self.layout
  let title = match run.phase {
    EventRoom => event_title(run.event.unwrap())
    ShopRoom => "THE ASHEN MARKET"
    CardRemoval => "REMOVE A CARD"
    TreasureRoom => "THE RELIC VAULT"
    _ => ""
  }
  let nodes : Array[@scene.SceneNode] = [
    fit_text(
      "room_title",
      l.w / 2.0,
      82.0,
      title,
      l.w - 128.0,
      scale=1.05,
      color=gold,
    ),
    fit_text(
      "room_controls",
      l.w / 2.0,
      l.h - 20.0,
      "DIRECTIONS TO SELECT / CONFIRM / D FOR DECK",
      l.w - 32.0,
      scale=0.5,
      color=muted_ink,
    ),
  ]
  match run.phase {
    EventRoom => {
      nodes.push(
        copy_lines(
          "event_story_",
          event_copy(run.event.unwrap()),
          l.w / 2.0,
          114.0,
          ui_min(760.0, l.w - 40.0),
          0.5,
          muted_ink,
        ),
      )
      let options = event_options(run.event.unwrap())
      for index, option in options {
        let id = "event:\{index}"
        let enabled = event_option_enabled(run, option)
        nodes.push(
          room_option(
            "event_\{index}",
            l.room_list_rect(index, options.length()),
            option.label + (if enabled { "" } else { " / UNAVAILABLE" }),
            option.detail,
            enabled,
            self.choice_focused(id),
            cyan,
          ),
        )
      }
    }
    TreasureRoom => {
      nodes.push(
        fit_text(
          "treasure_hint",
          l.w / 2.0,
          120.0,
          "CHOOSE ONE RELIC / ITS EFFECT LASTS FOR THIS RUN",
          l.w - 32.0,
          scale=0.55,
          color=muted_ink,
        ),
      )
      for index, relic in run.treasure_rewards {
        nodes.push(
          room_option(
            "relic_\{index}",
            l.room_list_rect(index, run.treasure_rewards.length()),
            relic_def(relic).name,
            relic_def(relic).description,
            true,
            self.choice_focused("relic:\{index}"),
            gold,
          ),
        )
      }
    }
    ShopRoom => {
      for index, offer in run.shop.unwrap().offers {
        let enabled = shop_offer_enabled(run, offer)
        let rect = l.shop_rect(index, run.shop.unwrap().offers.length())
        let focused = self.choice_focused("buy:\{index}")
        let color = if offer.sold { muted_ink } else { gold }
        let detail = match offer.item {
          ShopCard(card) => short_desc(card_def(card))
          _ => render_copy(shop_item_detail(offer.item))
        }
        let children : Array[@scene.SceneNode] = [
          fit_text(
            "name",
            rect.w / 2.0,
            15.0,
            shop_item_name(offer.item),
            rect.w - 16.0,
            scale=0.7,
            color~,
          ),
          if rect.h >= 90.0 {
            copy_lines(
              "detail_",
              detail,
              rect.w / 2.0,
              43.0,
              rect.w - 20.0,
              0.5,
              muted_ink,
            )
          } else {
            fit_text(
              "detail",
              rect.w / 2.0,
              31.0,
              detail,
              rect.w - 16.0,
              scale=0.4,
              color=muted_ink,
            )
          },
          fit_text(
            "price",
            rect.w / 2.0,
            rect.h - 14.0,
            if offer.sold {
              "SOLD"
            } else {
              "\{shop_price(run, offer.price)} GOLD" +
              (if enabled { "" } else { " / LOCKED" })
            },
            rect.w - 16.0,
            scale=0.65,
            color~,
          ),
        ]
        if focused {
          children.push(
            @scene.rect_outline(
              x=3.0,
              y=3.0,
              w=rect.w - 6.0,
              h=rect.h - 6.0,
              color=gold,
              line_width=2.0,
            ),
          )
        }
        nodes.push(
          ui_panel(
            "shop_\{index}",
            rect,
            if focused {
              0x4C3825
            } else {
              0x222C3B
            },
            if enabled {
              gold
            } else {
              0xA0ADBF
            },
            children,
            role=if enabled { "button" } else { "rect" },
            focusable=enabled,
            focused~,
          ),
        )
      }
      let removable = run_choices(run).any(c => c.id == "remove_card")
      nodes.push(
        ui_button(
          "remove_card",
          l.room_footer_rect(false),
          "REMOVE / \{card_removal_price(run)} GOLD",
          accent=if removable { cyan } else { muted_ink },
          focused=self.choice_focused("remove_card"),
          focusable=removable,
        ),
      )
      nodes.push(
        ui_button(
          "leave_shop",
          l.room_footer_rect(true),
          "LEAVE SHOP",
          focused=self.choice_focused("leave_shop"),
          focusable=true,
        ),
      )
      let choices = run_choices(run)
      if !choices.is_empty() {
        nodes.push(
          fit_text(
            "shop_selection",
            l.w / 2.0,
            l.h - 106.0,
            render_copy(choices[self.scene_focus % choices.length()].label),
            l.w - 32.0,
            scale=0.45,
            color=muted_ink,
          ),
        )
      }
    }
    CardRemoval => {
      let size = self.removal_page_size()
      let pages = (run.deck.length() + size - 1) / size
      nodes.push(
        fit_text(
          "removal_cost",
          l.w / 2.0,
          100.0,
          "\{card_removal_price(run)} GOLD / PAGE \{self.room_page + 1}/\{pages}",
          l.w - 128.0,
          scale=0.5,
          color=cyan,
        ),
      )
      for forward in [false, true] {
        nodes.push(
          ui_button(
            if forward {
              "removal_next"
            } else {
              "removal_prev"
            },
            map_browse_rect(l, forward),
            if forward {
              ">"
            } else {
              "<"
            },
          ),
        )
      }
      for slot in 0..<size {
        let index = self.room_page * size + slot
        if index >= run.deck.length() {
          break
        }
        let card = run.deck[index]
        nodes.push(
          room_option(
            "remove_\{index}",
            l.shop_rect(slot, size),
            card_def(card).name,
            short_desc(card_def(card)),
            true,
            self.choice_focused("remove:\{index}"),
            card_accent(card),
          ),
        )
      }
      nodes.push(
        ui_button(
          "cancel_removal",
          l.room_footer_rect(true),
          "CANCEL",
          focused=self.choice_focused("cancel_removal"),
          focusable=true,
        ),
      )
    }
    _ => ()
  }
  @scene.fragment(nodes)
}

///|
fn Game::view_branch_map(self : Game) -> @scene.SceneNode {
  let run = self.run.get()
  let route = run.route.unwrap()
  let l = self.layout
  let panel = l.map_panel()
  let first = self.map_first_floor()
  let last = first + l.map_rows() - 1
  let available = available_rooms(run)
  let visible = route.nodes.filter(n => n.floor >= first && n.floor <= last)
  let nodes : Array[@scene.SceneNode] = [
    ui_panel("branch_map", panel, 0xC8BB95, 0x74664D, []),
    fit_text(
      "map_title",
      l.w / 2.0,
      80.0,
      "ACT \{route.act} / FLOORS \{first}-\{last}",
      l.w - 144.0,
      scale=0.85,
      color=gold,
    ),
    ui_button("map_prev", map_browse_rect(l, false), "<", accent=cyan),
    ui_button("map_next", map_browse_rect(l, true), ">", accent=cyan),
  ]
  for node in visible {
    let source = self.map_node_rect(node)
    for target in visible {
      if node.next.contains(target.id) {
        let dest = self.map_node_rect(target)
        let active = route.current == Some(node.id) &&
          available.any(n => n.id == target.id)
        let visited = route.visited.contains(node.id) &&
          route.visited.contains(target.id)
        // Dashes keep crossing paths readable on the parchment.
        for dash in 0..<8 {
          let t0 = dash.to_double() / 8.0
          let t1 = t0 + 0.065
          let sx = source.x + source.w / 2.0
          let sy = source.y + source.h / 2.0
          let dx = dest.x + dest.w / 2.0 - sx
          let dy = dest.y + dest.h / 2.0 - sy
          nodes.push(
            @scene.line(
              x0=sx + dx * t0,
              y0=sy + dy * t0,
              x1=sx + dx * t1,
              y1=sy + dy * t1,
              width=if active { 2.5 } else { 1.5 },
              color=if active {
                0x70512D
              } else if visited {
                0x267C70
              } else {
                0x96896A
              },
            ),
          )
        }
      }
    }
  }
  for node in visible {
    let enabled = available.any(n => n.id == node.id)
    let current = route.current == Some(node.id)
    let visited = route.visited.contains(node.id)
    let focused = enabled && self.choice_focused("node:\{node.id}")
    let rect = self.map_node_rect(node)
    nodes.push(
      ui_panel(
        "map_node_\{node.id}",
        rect,
        if current {
          0x1C2430
        } else if focused {
          0x4C3825
        } else if enabled {
          0x253044
        } else if visited {
          0x9BA68A
        } else {
          0xC8BB95
        },
        if current {
          cyan
        } else if focused {
          gold
        } else if enabled {
          cyan
        } else {
          0x74664D
        },
        [
          fit_text(
            "symbol",
            rect.w / 2.0,
            rect.h * 0.30,
            (if current { "> " } else { "" }) + room_symbol(node.kind),
            rect.w - 12.0,
            scale=0.85,
            color=if current {
              cyan
            } else if enabled {
              room_color(node.kind)
            } else {
              0x30291D
            },
          ),
          fit_text(
            "name",
            rect.w / 2.0,
            rect.h * 0.75,
            if current {
              "HERE \{node.floor}"
            } else if visited {
              "DONE"
            } else {
              room_name(node.kind)
            },
            rect.w - 10.0,
            scale=0.42,
            color=if current || enabled { ink } else { 0x30291D },
          ),
          if current {
            @scene.rect_outline(
              x=3.0,
              y=3.0,
              w=rect.w - 6.0,
              h=rect.h - 6.0,
              color=cyan,
              line_width=2.0,
            )
          } else {
            @scene.fragment([])
          },
        ],
        role=if enabled { "button" } else { "rect" },
        focusable=enabled,
        focused~,
      ),
    )
  }
  if l.w >= 720.0 {
    let x = panel.x + panel.w + 16.0
    let width = l.w - x - 16.0
    let height = ui_min(panel.h, 350.0)
    let children : Array[@scene.SceneNode] = [
      fit_text(
        "title",
        width / 2.0,
        20.0,
        "MAP LEGEND",
        width - 20.0,
        scale=0.7,
        color=gold,
      ),
    ]
    for
      index, kind in [
        RoomBattle,
        RoomElite,
        RoomUnique,
        RoomBoss,
        RoomRest,
        RoomEvent,
        RoomShop,
        RoomTreasure,
      ] {
      children.push(
        fit_text(
          "kind_\{index}",
          width / 2.0,
          46.0 + index.to_double() * ((height - 62.0) / 7.0),
          room_symbol(kind) + "  " + room_name(kind),
          width - 20.0,
          scale=0.65,
          color=room_color(kind),
        ),
      )
    }
    nodes.push(
      ui_panel(
        "map_legend",
        { x, y: 104.0, w: width, h: height, },
        0x222C3B,
        muted_ink,
        children,
      ),
    )
  }
  let choices = run_choices(run)
  if !choices.is_empty() {
    let selected = available[self.scene_focus % choices.length()]
    nodes.push(
      fit_text(
        "map_selection",
        l.w / 2.0,
        l.h - 86.0,
        "NEXT: FLOOR \{selected.floor} / \{room_name(selected.kind)}",
        l.w - 32.0,
        scale=0.7,
        color=room_color(selected.kind),
      ),
    )
    nodes.push(
      copy_lines(
        "map_detail_",
        room_detail(selected.kind),
        l.w / 2.0,
        l.h - 61.0,
        l.w - 32.0,
        0.5,
        muted_ink,
      ),
    )
  }
  nodes.push(
    fit_text(
      "map_controls",
      l.w / 2.0,
      l.h - 20.0,
      if self.room_page != 0 {
        "CONFIRM TO RETURN TO NEXT NODES"
      } else {
        "CLICK A LIT NODE / DIRECTIONS + CONFIRM"
      },
      l.w - 32.0,
      scale=0.5,
      color=muted_ink,
    ),
  )
  @scene.fragment(nodes)
}
