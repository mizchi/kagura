///|
/// Normalize mouse and touch once; retain one finger until its release.
/// Does not query a DOM, scale coordinates, or depend on a game input helper.
pub struct UIPointerInputAdapter {
  keys : @inputstate.KeyInputState
  mouse : @inputstate.MouseButtonInputState
  touches : @inputstate.TouchInputState
  mut owned_touch : Int?
  mut frame : UIPointerFrame
}

///|
pub fn UIPointerInputAdapter::new() -> UIPointerInputAdapter {
  {
    keys: @inputstate.new_key_input_state(),
    mouse: @inputstate.new_mouse_input_state(),
    touches: @inputstate.new_touch_input_state(),
    owned_touch: None,
    frame: {
      pointer: Mouse,
      x: -1.0,
      y: -1.0,
      pressed: false,
      released: false,
      down: false,
      cancelled: false,
    },
  }
}

///|
pub fn UIPointerInputAdapter::pointer(
  self : UIPointerInputAdapter,
) -> UIPointerFrame {
  self.frame
}

///|
pub impl UIInputAdapter for UIPointerInputAdapter with fn from_input_snapshot(
  self,
  input,
) {
  @inputstate.update_key_input_state(self.keys, input)
  @inputstate.update_mouse_input_state(self.mouse, input)
  @inputstate.update_touch_input_state(self.touches, input)
  let previous = self.frame
  let cancelled = @inputstate.is_key_just_pressed(self.keys, 27) ||
    @inputstate.is_key_just_pressed(self.keys, 256) ||
    @inputstate.is_mouse_button_just_pressed(self.mouse, 1) ||
    @inputstate.is_mouse_button_just_pressed(self.mouse, 2)
  let frame = if cancelled {
    self.owned_touch = None
    {
      ..previous,
      pressed: false,
      released: false,
      down: false,
      cancelled: true,
    }
  } else if self.owned_touch is Some(id) {
    let mut owned : @core.TouchPoint? = None
    for touch in input.touches {
      if touch.id == id {
        owned = Some(touch)
      }
    }
    match owned {
      Some(touch) =>
        {
          pointer: Touch(id),
          x: touch.x,
          y: touch.y,
          pressed: false,
          released: false,
          down: true,
          cancelled: false,
        }
      None => {
        self.owned_touch = None
        {
          ..previous,
          pointer: Touch(id),
          pressed: false,
          released: true,
          down: false,
          cancelled: false,
        }
      }
    }
  } else {
    let mouse_captured = previous.pointer == Mouse && previous.down
    let mut new_touch : @core.TouchPoint? = None
    for touch in input.touches {
      if !mouse_captured &&
        new_touch is None &&
        @inputstate.is_touch_just_pressed(self.touches, touch.id) {
        new_touch = Some(touch)
      }
    }
    match new_touch {
      Some(touch) => {
        self.owned_touch = Some(touch.id)
        {
          pointer: Touch(touch.id),
          x: touch.x,
          y: touch.y,
          pressed: true,
          released: false,
          down: true,
          cancelled: false,
        }
      }
      None => {
        let sampled = input.cursor_x != -1.0 || input.cursor_y != -1.0
        // A remaining finger cannot take over a released/cancelled gesture.
        let mouse_available = input.touches.length() == 0 || mouse_captured
        {
          pointer: Mouse,
          x: if sampled && mouse_available {
            input.cursor_x
          } else {
            previous.x
          },
          y: if sampled && mouse_available {
            input.cursor_y
          } else {
            previous.y
          },
          pressed: mouse_available &&
          @inputstate.is_mouse_button_just_pressed(self.mouse, 0),
          released: mouse_available &&
          @inputstate.is_mouse_button_just_released(self.mouse, 0),
          down: mouse_available &&
          @inputstate.is_mouse_button_pressed(self.mouse, 0),
          cancelled: false,
        }
      }
    }
  }
  self.frame = frame
  let events : Array[UIEvent] = []
  for key in @inputstate.append_just_pressed_keys(self.keys, []) {
    events.push(KeyDown(key))
  }
  for key in @inputstate.append_just_released_keys(self.keys, []) {
    events.push(KeyUp(key))
  }
  if cancelled {
    events.push(PointerCancel)
  } else {
    if frame.x != previous.x || frame.y != previous.y {
      events.push(PointerMove(frame.x, frame.y))
    }
    if frame.pressed {
      events.push(PointerDown(frame.x, frame.y))
    }
    if frame.released {
      events.push(PointerUp(frame.x, frame.y))
    }
  }
  if input.wheel_x != 0.0 || input.wheel_y != 0.0 {
    events.push(Scroll(input.wheel_x, input.wheel_y))
  }
  events
}

///|
pub extend UIPointerInputAdapter with UIInputAdapter::{from_input_snapshot}
