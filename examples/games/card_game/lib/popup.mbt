///|
let pile_modal_id : Int = 5000

///|
let pile_close_id : Int = 5001

///|
let pile_next_id : Int = 5002

///|
fn pile_opener_id(kind : PileKind) -> Int {
  match kind {
    Deck => 3001
    Draw => 3002
    Discard => 3003
  }
}

///|
fn Game::open_pile(self : Game, kind : PileKind) -> Unit {
  if self.scene != Playing ||
    self.presentation is Some(_) ||
    self.popup is Some(_) {
    return
  }
  if kind != Deck &&
    !(self.run.get().phase == Battle &&
    self.run.get().battle is Some({ phase: PlayerTurn, .. })) {
    return
  }
  self.cancel_card()
  self.popup = Some(kind)
  self.popup_page = 0
  let _ = self.modals.open(
    @ui.UINodeId::new(pile_modal_id),
    opener=Some(@ui.UINodeId::new(pile_opener_id(kind))),
    focusable=[
      @ui.UINodeId::new(pile_close_id),
      @ui.UINodeId::new(pile_next_id),
    ],
  )
}

///|
fn Game::close_pile(self : Game, reason : @ui.UIModalCloseReason) -> Unit {
  if self.modals.close(reason) is Some(closed) {
    self.combat_focus = closed.restore_focus.bind(id => {
      match id.value {
        3001 => Some(DeckButton)
        3002 => Some(DrawPile)
        3003 => Some(DiscardPile)
        _ => None
      }
    })
  }
  self.popup = None
  self.hint = "ARROWS: CONTROL / A OR ENTER: CONFIRM"
}

///|
fn GameLayout::draw_pile_rect(self : GameLayout) -> UiRect {
  let x = if self.w < 400.0 { 128.0 } else { 154.0 }
  {
    x,
    y: self.command_y,
    w: ui_min(72.0, (self.w - 116.0 - x - 16.0) / 2.0),
    h: 44.0,
  }
}

///|
fn GameLayout::discard_pile_rect(self : GameLayout) -> UiRect {
  let draw = self.draw_pile_rect()
  { ..draw, x: draw.x + draw.w + 8.0, }
}

///|
fn Game::pile_cards(self : Game, kind : PileKind) -> Array[CardId] {
  let run = self.run.get()
  match kind {
    Deck => run.deck.copy()
    Draw => run.battle.map(b => b.draw_pile.copy()).unwrap_or([])
    Discard => run.battle.map(b => b.discard_pile.copy()).unwrap_or([])
  }
}

///|
fn GameLayout::pile_page_size(self : GameLayout) -> Int {
  (if self.w < 400.0 { 2 } else { 4 }) * (if self.h < 480.0 { 1 } else { 2 })
}

///|
fn Game::pile_pages(self : Game) -> Int {
  guard self.popup is Some(kind) else { return 1 }
  if kind == Deck {
    return deck_page_count(self.run.get())
  }
  let size = self.layout.pile_page_size()
  ui_max(1, (self.pile_cards(kind).length() + size - 1) / size)
}

///|
fn Game::turn_pile_page(self : Game, direction : Int) -> Unit {
  let pages = self.pile_pages()
  self.popup_page = (self.popup_page + pages + direction) % pages
}

///|
fn Game::update_pile(
  self : Game,
  navigation : Array[@ui.UINavigationEvent],
  pressed : Bool,
) -> Unit {
  let toggle_key = match self.popup {
    Some(Deck) => 68
    Some(Draw) => 81
    Some(Discard) => 82
    None => -1
  }
  if @inputstate.is_key_just_pressed(self.input.key_state, toggle_key) ||
    @inputstate.is_mouse_button_just_pressed(self.input.mouse_state, 1) {
    self.close_pile(@ui.UIModalCloseReason::Explicit)
    return
  }
  for event in navigation {
    match event {
      Cancel => {
        self.close_pile(@ui.UIModalCloseReason::Cancel)
        return
      }
      Move(Left) | Auxiliary(4) => self.turn_pile_page(-1)
      Move(Right) | Auxiliary(5) => self.turn_pile_page(1)
      Move(Up) => self.modals.cycle(-1)
      Move(Down) => self.modals.cycle(1)
      Confirm => {
        if self.modals.current().unwrap().focused.value == pile_next_id {
          self.turn_pile_page(1)
        } else {
          self.close_pile(@ui.UIModalCloseReason::Explicit)
        }
        return
      }
      _ => ()
    }
  }
  if @inputstate.is_key_just_pressed(self.input.key_state, 9) ||
    @inputstate.is_key_just_pressed(self.input.key_state, 258) {
    self.modals.cycle(
      if @inputstate.is_key_pressed(self.input.key_state, 16) ||
        @inputstate.is_key_pressed(self.input.key_state, 340) ||
        @inputstate.is_key_pressed(self.input.key_state, 344) {
        -1
      } else {
        1
      },
    )
  }
  if pressed {
    if self.layout.pile_close_rect().contains(self.cursor_x, self.cursor_y) {
      self.close_pile(@ui.UIModalCloseReason::Explicit)
    } else if deck_next_rect(self.layout).contains(self.cursor_x, self.cursor_y) {
      self.turn_pile_page(1)
      let _ = self.modals.focus(@ui.UINodeId::new(pile_next_id))
    } else if !self.layout
      .pile_modal_rect()
      .contains(self.cursor_x, self.cursor_y) {
      self.close_pile(@ui.UIModalCloseReason::Backdrop)
    }
  }
}

///|
fn GameLayout::pile_modal_rect(self : GameLayout) -> UiRect {
  { x: 12.0, y: 64.0, w: self.w - 24.0, h: self.h - 88.0, }
}

///|
fn GameLayout::pile_close_rect(self : GameLayout) -> UiRect {
  {
    x: 28.0,
    y: self.h - 72.0,
    w: ui_min(168.0, (self.w - 72.0) / 2.0),
    h: 44.0,
  }
}
