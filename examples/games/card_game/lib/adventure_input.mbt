///|
fn Game::browse_map(self : Game, forward : Bool) -> Unit {
  let start = (self.run.get().route.unwrap().act - 1) * 15 + 1
  let base = ui_max(start, self.run.get().floor)
  let maximum = ui_max(0, start + 15 - self.layout.map_rows() - base)
  self.room_page = ui_max(
    start - base,
    ui_min(maximum, self.room_page + (if forward { 1 } else { -1 })),
  )
}

///|
fn Game::update_adventure(
  self : Game,
  navigation : Array[@ui.UINavigationEvent],
  pressed : Bool,
) -> Unit {
  let run = self.run.get()
  let choices = run_choices(run)
  if choices.is_empty() {
    return
  }
  self.scene_focus %= choices.length()
  for event in navigation {
    match event {
      Move(Left | Up) => {
        self.scene_focus = (self.scene_focus + choices.length() - 1) %
          choices.length()
        if run.phase == RouteMap {
          self.room_page = 0
        }
      }
      Move(Right | Down) => {
        self.scene_focus = (self.scene_focus + 1) % choices.length()
        if run.phase == RouteMap {
          self.room_page = 0
        }
      }
      Confirm => {
        if run.phase == RouteMap && self.room_page != 0 {
          self.room_page = 0
          return
        }
        self.travel(AdventureChoice(choices[self.scene_focus].id))
        return
      }
      Auxiliary(4 | 5) =>
        if run.phase == RouteMap {
          self.browse_map(event is Auxiliary(5))
          return
        }
      Cancel => {
        if run.phase == ShopRoom {
          self.travel(AdventureChoice("leave_shop"))
        }
        if run.phase == CardRemoval {
          self.travel(AdventureChoice("cancel_removal"))
        }
        return
      }
      _ => ()
    }
  }
  if run.phase == CardRemoval &&
    choices[self.scene_focus].action is RemoveDeckCard(index) {
    self.room_page = index / self.removal_page_size()
  }
  if !pressed {
    return
  }
  if run.phase == RouteMap {
    for forward in [false, true] {
      if map_browse_rect(self.layout, forward).contains(
          self.cursor_x,
          self.cursor_y,
        ) {
        self.browse_map(forward)
        return
      }
    }
  }
  if run.phase == CardRemoval {
    for forward in [false, true] {
      if map_browse_rect(self.layout, forward).contains(
          self.cursor_x,
          self.cursor_y,
        ) {
        let pages = (run.deck.length() + self.removal_page_size() - 1) /
          self.removal_page_size()
        self.room_page = (
            self.room_page + pages + (if forward { 1 } else { -1 })
          ) %
          pages
        self.scene_focus = self.room_page * self.removal_page_size()
        return
      }
    }
  }
  for index, choice in choices {
    if choice.action is RemoveDeckCard(card) &&
      card / self.removal_page_size() != self.room_page {
      continue
    }
    if choice.action is PickNode(node) &&
      !self.run.get().route.unwrap().nodes.any(n => {
        n.id == node &&
        n.floor >= self.map_first_floor() &&
        n.floor < self.map_first_floor() + self.layout.map_rows()
      }) {
      continue
    }
    if self.room_choice_rect(choice).contains(self.cursor_x, self.cursor_y) {
      self.scene_focus = index
      self.travel(AdventureChoice(choice.id))
      return
    }
  }
}
