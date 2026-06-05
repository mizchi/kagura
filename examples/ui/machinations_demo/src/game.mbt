///|
let screen_w : Int = 720

///|
let screen_h : Int = 480

///|
let hist_max : Int = 140

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

// The web runtime reports cursor coordinates in canvas CSS pixels, which differ
// from the logical (screen_w x screen_h) space the diagram is laid out in when
// the canvas is scaled. Read the canvas CSS size to convert clicks to logical.

///|
extern "js" fn js_canvas_css_w() -> Double =
  #| () => { const c = document.querySelector("canvas"); return c ? c.getBoundingClientRect().width : 0; }

///|
extern "js" fn js_canvas_css_h() -> Double =
  #| () => { const c = document.querySelector("canvas"); return c ? c.getBoundingClientRect().height : 0; }

///|
struct DemoState {
  diagram : @mac.Diagram
  sim : @mac.SimState
  input : @inpututil.InputHelper
  mut playing : Bool
  mut frames_per_step : Int // lower = faster auto-stepping
  mut acc : Int
  mut anim : Double // 0..1 flow-particle phase, reset each step
  mut hovered : Int // hovered node index, -1 = none
  history : Array[Array[Int]] // per-node ring buffer of values
  mut hist_head : Int // next write index
  mut hist_len : Int // valid sample count (<= hist_max)
}

///|
fn DemoState::new() -> DemoState {
  let diagram = build_sample()
  let history : Array[Array[Int]] = []
  for _ in 0..<diagram.nodes.length() {
    history.push(Array::make(hist_max, 0))
  }
  let st = {
    diagram,
    sim: @mac.SimState::init(diagram),
    input: @inpututil.new_input_helper(),
    playing: false,
    frames_per_step: 24,
    acc: 0,
    anim: 0.0,
    hovered: -1,
    history,
    hist_head: 0,
    hist_len: 0,
  }
  st.record()
  st
}

///|
/// Append the current node values to the history ring.
fn DemoState::record(self : DemoState) -> Unit {
  for i in 0..<self.diagram.nodes.length() {
    self.history[i][self.hist_head] = self.sim.values[i]
  }
  self.hist_head = (self.hist_head + 1) % hist_max
  if self.hist_len < hist_max {
    self.hist_len = self.hist_len + 1
  }
}

///|
/// The k-th oldest recorded value for node `node` (0 = oldest sample).
fn DemoState::sample(self : DemoState, node : Int, k : Int) -> Int {
  let start = (self.hist_head - self.hist_len + hist_max * 2) % hist_max
  self.history[node][(start + k) % hist_max]
}

///|
/// Advance one simulation step and record it.
fn DemoState::do_step(self : DemoState) -> Unit {
  @mac.step(self.diagram, self.sim)
  self.record()
  self.anim = 0.0
}

///|
fn DemoState::reset(self : DemoState) -> Unit {
  self.sim.reset(self.diagram)
  self.playing = false
  self.acc = 0
  self.hist_head = 0
  self.hist_len = 0
  self.record()
}

///|
fn DemoState::update(self : DemoState, input : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, input)
  let ks = self.input.key_state
  // Cursor coords arrive in canvas CSS pixels; scale into logical layout space.
  let css_w = js_canvas_css_w()
  let css_h = js_canvas_css_h()
  let sx = if css_w > 0.0 { screen_w.to_double() / css_w } else { 1.0 }
  let sy = if css_h > 0.0 { screen_h.to_double() / css_h } else { 1.0 }
  let mx = input.cursor_x * sx
  let my = input.cursor_y * sy
  // Hover detection (for the inspector).
  self.hovered = -1
  for i in 0..<self.diagram.nodes.length() {
    let n = self.diagram.nodes[i]
    if mx > n.x - 46.0 && mx < n.x + 46.0 && my > n.y - 27.0 && my < n.y + 27.0 {
      self.hovered = i
    }
  }
  // Click an interactive node to fire it, then advance one step.
  if @inpututil.is_mouse_button_just_pressed(self.input.mouse_state, 0) {
    for i in 0..<self.diagram.nodes.length() {
      let n = self.diagram.nodes[i]
      match n.activation {
        Interactive =>
          if mx > n.x - 46.0 &&
            mx < n.x + 46.0 &&
            my > n.y - 27.0 &&
            my < n.y + 27.0 {
            self.sim.activate(i)
            self.do_step()
          }
        _ => ()
      }
    }
  }
  if @inpututil.is_key_just_pressed(ks, key_space) {
    self.playing = !self.playing
  }
  if @inpututil.is_key_just_pressed(ks, key_right) {
    self.do_step()
  }
  if @inpututil.is_key_just_pressed(ks, key_r) {
    self.reset()
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
  // Flow-particle animation phase advances each frame.
  self.anim = self.anim + 0.06
  if self.anim >= 1.0 {
    self.anim = self.anim - 1.0
  }
  if self.playing {
    self.acc = self.acc + 1
    if self.acc >= self.frames_per_step {
      self.do_step()
      self.acc = 0
    }
  }
}
