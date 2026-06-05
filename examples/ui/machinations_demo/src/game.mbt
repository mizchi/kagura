///|
let screen_w : Int = 640

///|
let screen_h : Int = 400

// Web key codes.
///|
let key_space : Int = 32

///|
let key_right : Int = 39

///|
let key_r : Int = 82

///|
let key_up : Int = 38

///|
let key_down : Int = 40

///|
struct DemoState {
  diagram : @mac.Diagram
  sim : @mac.SimState
  input : @inpututil.InputHelper
  mut playing : Bool
  mut frames_per_step : Int // lower = faster auto-stepping
  mut acc : Int
}

///|
fn DemoState::new() -> DemoState {
  let diagram = build_sample()
  {
    diagram,
    sim: @mac.SimState::init(diagram),
    input: @inpututil.new_input_helper(),
    playing: false,
    frames_per_step: 24,
    acc: 0,
  }
}

///|
fn DemoState::update(self : DemoState, input : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, input)
  let ks = self.input.key_state
  // Click an interactive node to fire it, then advance one step for instant
  // feedback (cursor coords are in logical canvas space).
  if @inpututil.is_mouse_button_just_pressed(self.input.mouse_state, 0) {
    let mx = input.cursor_x
    let my = input.cursor_y
    for i in 0..<self.diagram.nodes.length() {
      let n = self.diagram.nodes[i]
      match n.activation {
        Interactive =>
          if mx > n.x - 46.0 &&
            mx < n.x + 46.0 &&
            my > n.y - 27.0 &&
            my < n.y + 27.0 {
            self.sim.activate(i)
            @mac.step(self.diagram, self.sim)
          }
        _ => ()
      }
    }
  }
  if @inpututil.is_key_just_pressed(ks, key_space) {
    self.playing = !self.playing
  }
  if @inpututil.is_key_just_pressed(ks, key_right) {
    @mac.step(self.diagram, self.sim)
  }
  if @inpututil.is_key_just_pressed(ks, key_r) {
    self.sim.reset(self.diagram)
    self.playing = false
    self.acc = 0
  }
  if @inpututil.is_key_just_pressed(ks, key_up) {
    self.frames_per_step = self.frames_per_step - 4
    if self.frames_per_step < 2 {
      self.frames_per_step = 2
    }
  }
  if @inpututil.is_key_just_pressed(ks, key_down) {
    self.frames_per_step = self.frames_per_step + 4
    if self.frames_per_step > 120 {
      self.frames_per_step = 120
    }
  }
  if self.playing {
    self.acc = self.acc + 1
    if self.acc >= self.frames_per_step {
      @mac.step(self.diagram, self.sim)
      self.acc = 0
    }
  }
}
