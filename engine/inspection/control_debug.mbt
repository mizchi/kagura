///|
/// Optional debugger bookkeeping. Games remain responsible for tick/commit semantics.
/// Debug profile only. Release defines Control = Unit and allocates no debug state.
/// pkg.generated.mbti shows the debug profile, not the release representation.
/// Access counters/hierarchy only from files selected by targets: ["debug"].
pub(all) struct Control {
  mut paused : Bool
  mut revision : Int
  mut hierarchy : Array[@hierarchy.Node]
}

///|
pub fn new_control() -> Control {
  { paused: false, revision: 0, hierarchy: [], }
}
