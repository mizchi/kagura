///|
struct Pipe {
  mut x : Double
  gap_y : Double
} derive(FromJson, ToJson)

///|
let screen_w : Int = 320

///|
let screen_h : Int = 240

///|
let gravity : Double = 0.25

///|
let jump_velocity : Double = -4.5

///|
let pipe_width : Double = 36.0

///|
let pipe_gap : Double = 70.0

///|
let pipe_speed : Double = 1.5

///|
let pipe_interval : Int = 120

///|
// Input is replaced at debugger boundaries, compiled out in release.
#warnings("-unused_mut")
struct Game {
  _inspection : @inspection.Control
  mut layout : @scene2d.Document
  mut bird : @scene2d.Element
  mut ground : @scene2d.Element
  game_mode : @signals.Signal[Int]
  score : @signals.Signal[Int]
  bird_y : @signals.Signal[Double]
  frame_count : @signals.Signal[Int]
  pipes : @signals.Signal[Array[Pipe]]
  mut velocity : Double
  mut pipe_timer : Int
  mut input : @inpututil.InputHelper
}

///|
fn pseudo_random(seed : Int) -> Double {
  let x = seed * 1103515245 + 12345
  let normalized = ((x >> 16) & 0x7FFF).to_double() / 32767.0
  normalized
}

///|
fn Game::new() -> Game {
  let layout = @scenes.layout() catch { error => abort(error.to_string()) }
  validate_layout(layout) catch {
    error => abort(error.to_string())
  }
  let bird = layout.element("bird") catch { error => abort(error.to_string()) }
  let ground = layout.element("ground") catch {
    error => abort(error.to_string())
  }
  {
    layout,
    bird,
    ground,
    _inspection: @inspection.new_control(),
    game_mode: @signals.signal(0),
    score: @signals.signal(0),
    bird_y: @signals.signal(bird.y),
    frame_count: @signals.signal(0),
    pipes: @signals.signal([]),
    velocity: 0.0,
    pipe_timer: 0,
    input: @inpututil.new_input_helper(),
  }
}

///|
fn Game::reset(self : Game) -> Unit {
  self.bird_y.set(self.bird.y)
  self.velocity = 0.0
  self.game_mode.set(0)
  self.score.set(0)
  self.pipes.set([])
  self.pipe_timer = 0
}

///|
fn Game::update_tick(self : Game, input : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, input)
  @signals.batch(fn() {
    self.frame_count.set(self.frame_count.get() + 1)
    let action = @inpututil.is_any_action_just_pressed(self.input, input)
    match self.game_mode.get() {
      0 =>
        if action {
          self.game_mode.set(1)
          self.velocity = jump_velocity
        }
      1 => {
        // Physics
        self.velocity = self.velocity + gravity
        self.bird_y.set(self.bird_y.get() + self.velocity)
        if action {
          self.velocity = jump_velocity
        }
        // Pipe generation
        self.pipe_timer = self.pipe_timer + 1
        if self.pipe_timer >= pipe_interval {
          self.pipe_timer = 0
          let sw = screen_w.to_double()
          let sh = screen_h.to_double()
          let min_gap_y = 40.0
          let max_gap_y = sh - self.ground.height - pipe_gap - 40.0
          let gap_y = min_gap_y +
            pseudo_random(self.frame_count.get()) * (max_gap_y - min_gap_y)
          let current_pipes = self.pipes.get()
          current_pipes.push({ x: sw, gap_y, })
          self.pipes.set(current_pipes)
        }
        // Move pipes and check scoring
        let pipes = self.pipes.get()
        let mut i = 0
        while i < pipes.length() {
          let pipe = pipes[i]
          let old_x = pipe.x
          pipe.x = pipe.x - pipe_speed
          let pipe_right = old_x + pipe_width
          let pipe_right_new = pipe.x + pipe_width
          if pipe_right >= self.bird.x && pipe_right_new < self.bird.x {
            self.score.set(self.score.get() + 1)
          }
          i = i + 1
        }
        // Remove off-screen pipes
        let new_pipes : Array[Pipe] = []
        for pipe in pipes {
          if pipe.x + pipe_width > 0.0 {
            new_pipes.push(pipe)
          }
        }
        self.pipes.set(new_pipes)
        // Collision: ground/ceiling
        let ground_top = self.ground.y
        if self.bird_y.get() + self.bird.height > ground_top ||
          self.bird_y.get() < 0.0 {
          self.game_mode.set(2)
        }
        // Collision: pipes
        for pipe in self.pipes.get() {
          let bird_right = self.bird.x + self.bird.width
          let bird_bottom = self.bird_y.get() + self.bird.height
          let pipe_right = pipe.x + pipe_width
          if bird_right > pipe.x && self.bird.x < pipe_right {
            let gap_bottom = pipe.gap_y + pipe_gap
            if self.bird_y.get() < pipe.gap_y || bird_bottom > gap_bottom {
              self.game_mode.set(2)
            }
          }
        }
      }
      _ => if action { self.reset() }
    }
  })
}
