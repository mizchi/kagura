///|
fn Game::view_pile(self : Game) -> @scene.SceneNode {
  guard self.popup is Some(kind) else { return @scene.fragment([]) }
  let l = self.layout
  let r = l.pile_modal_rect()
  let focused = self.modals
    .current()
    .map(m => m.focused.value)
    .unwrap_or(pile_close_id)
  let nodes = [
    @scene.rect_outline(
      x=r.x + 1.0,
      y=r.y + 1.0,
      w=r.w - 2.0,
      h=r.h - 2.0,
      line_width=2.0,
      color=cyan,
    ),
  ]
  if kind == Deck {
    nodes.push(
      view_deck(self.run.get(), l, self.popup_page, focused_id=focused),
    )
  } else {
    let cards = self.pile_cards(kind)
    let columns = if l.w < 400.0 { 2 } else { 4 }
    let rows = if l.h < 480.0 { 1 } else { 2 }
    let width = ui_min(
      120.0,
      (l.w - 56.0 - (columns - 1).to_double() * 8.0) / columns.to_double(),
    )
    let height = ui_min(
      150.0,
      (l.h - 219.0 - (rows - 1).to_double() * 8.0) / rows.to_double(),
    )
    let start = self.popup_page * l.pile_page_size()
    let grid_width = columns.to_double() * (width + 8.0) - 8.0
    nodes.push(
      fit_text(
        "pile_title",
        l.w / 2.0,
        88.0,
        if kind == Draw {
          "DRAW PILE"
        } else {
          "DISCARD PILE"
        },
        l.w - 48.0,
        scale=1.15,
        color=gold,
      ),
    )
    nodes.push(
      fit_text(
        "pile_count",
        l.w / 2.0,
        108.0,
        cards.length().to_string() +
        " CARDS / PAGE " +
        (self.popup_page + 1).to_string() +
        "/" +
        self.pile_pages().to_string(),
        l.w - 48.0,
        scale=0.55,
        color=cyan,
      ),
    )
    if cards.is_empty() {
      nodes.push(
        fit_text(
          "pile_empty",
          l.w / 2.0,
          l.h / 2.0,
          "NO CARDS IN THIS PILE",
          l.w - 56.0,
          scale=0.8,
          color=muted_ink,
        ),
      )
    }
    for i = 0; i < l.pile_page_size() && start + i < cards.length(); i = i + 1 {
      let rect : UiRect = {
        x: (l.w - grid_width) / 2.0 + (i % columns).to_double() * (width + 8.0),
        y: 125.0 + (i / columns).to_double() * (height + 8.0),
        w: width,
        h: height,
      }
      let card = cards[start + i]
      nodes.push(
        ui_card(
          "pile_frame_" + i.to_string(),
          rect,
          card,
          card_def(card).cost,
          true,
          false,
          interactive=false,
        ),
      )
    }
    nodes.push(
      ui_button(
        "pile_close",
        l.pile_close_rect(),
        "CLOSE / B",
        accent=cyan,
        focused=focused == pile_close_id,
        focusable=true,
      ),
    )
    nodes.push(
      ui_button(
        "pile_next",
        deck_next_rect(l),
        "NEXT PAGE >",
        focused=focused == pile_next_id,
        focusable=true,
        focus_index=1,
      ),
    )
  }
  @scene.fragment([
    @scene.rect(w=l.w, h=l.h, fill=0x000000, alpha=0.8),
    @scene.ui_key(
      "pile_modal",
      @scene.rect(
        key="pile_modal",
        x=r.x,
        y=r.y,
        w=r.w,
        h=r.h,
        fill=0x10151C,
        role="dialog",
        children=[@scene.group(x=-r.x, y=-r.y, children=nodes)],
      ),
    ),
    fit_text(
      "pile_controls",
      l.w / 2.0,
      l.h - 10.0,
      "LEFT RIGHT: PAGE / TAB: CONTROL / B ESC: CLOSE",
      l.w - 24.0,
      scale=0.5,
      color=cyan,
    ),
  ])
}
