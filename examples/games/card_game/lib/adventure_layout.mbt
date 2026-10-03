///|
fn adventure_phase(phase : RunPhase) -> Bool {
  match phase {
    RouteMap | EventRoom | ShopRoom | CardRemoval | TreasureRoom => true
    _ => false
  }
}

///|
fn GameLayout::map_panel(self : GameLayout) -> UiRect {
  {
    x: 16.0,
    y: 104.0,
    w: self.w - (if self.w >= 720.0 { 248.0 } else { 32.0 }),
    h: self.h - 216.0,
  }
}

///|
fn GameLayout::map_rows(self : GameLayout) -> Int {
  ui_max(2, ui_min(7, (self.map_panel().h / 64.0).to_int()))
}

///|
fn Game::map_first_floor(self : Game) -> Int {
  let run = self.run.get()
  let act = run.route.unwrap().act
  let start = (act - 1) * 15 + 1
  let base = ui_max(start, run.floor)
  ui_min(start + 15 - self.layout.map_rows(), base + self.room_page)
}

///|
fn Game::map_node_rect(self : Game, node : RouteNode) -> UiRect {
  let panel = self.layout.map_panel()
  let width = ui_min(88.0, panel.w / 4.0 - 10.0)
  let step = (panel.h - 60.0) / (self.layout.map_rows() - 1).to_double()
  {
    x: panel.x + panel.w * (node.lane + 1).to_double() / 4.0 - width / 2.0,
    y: panel.y +
    panel.h -
    52.0 -
    (node.floor - self.map_first_floor()).to_double() * step,
    w: width,
    h: 44.0,
  }
}

///|
fn map_browse_rect(l : GameLayout, forward : Bool) -> UiRect {
  { x: if forward { l.w - 60.0 } else { 16.0 }, y: 62.0, w: 44.0, h: 36.0, }
}

///|
fn GameLayout::room_list_rect(
  self : GameLayout,
  index : Int,
  count : Int,
) -> UiRect {
  let width = ui_min(760.0, self.w - 32.0)
  let height = ui_min(
    98.0,
    (self.h - 204.0 - (count - 1).to_double() * 8.0) / count.to_double(),
  )
  {
    x: (self.w - width) / 2.0,
    y: 164.0 + index.to_double() * (height + 8.0),
    w: width,
    h: height,
  }
}

///|
fn GameLayout::shop_rect(self : GameLayout, index : Int, count : Int) -> UiRect {
  let cols = if self.w >= 600.0 { 3 } else { 2 }
  let rows = (count + cols - 1) / cols
  let width = ui_min(1000.0, self.w - 32.0)
  let tile_w = (width - (cols - 1).to_double() * 10.0) / cols.to_double()
  let height = ui_min(
    160.0,
    (self.h - 232.0 - (rows - 1).to_double() * 10.0) / rows.to_double(),
  )
  {
    x: (self.w - width) / 2.0 + (index % cols).to_double() * (tile_w + 10.0),
    y: 112.0 + (index / cols).to_double() * (height + 10.0),
    w: tile_w,
    h: height,
  }
}

///|
fn GameLayout::room_footer_rect(self : GameLayout, right : Bool) -> UiRect {
  let width = ui_min(760.0, self.w - 32.0)
  let half = (width - 12.0) / 2.0
  {
    x: (self.w - width) / 2.0 + (if right { half + 12.0 } else { 0.0 }),
    y: self.h - 88.0,
    w: half,
    h: 44.0,
  }
}

///|
fn Game::removal_page_size(self : Game) -> Int {
  if self.layout.w >= 720.0 {
    6
  } else {
    4
  }
}

///|
fn Game::room_choice_rect(self : Game, choice : RunChoice) -> UiRect {
  let l = self.layout
  let run = self.run.get()
  match choice.action {
    PickNode(id) => {
      for node in run.route.unwrap().nodes {
        if node.id == id {
          return self.map_node_rect(node)
        }
      }
      { x: -100.0, y: -100.0, w: 0.0, h: 0.0, }
    }
    ResolveEvent(index) =>
      l.room_list_rect(index, event_options(run.event.unwrap()).length())
    BuyShop(index) => l.shop_rect(index, run.shop.unwrap().offers.length())
    OpenCardRemoval => l.room_footer_rect(false)
    LeaveShop | CancelRemoval => l.room_footer_rect(true)
    RemoveDeckCard(index) =>
      l.shop_rect(index % self.removal_page_size(), self.removal_page_size())
    TakeRelic(index) => l.room_list_rect(index, run.treasure_rewards.length())
  }
}
