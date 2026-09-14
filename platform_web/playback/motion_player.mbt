///|
/// Playback state is independent of rendering, assets and editor documents.
priv struct MotionPlayer {
  clips : Array[@core.Any]
  mut clip : @core.Any
  timeline : @timeline.Timeline
}

///|
fn require_time(value : @core.Any) -> Double {
  if !@interop.finite(value) {
    @core.throw_error("Expected finite time")
  }
  @interop.number(value)
}

///|
fn MotionPlayer::duration(self : MotionPlayer) -> Double {
  @interop.number(self.clip._get("duration"))
}

///|
pub fn create_motion_player(asset : @core.Any) -> @core.Any {
  let clips = @interop.array_values(asset._get("clips"))
  let state : MotionPlayer = {
    clips,
    clip: clips[0],
    timeline: @timeline.Timeline::new(),
  }
  @object.Object::freeze(
    @core.from_entries([
      (
        "snapshot",
        @core.from_fn0(fn() {
          let fps = @interop.number(state.clip._get("fps"))
          @core.from_entries([
            ("clip", state.clip._get("id")),
            ("time", @core.any(state.timeline.time)),
            ("duration", @core.any(state.duration())),
            ("fps", @core.any(fps)),
            ("frame", @core.any(@jsmath.Math::round(state.timeline.time * fps))),
            ("playing", @core.any(state.timeline.playing)),
            ("speed", @core.any(state.timeline.speed)),
            ("loop", @core.any(state.timeline.looping)),
          ])
        }),
      ),
      (
        "selectClip",
        @core.from_fn1(fn(id : @core.Any) -> Unit {
          for clip in state.clips {
            if @core.equal(clip._get("id"), id) {
              state.clip = clip
              state.timeline.time = 0
              state.timeline.playing = false
              return
            }
          }
          @core.throw_error("Unknown motion clip")
        }),
      ),
      (
        "play",
        @core.from_fn0(fn() -> Unit { state.timeline.play(state.duration()) }),
      ),
      ("pause", @core.from_fn0(fn() -> Unit { state.timeline.playing = false })),
      (
        "seek",
        @core.from_fn1(fn(value : @core.Any) -> Unit {
          state.timeline.seek(require_time(value), state.duration())
        }),
      ),
      (
        "step",
        @core.from_fn1(fn(direction : @core.Any) -> Unit {
          if !@core.equal(direction, @core.any(-1)) &&
            !@core.equal(direction, @core.any(1)) {
            @core.throw_error("Step must be -1 or 1")
          }
          let fps = @interop.number(state.clip._get("fps"))
          state.timeline.time = @interop.clamp(
            (
              @jsmath.Math::round(state.timeline.time * fps).to_double() +
              @interop.number(direction)
            ) /
            fps,
            0,
            state.duration(),
          )
          state.timeline.playing = false
        }),
      ),
      (
        "setSpeed",
        @core.from_fn1(fn(value : @core.Any) -> Unit {
          let speed = require_time(value)
          if speed < 0.1 || speed > 4 {
            @core.throw_error("Speed must be 0.1..4")
          }
          state.timeline.speed = speed
        }),
      ),
      (
        "setLoop",
        @core.from_fn1(fn(value : @core.Any) -> Unit {
          if @core.typeof_(value) != "boolean" {
            @core.throw_error("Loop must be boolean")
          }
          state.timeline.looping = value.cast()
        }),
      ),
      (
        "tick",
        @core.from_fn1(fn(value : @core.Any) -> Unit {
          let delta = require_time(value)
          if delta < 0 {
            @core.throw_error("Negative time delta")
          }
          state.timeline.advance(delta, state.duration())
        }),
      ),
    ]),
  )
}
