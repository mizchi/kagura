///|
/// Declare each getter/setter once; the common adapter derives describe and reduce.
/// "bird" is a logical subject, selected via the visual at world/body in view.mbt.
/// Setters return detached candidate state; debug_replace validates and commits it.
/// Studio permits edits only while paused with a current session/revision token.
/// Changes affect runtime state, not scenes/training.mbt or the project file.
/// See game/inspection/README.md for the host API and debug/release build contract.
fn debug_inspector() -> @inspection.Inspector[DebugState] raise {
  @inspection.Inspector::new([
    @inspection.bind_subject("bird", name="Bird", fields=[
      @inspection.number_field(
        "y",
        get=s => s.bird_y,
        set=(s, value) => { ..s, bird_y: value, },
        label="Y",
        unit="px",
      ),
      @inspection.number_field(
        "velocity",
        get=s => s.velocity,
        set=(s, value) => { ..s, velocity: value, },
        label="Velocity",
        unit="px/tick",
      ),
      @inspection.number_field(
        "speed",
        get=s => s.velocity.abs(),
        label="Speed",
        unit="px/tick",
      ),
    ]),
  ])
}
