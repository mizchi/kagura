///|
/// Radial dead zone shared by virtual sticks and hardware gamepads.
pub fn stick_vector(
  dx : @core.Any,
  dy : @core.Any,
  radius : @core.Any,
  options : @core.Any,
) -> @core.Any {
  let dead_zone = argument(field(options, "deadZone"), @core.any(0.14))
  if !finite(dx) ||
    !finite(dy) ||
    !finite(radius) ||
    !finite(dead_zone) ||
    number(radius) <= 0 ||
    number(dead_zone) < 0 ||
    number(dead_zone) >= 1 {
    range_error(
      "Stick coordinates must be finite, radius positive, and deadZone in [0, 1)",
    )
  }
  let (x, y) = radial_stick(
    dx.cast(),
    dy.cast(),
    radius.cast(),
    dead_zone.cast(),
  )
  vector(x, y)
}

///|
fn radial_stick(
  dx : Double,
  dy : Double,
  radius : Double,
  dead_zone : Double,
) -> (Double, Double) {
  let length = @jsmath.Math::hypot([dx, dy])
  if length == 0 || length < radius * dead_zone {
    return (0, 0)
  }
  let magnitude = ((length / radius - dead_zone) / (1 - dead_zone)).min(1)
  (dx / length * magnitude, dy / length * magnitude)
}

///|
priv struct ControlState {
  capacity : Double
  held : Array[(Double, @core.Any)]
  commands : Array[@core.Any]
  mut owner : Double?
  mut x : Double
  mut y : Double
  mut release_pending : Bool
}

///|
fn ControlState::release(self : ControlState, id : Double) -> Unit {
  for i = self.held.length() - 1; i >= 0; i = i - 1 {
    if self.held[i].0 == id {
      self.held.remove(i) |> ignore
    }
  }
  if self.owner == Some(id) {
    self.owner = None
    self.x = 0
    self.y = 0
  }
}

///|
pub fn create_control_input(options : @core.Any) -> @core.Any {
  let capacity = argument(field(options, "capacity"), @core.any(8))
  if !safe_integer(capacity) || number(capacity) < 1 {
    range_error("Command capacity must be positive")
  }
  let state : ControlState = {
    capacity: capacity.cast(),
    held: [],
    commands: [],
    owner: None,
    x: 0,
    y: 0,
    release_pending: false,
  }
  @core.from_entries([
    ("version", @core.any(1)),
    (
      "move",
      @core.from_fn3(fn(id : Double, dx : Double, dy : Double) -> Bool {
        if state.owner is Some(owner) && owner != id {
          return false
        }
        state.owner = Some(id)
        state.x = dx
        state.y = dy
        true
      }),
    ),
    (
      "hold",
      @core.from_fn2(fn(id : Double, action : @core.Any) -> Unit {
        for i = 0; i < state.held.length(); i = i + 1 {
          if state.held[i].0 == id {
            state.held[i] = (id, action)
            return
          }
        }
        state.held.push((id, action))
      }),
    ),
    ("release", @core.from_fn1(fn(id : Double) -> Unit { state.release(id) })),
    (
      "tap",
      @core.from_fn2(fn(key : @core.Any, payload : @core.Any) -> Bool {
        if !safe_integer(key) || number(key) <= 0 {
          range_error("Command key must be a positive integer")
        }
        if state.commands.length().to_double() >= state.capacity {
          return false
        }
        state.commands.push(
          @core.from_entries([
            ("key", key),
            ("payload", argument(payload, @core.null())),
          ]),
        )
        true
      }),
    ),
    (
      "consumeCommand",
      @core.from_fn0(fn() -> @core.Any {
        if state.release_pending {
          state.release_pending = false
          return @core.null()
        }
        if state.commands.is_empty() {
          return @core.null()
        }
        state.release_pending = true
        state.commands.remove(0)
      }),
    ),
    (
      "snapshot",
      @core.from_fn0(fn() -> @core.Any {
        let actions : Array[@core.Any] = []
        for (_, action) in state.held {
          if !actions.contains(action) {
            actions.push(action)
          }
        }
        @core.from_entries([
          ("x", @core.any(state.x)),
          ("y", @core.any(state.y)),
          ("actions", @core.any(actions)),
        ])
      }),
    ),
    (
      "clear",
      @core.from_fn0(fn() -> Unit {
        state.held.clear()
        state.commands.clear()
        state.owner = None
        state.x = 0
        state.y = 0
        state.release_pending = false
      }),
    ),
  ])
}
