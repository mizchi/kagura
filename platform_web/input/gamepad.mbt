///|
/// Known raw HID layouts only; browser standard mappings always take priority.
let victrix_id : @regexp.RegExp = @regexp.RegExp::new(
  "\\bVendor:\\s*0e6f\\s+Product:\\s*0218\\b",
  flags="i",
)

///|
fn pad_axis(value : @core.Any) -> Double {
  if @interop.finite(value) {
    @interop.clamp(@interop.number(value), -1, 1)
  } else {
    0
  }
}

///|
fn pad_button(source : @core.Any) -> @core.Any {
  let value = @interop.field(source, "value")
  button(
    @interop.truthy(@interop.field(source, "pressed")),
    if @interop.finite(value) {
      @interop.clamp(@interop.number(value), 0, 1)
    } else {
      0
    },
  )
}

///|
fn button(pressed : Bool, value : Double) -> @core.Any {
  @core.from_entries([
    ("pressed", @core.any(pressed)),
    ("value", @core.any(value)),
  ])
}

///|
fn button_down(source : @core.Any) -> Bool {
  let value = @interop.field(source, "value")
  @interop.truthy(@interop.field(source, "pressed")) ||
  (@interop.finite(value) && @interop.number(value) >= 0.55)
}

///|
pub fn normalize_gamepad(pad : @core.Any) -> @core.Any {
  let mapping : String = pad._get("mapping").cast()
  if mapping == "standard" {
    return pad
  }
  let axes = pad._get("axes")
  let raw_buttons = pad._get("buttons")
  if mapping != "" ||
    !victrix_id.test_(pad._get("id").cast()) ||
    @interop.length(axes) != 10 ||
    @interop.length(raw_buttons) < 14 {
    return @core.null()
  }
  let order = [1, 2, 0, 3, 4, 5, 6, 7, 8, 9, 10, 11, -1, -1, -1, -1, 12, 13]
  let buttons = order.map(fn(i) {
    pad_button(if i < 0 { @core.null() } else { raw_buttons._get_by_index(i) })
  })
  for (axis_index, button_index) in [(3, 6), (4, 7)] {
    let raw = axes._get_by_index(axis_index)
    let value = if @interop.finite(raw) { (pad_axis(raw) + 1) / 2 } else { 0 }
    buttons[button_index] = button(
      button_down(buttons[button_index]) || value >= 0.55,
      value,
    )
  }
  let hat = axes._get_by_index(9)
  // Neutral is > 1; zero at startup is unspecified, not a diagonal.
  if @interop.finite(hat) &&
    @interop.number(hat) >= -1 &&
    @interop.number(hat) <= 1 {
    let position = (@interop.number(hat) + 1) * 3.5
    let direction = @jsmath.Math::round(position)
    if (position - direction.to_double()).abs() < 0.1 {
      let hats = [
        [12],
        [12, 15],
        [15],
        [13, 15],
        [13],
        [13, 14],
        [14],
        [12, 14],
      ]
      for index in hats[direction] {
        buttons[index] = button(true, 1)
      }
    }
  }
  @core.from_entries([
    ("index", pad._get("index")),
    ("id", pad._get("id")),
    ("connected", pad._get("connected")),
    ("mapping", @core.any("standard")),
    ("profile", @core.any("victrix-pro-bfg-ps5-mac")),
    (
      "axes",
      @core.any([0, 1, 2, 5].map(fn(i) { pad_axis(axes._get_by_index(i)) })),
    ),
    ("buttons", @core.any(buttons)),
  ])
}

///|
priv struct GamepadState {
  dead_zone : Double
  mut identity : String?
  mut armed : Bool
  mut previous : Array[Int]
  mut previous_axes : Array[Double]
  mut direction : String?
  mut next_repeat : Double
  mut last_time : Double?
}

///|
fn device_key(pad : @core.Any) -> String {
  let index = pad._get("index").to_string()
  let id : String = pad._get("id").cast()
  let profile : String = @interop.fallback(
    pad._get("profile"),
    pad._get("mapping"),
  ).cast()
  "\{index}:\{id}:\{profile}"
}

///|
pub fn create_gamepad_reader(options : @core.Any) -> @core.Any {
  let dead_zone = @interop.argument(
    @interop.field(options, "deadZone"),
    @core.any(0.18),
  )
  if !@interop.finite(dead_zone) ||
    @interop.number(dead_zone) < 0 ||
    @interop.number(dead_zone) >= 1 {
    @interop.range_error(
      "Stick coordinates must be finite, radius positive, and deadZone in [0, 1)",
    )
  }
  let state : GamepadState = {
    dead_zone: @interop.number(dead_zone),
    identity: None,
    armed: false,
    previous: [],
    previous_axes: [0, 0, 0, 0],
    direction: None,
    next_repeat: 0,
    last_time: None,
  }
  @core.from_entries([
    (
      "step",
      @core.from_fn2(fn(pads : @core.Any, options : @core.Any) {
        state.step(pads, options)
      }),
    ),
  ])
}

///|
fn GamepadState::step(
  self : GamepadState,
  pads : @core.Any,
  options : @core.Any,
) -> @core.Any {
  let enabled = @interop.truthy(
    @interop.argument(@interop.field(options, "enabled"), @core.any(true)),
  )
  let now = @interop.number(
    @interop.argument(@interop.field(options, "now"), @core.any(0)),
  )
  let connected = @interop.array_values(pads).filter(fn(p) {
    @interop.truthy(p) &&
    !@core.equal(@interop.field(p, "connected"), @core.any(false))
  })
  let candidates = connected
    .map(normalize_gamepad)
    .filter(fn(p) { !@core.is_nullish(p) })
  let mut selected : @core.Any? = None
  for candidate in candidates {
    if Some(device_key(candidate)) == self.identity {
      selected = Some(candidate)
      break
    }
  }
  let pad = match selected {
    Some(p) => p
    None => if candidates.is_empty() { @core.null() } else { candidates[0] }
  }
  let supported = !@core.is_nullish(pad)
  let next_identity = if supported { Some(device_key(pad)) } else { None }
  let changed = next_identity != self.identity
  let dt : Double = match self.last_time {
    None => 0
    Some(last) => @interop.clamp((now - last) / 1000, 0, 0.05)
  }
  self.last_time = Some(now)
  let old_buttons = self.previous
  if changed || !enabled {
    self.identity = next_identity
    self.armed = false
    self.previous = []
    self.previous_axes = [0, 0, 0, 0]
    self.direction = None
  }
  let axes = @interop.field(pad, "axes")
  let axis_at = fn(i) {
    pad_axis(
      if @core.is_nullish(axes) {
        @core.undefined()
      } else {
        axes._get_by_index(i)
      },
    )
  }
  let (mx, my) = radial_stick(axis_at(0), axis_at(1), 1, self.dead_zone)
  let (lx, ly) = radial_stick(axis_at(2), axis_at(3), 1, self.dead_zone)
  let buttons = @interop.array_values(@interop.field(pad, "buttons")).map(
    button_down,
  )
  let neutral = !buttons.contains(true) &&
    mx == 0 &&
    my == 0 &&
    lx == 0 &&
    ly == 0
  if supported && enabled && neutral {
    self.armed = true
  }
  let ready = supported && enabled && self.armed
  let down : Array[Int] = []
  if ready {
    for i = 0; i < buttons.length(); i = i + 1 {
      if buttons[i] {
        down.push(i)
      }
    }
  }
  let pressed = down.filter(fn(i) { !self.previous.contains(i) })
  let released = old_buttons.filter(fn(i) { !down.contains(i) })
  let vectors = [mx, my, lx, ly]
  let mut axis_activity = false
  for i = 0; i < 4; i = i + 1 {
    if (vectors[i] - self.previous_axes[i]).abs() > 0.025 {
      axis_activity = true
    }
  }
  let activity = ready &&
    (!pressed.is_empty() || !released.is_empty() || axis_activity)
  let horizontal = if down.contains(15) {
    1
  } else if down.contains(14) {
    -1
  } else if mx.abs() > 0.5 {
    if mx > 0 {
      1
    } else {
      -1
    }
  } else {
    0
  }
  let vertical = if down.contains(13) {
    1
  } else if down.contains(12) {
    -1
  } else if my.abs() > 0.5 {
    if my > 0 {
      1
    } else {
      -1
    }
  } else {
    0
  }
  let next_direction = if !ready {
    None
  } else if vertical != 0 {
    Some(if vertical > 0 { "down" } else { "up" })
  } else if horizontal != 0 {
    Some(if horizontal > 0 { "right" } else { "left" })
  } else {
    None
  }
  let mut navigation : String? = None
  if next_direction != self.direction {
    self.direction = next_direction
    navigation = next_direction
    self.next_repeat = now + 400
  } else if self.direction != None && now >= self.next_repeat {
    navigation = self.direction
    self.next_repeat = now + 140
  }
  self.previous = down
  if activity || !ready {
    self.previous_axes = vectors
  }
  @core.from_entries([
    ("connected", @core.any(!connected.is_empty())),
    ("supported", @core.any(supported)),
    ("ready", @core.any(ready)),
    ("index", @interop.fallback(@interop.field(pad, "index"), @core.any(-1))),
    (
      "id",
      @interop.fallback(
        @interop.field(pad, "id"),
        if connected.is_empty() {
          @core.any("")
        } else {
          connected[0]._get("id")
        },
      ),
    ),
    (
      "profile",
      if supported {
        @interop.fallback(@interop.field(pad, "profile"), @core.any("standard"))
      } else {
        @core.null()
      },
    ),
    (
      "move",
      if ready {
        @interop.vector(mx, my)
      } else {
        @interop.vector(0, 0)
      },
    ),
    (
      "look",
      if ready {
        @interop.vector(lx, ly)
      } else {
        @interop.vector(0, 0)
      },
    ),
    ("down", @core.any(down)),
    ("pressed", @core.any(pressed)),
    ("released", @core.any(released)),
    ("activity", @core.any(activity)),
    (
      "navigation",
      match navigation {
        Some(s) => @core.any(s)
        None => @core.null()
      },
    ),
    ("dt", @core.any(dt)),
  ])
}
