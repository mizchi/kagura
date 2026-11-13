///|
priv struct App {
  game : @sim.Game
  control : @inspection.FieldControl
  mut web : @sim.Input
  mut queued : @sim.Input
  mut previous : Double
  mut accumulator : Double
}

///|
fn axis(negative : Bool, positive : Bool) -> Double {
  (if positive { 1.0 } else { 0.0 }) - (if negative { 1.0 } else { 0.0 })
}

///|
fn read_input(raw : @core.InputSnapshot, web : @sim.Input) -> @sim.Input {
  let keys = raw.pressed_keys
  let mut x = axis(
      keys.contains(65) || keys.contains(263) || keys.contains(37),
      keys.contains(68) || keys.contains(262) || keys.contains(39),
    ) +
    web.x
  let mut z = axis(
      keys.contains(87) || keys.contains(265) || keys.contains(38),
      keys.contains(83) || keys.contains(264) || keys.contains(40),
    ) +
    web.z
  let mut strike = keys.contains(74) || web.strike
  let mut breaker = keys.contains(75) || web.breaker
  let mut evade = keys.contains(32) || web.evade
  let mut start = keys.contains(13) || keys.contains(257) || web.start
  let mut pause = keys.contains(27) || keys.contains(256) || web.pause
  if raw.gamepads.length() > 0 {
    let pad = raw.gamepads[0]
    if pad.axes.length() >= 2 {
      if pad.axes[0].abs() > 0.2 {
        x += pad.axes[0]
      }
      if pad.axes[1].abs() > 0.2 {
        z += pad.axes[1]
      }
    }
    let b = pad.pressed_buttons
    x += axis(b.contains(14), b.contains(15))
    z += axis(b.contains(12), b.contains(13))
    strike = strike || b.contains(0)
    breaker = breaker || b.contains(2)
    evade = evade || b.contains(1)
    start = start || b.contains(9)
    pause = pause || b.contains(8)
  }
  {
    x: @sim.clamp(x, -1, 1),
    z: @sim.clamp(z, -1, 1),
    strike,
    breaker,
    evade,
    start,
    pause,
    retry: keys.contains(82) || web.retry,
  }
}

///|
fn App::update(self : App, raw : @core.InputSnapshot) -> Unit {
  let now = @runtime.clock_now_ms()
  let dt = if self.previous < 0 {
    @sim.simulation_step_ms
  } else {
    @sim.clamp(now - self.previous, 0, 100)
  }
  self.previous = now
  if !self.control.begin_update() {
    self.accumulator = 0
    return
  }
  self.advance(raw, dt)
}

///|
fn App::accept_input(
  self : App,
  x : Double,
  z : Double,
  strike : Bool,
  breaker : Bool,
  evade : Bool,
) -> Unit {
  if self.control.paused {
    return
  }
  self.web = { ..@sim.idle_input(), x, z, strike, breaker, evade, }
  self.queued = {
    ..self.queued,
    strike: self.queued.strike || strike,
    breaker: self.queued.breaker || breaker,
    evade: self.queued.evade || evade,
  }
}

///|
fn App::advance(self : App, raw : @core.InputSnapshot, dt : Double) -> Unit {
  self.accumulator += dt
  while self.accumulator >= @sim.simulation_step_ms {
    let input = read_input(raw, {
      ..self.web,
      strike: self.web.strike || self.queued.strike,
      breaker: self.web.breaker || self.queued.breaker,
      evade: self.web.evade || self.queued.evade,
    })
    self.queued = @sim.idle_input()
    let generation = self.game.generation
    self.game.step(input)
    if generation != self.game.generation {
      self.control.restart()
    }
    self.accumulator -= @sim.simulation_step_ms
  }
}

///|
fn App::command(self : App, command : String) -> Unit {
  if self.control.paused {
    return
  }
  match command {
    "start" =>
      if self.game.mode == "paused" {
        self.game.set_mode("playing")
      } else if self.game.mode != "playing" {
        self.game.start()
        self.control.restart()
      }
    "retry" => {
      self.game.start()
      self.control.restart()
    }
    "pause" => if self.game.mode == "playing" { self.game.set_mode("paused") }
    "toggle-pause" =>
      self.game.set_mode(match self.game.mode {
        "playing" => "paused"
        "paused" => "playing"
        other => other
      })
    _ => ()
  }
  self.web = @sim.idle_input()
  self.queued = @sim.idle_input()
  self.accumulator = 0
  self.previous = -1
}

///|
fn main {
  install_platform()
  let app : App = {
    game: @sim.new_game(),
    control: @inspection.new_field_control(),
    web: @sim.idle_input(),
    queued: @sim.idle_input(),
    previous: -1,
    accumulator: 0,
  }
  app.register_inspection()
  install_host(
    () => app.game.snapshot(),
    (x, z, strike, breaker, evade) => {
      app.accept_input(x, z, strike, breaker, evade)
    },
    action => app.command(action),
  )
  @scene.run(
    view=() => view(app.game),
    update=raw => app.update(raw),
    width=960,
    height=540,
    title="AFTERSHIFT",
    snapshot_state=() => app.game.snapshot(),
  )
}
