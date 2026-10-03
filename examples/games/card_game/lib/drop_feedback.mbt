///|
/// Geometry and acceptance shared by drop recognition and its visual guidance.
priv struct CardDropTarget {
  id : @ui.UINodeId
  rect : UiRect
}

///|
priv enum DropFeedback {
  Available
  Active
}

///|
fn Game::card_drop_targets(
  self : Game,
  source : @ui.UINodeId,
) -> Array[CardDropTarget] {
  let run = self.run.get()
  if self.scene != Playing ||
    self.popup is Some(_) ||
    run.phase != Battle ||
    self.presentation is Some(_) {
    return []
  }
  guard run.battle is Some(state) else { return [] }
  if state.phase != PlayerTurn || !can_play_card(state, source.value) {
    return []
  }
  if !card_needs_target(state.hand[source.value]) {
    return [
      {
        id: @ui.UINodeId::new(battlefield_drag_id),
        rect: self.layout.play_area(),
      },
    ]
  }
  let targets = []
  for index in 0..<state.enemies.length() {
    if !state.enemies[index].fighter.is_dead() {
      targets.push({
        id: @ui.UINodeId::new(enemy_drag_id_base + index),
        rect: self.layout.enemy_rect(index, state.enemies.length()),
      })
    }
  }
  targets
}

///|
fn drop_feedback_color(feedback : DropFeedback) -> Int {
  match feedback {
    Available => cyan
    Active => gold
  }
}

///|
/// A border plus corner brackets; active targets change shape and color.
fn ui_drop_zone(
  key : String,
  rect : UiRect,
  feedback : DropFeedback,
) -> @scene.SceneNode {
  let accent = drop_feedback_color(feedback)
  let active = feedback is Active
  let length = ui_min(
    if active {
      18.0
    } else {
      12.0
    },
    ui_min(rect.w, rect.h) / 3.0,
  )
  let stroke = if active { 4.0 } else { 2.0 }
  let nodes = [
    @scene.rect_outline(
      key~,
      x=rect.x,
      y=rect.y,
      w=rect.w,
      h=rect.h,
      line_width=stroke,
      color=accent,
    ),
  ]
  for corner in 0..<4 {
    let right = corner % 2 == 1
    let bottom = corner >= 2
    let x = if right { rect.x + rect.w - length - 2.0 } else { rect.x + 2.0 }
    let y = if bottom { rect.y + rect.h - length - 2.0 } else { rect.y + 2.0 }
    nodes.push(
      @scene.rect(
        x~,
        y=if bottom { y + length - stroke } else { y },
        w=length,
        h=stroke,
        fill=accent,
      ),
    )
    nodes.push(
      @scene.rect(
        x=if right { x + length - stroke } else { x },
        y~,
        w=stroke,
        h=length,
        fill=accent,
      ),
    )
  }
  @scene.fragment(nodes)
}

///|
fn ui_drop_badge(
  key : String,
  text_key : String,
  rect : UiRect,
  feedback : DropFeedback,
  controller? : Bool = false,
) -> @scene.SceneNode {
  let accent = drop_feedback_color(feedback)
  ui_panel(key, rect, 0x10151C, accent, [
    fit_text(
      text_key,
      rect.w / 2.0,
      rect.h / 2.0,
      if feedback is Active {
        if controller {
          "CONFIRM"
        } else {
          "RELEASE"
        }
      } else if controller {
        "TARGET"
      } else {
        "DROP"
      },
      rect.w - 8.0,
      scale=0.55,
      color=accent,
    ),
  ])
}

///|
fn drag_feedback_hint(
  targets : Array[CardDropTarget],
  target : @ui.UINodeId?,
) -> String {
  if targets.is_empty() {
    "CANNOT PLAY THIS CARD"
  } else if targets.any(t => Some(t.id) == target) {
    "RELEASE TO PLAY"
  } else if targets[0].id.value == battlefield_drag_id {
    "MOVE INTO THE BATTLEFIELD"
  } else {
    "MOVE TO A HIGHLIGHTED ENEMY"
  }
}
