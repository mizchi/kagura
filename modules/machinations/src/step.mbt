// Simulation engine.
//
// Phase 1 scope: Pool / Source / Drain with fixed-rate (and dice/interval/all)
// resource connections, automatic/start activation, pull and push flow. Each
// step resolves all resource edges against a working copy of the previous
// values so the order of independent flows does not matter; contention on a
// shared pool is resolved deterministically in edge declaration order (a
// documented MVP rule, refined in later phases). Gates, state connections,
// converters/traders/delays and interactive/trigger activation are added in
// subsequent phases.

///|
/// Create the initial simulation state for a diagram, seeded for reproducibility.
pub fn SimState::init(
  diagram : Diagram,
  seed? : UInt64 = 0x123456789ABCDEF,
) -> SimState {
  let n = diagram.nodes.length()
  let values = Array::make(n, 0)
  for i in 0..<n {
    values[i] = diagram.nodes[i].initial
  }
  {
    values,
    step: 0,
    rng: seed,
    last_flows: Array::make(diagram.resources.length(), 0),
  }
}

///|
/// Reset state back to the diagram's initial values (keeps the RNG stream).
pub fn SimState::reset(self : SimState, diagram : Diagram) -> Unit {
  let n = diagram.nodes.length()
  let values = Array::make(n, 0)
  for i in 0..<n {
    values[i] = diagram.nodes[i].initial
  }
  self.values = values
  self.step = 0
  self.last_flows = Array::make(diagram.resources.length(), 0)
}

///|
fn node_active(node : Node, step : Int) -> Bool {
  match node.activation {
    Automatic => true
    Start => step == 0
    // Passive/Interactive/OnTrigger do not self-fire in Phase 1; passive nodes
    // still supply/receive resources when an active node pulls/pushes them.
    _ => false
  }
}

///|
/// Resolve a rate label to a concrete amount for this step. `avail` is the
/// amount available at the source end (used by `All`).
fn resolve_rate(rate : Rate, state : SimState, avail : Int) -> Int {
  match rate {
    Fixed(n) => n
    Dice(count, sides) => roll_dice(state, count, sides)
    Interval(n) => if n > 0 && state.step % n == 0 { 1 } else { 0 }
    All => avail
  }
}

///|
/// Advance the simulation by one step, mutating `state`.
pub fn step(diagram : Diagram, state : SimState) -> Unit {
  let n = diagram.nodes.length()
  let work = Array::make(n, 0)
  for i in 0..<n {
    work[i] = state.values[i]
  }
  let flows = Array::make(diagram.resources.length(), 0)
  for ei in 0..<diagram.resources.length() {
    let edge = diagram.resources[ei]
    let from = diagram.nodes[edge.from]
    let to = diagram.nodes[edge.to]

    // A resource edge fires when the active end drives it: a pulling target or
    // a pushing source.
    let pulled = node_active(to, state.step) &&
      (to.flow == Pull || to.flow == PullAll)
    let pushed = node_active(from, state.step) && from.flow == Push
    if !(pulled || pushed) {
      continue
    }

    // Available at the source end: a Source is infinite; everything else draws
    // from its (working) value.
    let stock = match from.kind {
      Source => 0 // placeholder; `want` is taken as-is for sources below
      _ => work[edge.from]
    }
    let want = match from.kind {
      Source => resolve_rate(edge.rate, state, 0)
      _ => resolve_rate(edge.rate, state, stock)
    }
    let avail = match from.kind {
      Source => want
      _ => work[edge.from]
    }
    let mut moved = if want < avail { want } else { avail }

    // PullAll is atomic: if the source cannot fully satisfy, nothing moves.
    if to.flow == PullAll && moved < want {
      moved = 0
    }

    // Capacity at the destination (drains/sources never store).
    match to.capacity {
      Some(cap) => {
        let room = cap - work[edge.to]
        if moved > room {
          moved = room
        }
      }
      None => ()
    }
    if moved < 0 {
      moved = 0
    }

    // Apply: sources are infinite producers; drains destroy what they receive.
    match from.kind {
      Source => ()
      _ => work[edge.from] = work[edge.from] - moved
    }
    match to.kind {
      Drain | Source => ()
      _ => work[edge.to] = work[edge.to] + moved
    }
    flows[ei] = moved
  }
  state.values = work
  state.last_flows = flows
  state.step = state.step + 1
}

///|
/// Run `count` steps.
pub fn run(diagram : Diagram, state : SimState, count : Int) -> Unit {
  for _ in 0..<count {
    step(diagram, state)
  }
}
