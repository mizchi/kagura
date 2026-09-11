///| Game-owned logical state. GPU resources and input edges are not checkpoint data.
struct DebugState {
  layout : @scene2d.Document
  mode : Int
  score : Int
  bird_y : Double
  frame_count : Int
  velocity : Double
  pipe_timer : Int
  pipes : Array[Pipe]
} derive(FromJson, ToJson)

///|
extend DebugState with ToJson::{to_json}

///|
fn Game::debug_state(self : Game) -> DebugState {
  let state : DebugState = {
    layout: self.layout,
    mode: self.game_mode.get(), score: self.score.get(),
    bird_y: self.bird_y.get(), frame_count: self.frame_count.get(),
    velocity: self.velocity, pipe_timer: self.pipe_timer, pipes: self.pipes.get(),
  }
  @json.from_json(state.to_json()) catch { error => abort(error.to_string()) }
}

///|
fn Game::debug_pause(self : Game, paused : Bool) -> Unit {
  self.debug_paused = paused
  self.debug_revision += 1
  // Release input edges when crossing a debugger boundary.
  self.input = @inpututil.new_input_helper()
}

///|
fn Game::debug_step(self : Game) -> Unit raise {
  if !self.debug_paused { fail("Runtime must be paused") }
  self.debug_paused = false
  self.update(@core.empty_input_snapshot())
  self.debug_paused = true
}

///|
fn Game::debug_replace(self : Game, state : DebugState) -> Unit raise {
  if !self.debug_paused { fail("Runtime must be paused") }
  validate_layout(state.layout)
  if state.mode < 0 || state.mode > 2 || state.score < 0 || state.frame_count < 0 || state.pipe_timer < 0 || state.pipe_timer >= pipe_interval || state.pipes.length() > 512 { fail("Invalid runtime counters") }
  for value in [state.bird_y, state.velocity] {
    if !(value >= -1000000.0 && value <= 1000000.0) { fail("Invalid runtime physics") }
  }
  let ground = state.layout.element("ground")
  for pipe in state.pipes {
    if !(pipe.x >= -1000000.0 && pipe.x <= 1000000.0) || !(pipe.gap_y >= 0.0 && pipe.gap_y + pipe_gap <= ground.y) { fail("Invalid runtime pipe") }
  }
  let copy : DebugState = @json.from_json(state.to_json())
  let bird = copy.layout.element("bird")
  let ground = copy.layout.element("ground")
  @signals.batch(fn() {
    self.layout = copy.layout
    self.bird = bird
    self.ground = ground
    self.game_mode.set(copy.mode)
    self.score.set(copy.score)
    self.bird_y.set(copy.bird_y)
    self.frame_count.set(copy.frame_count)
    self.velocity = copy.velocity
    self.pipe_timer = copy.pipe_timer
    self.pipes.set(copy.pipes)
    self.input = @inpututil.new_input_helper()
    self.debug_revision += 1
  })
}

///| Refuse misspelled fields at every level rather than silently discarding an edit.
fn decode_debug_state(source : String) -> DebugState raise {
  let json = @json.parse(source)
  let state : DebugState = @json.from_json(json)
  if state.to_json() != json { fail("Unknown or non-canonical runtime state fields") }
  state
}
