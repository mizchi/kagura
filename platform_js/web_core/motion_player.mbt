///|
/// Playback state is independent of rendering, assets and editor documents.
priv struct MotionPlayer {
  clips : Array[@core.Any]
  mut clip : @core.Any
  mut time : Double
  mut playing : Bool
  mut speed : Double
  mut looping : Bool
}

///|
fn require_time(value : @core.Any) -> Double {
  if !finite(value) {
    @core.throw_error("Expected finite time")
  }
  number(value)
}

///|
fn MotionPlayer::duration(self : MotionPlayer) -> Double {
  number(self.clip._get("duration"))
}

///|
pub fn create_motion_player(asset : @core.Any) -> @core.Any {
  let clips = array_values(asset._get("clips"))
  let state : MotionPlayer = {
    clips,
    clip: clips[0],
    time: 0,
    playing: false,
    speed: 1,
    looping: true,
  }
  @object.Object::freeze(
    @core.from_entries([
      (
        "snapshot",
        @core.from_fn0(fn() {
          let fps = number(state.clip._get("fps"))
          @core.from_entries([
            ("clip", state.clip._get("id")),
            ("time", @core.any(state.time)),
            ("duration", @core.any(state.duration())),
            ("fps", @core.any(fps)),
            ("frame", @core.any(@jsmath.Math::round(state.time * fps))),
            ("playing", @core.any(state.playing)),
            ("speed", @core.any(state.speed)),
            ("loop", @core.any(state.looping)),
          ])
        }),
      ),
      (
        "selectClip",
        @core.from_fn1(fn(id : @core.Any) -> Unit {
          for clip in state.clips {
            if @core.equal(clip._get("id"), id) {
              state.clip = clip
              state.time = 0
              state.playing = false
              return
            }
          }
          @core.throw_error("Unknown motion clip")
        }),
      ),
      (
        "play",
        @core.from_fn0(fn() -> Unit {
          if state.time >= state.duration() {
            state.time = 0
          }
          state.playing = true
        }),
      ),
      ("pause", @core.from_fn0(fn() -> Unit { state.playing = false })),
      (
        "seek",
        @core.from_fn1(fn(value : @core.Any) -> Unit {
          state.time = clamp(require_time(value), 0, state.duration())
          state.playing = false
        }),
      ),
      (
        "step",
        @core.from_fn1(fn(direction : @core.Any) -> Unit {
          if !@core.equal(direction, @core.any(-1)) &&
            !@core.equal(direction, @core.any(1)) {
            @core.throw_error("Step must be -1 or 1")
          }
          let fps = number(state.clip._get("fps"))
          state.time = clamp(
            (
              @jsmath.Math::round(state.time * fps).to_double() +
              number(direction)
            ) /
            fps,
            0,
            state.duration(),
          )
          state.playing = false
        }),
      ),
      (
        "setSpeed",
        @core.from_fn1(fn(value : @core.Any) -> Unit {
          let speed = require_time(value)
          if speed < 0.1 || speed > 4 {
            @core.throw_error("Speed must be 0.1..4")
          }
          state.speed = speed
        }),
      ),
      (
        "setLoop",
        @core.from_fn1(fn(value : @core.Any) -> Unit {
          if @core.typeof_(value) != "boolean" {
            @core.throw_error("Loop must be boolean")
          }
          state.looping = value.cast()
        }),
      ),
      (
        "tick",
        @core.from_fn1(fn(value : @core.Any) -> Unit {
          let delta = require_time(value)
          if delta < 0 {
            @core.throw_error("Negative time delta")
          }
          if !state.playing {
            return
          }
          state.time = state.time + delta * state.speed
          if state.time >= state.duration() {
            if state.looping {
              state.time = state.time % state.duration()
            } else {
              state.time = state.duration()
              state.playing = false
            }
          }
        }),
      ),
    ]),
  )
}
