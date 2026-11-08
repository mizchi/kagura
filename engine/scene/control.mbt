///|
/// A renderer-independent control body. Contents and availability rules belong
/// to the application; the common visual state also drives snapshot semantics.
pub fn control_panel(
  id : String,
  bounds : @kagura_ui.LayoutRect,
  state : @kagura_ui.UIInteractionState,
  fill~ : Int32,
  border~ : Int32,
  available_color~ : Int32 = 0x83E8CB,
  selected_color~ : Int32 = 0xF2D49A,
  children~ : Array[SceneNode],
) -> SceneNode {
  let stroke = if state.selected {
    3.0
  } else if state.available {
    2.0
  } else {
    1.0
  }
  let accent = if state.selected {
    selected_color
  } else if state.available {
    available_color
  } else {
    border
  }
  ui_key(
    id,
    rect(
      key=id,
      x=bounds.x,
      y=bounds.y,
      w=bounds.width,
      h=bounds.height,
      fill~,
      interaction=state,
      focused=state.selected,
      children=[
        rect_outline(
          x=stroke / 2.0,
          y=stroke / 2.0,
          w=bounds.width - stroke,
          h=bounds.height - stroke,
          color=accent,
          line_width=stroke,
        ),
        if state.available {
          ui_key(
            id + "_actionable",
            rect(
              x=2.0,
              y=bounds.height - 3.0,
              w=bounds.width - 4.0,
              h=2.0,
              fill=accent,
            ),
          )
        } else {
          fragment([])
        },
        ..children,
      ],
    ),
  )
}
