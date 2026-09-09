// Simulation engine.
//
// Implemented: all node kinds — Pool / Source / Drain / Gate / Converter /
// Trader / Delay / Queue / Register — with fixed/dice/interval/all rates,
// automatic / start / interactive activation, pull / pull-all / push flow,
// capacity, and state connections (modifier / activator — see state.mbt). Each
// step resolves direct resource edges against a working copy of the previous
// values (contention on a shared pool resolved deterministically in edge
// declaration order — a documented MVP rule), then the gate / converter+trader /
// delay+queue passes, then interactive activations are cleared. Still to come:
// trigger and rate-label state connections.

///|
/// Fresh per-node time buffers (Delay line / Queue store; empty for others).
fn make_buffers(diagram : Diagram) -> Array[Array[Int]] {
  let bufs : Array[Array[Int]] = []
  for i in 0..<diagram.nodes.length() {
    let node = diagram.nodes[i]
    let buf = match node.kind {
      Delay => Array::make(if node.param > 0 { node.param } else { 1 }, 0)
      Queue => Array::make(1, 0)
      _ => []
    }
    bufs.push(buf)
  }
  bufs
}

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
    pending: Array::make(n, false),
    buffers: make_buffers(diagram),
  }
}

///|
/// Queue an interactive activation for the next `step` (e.g. a click on a node).
pub fn SimState::activate(self : SimState, node : Int) -> Unit {
  if node >= 0 && node < self.pending.length() {
    self.pending[node] = true
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
  self.pending = Array::make(n, false)
  self.buffers = make_buffers(diagram)
}

///|
/// Nodes whose edges are resolved by a dedicated pass (or carry no flow).
fn is_special(kind : NodeKind) -> Bool {
  match kind {
    Gate | Converter | Trader | Delay | Queue | Register => true
    _ => false
  }
}

///|
fn node_active(diagram : Diagram, state : SimState, idx : Int) -> Bool {
  // An unsatisfied activator disables the node entirely.
  if node_blocked(diagram, state, idx) {
    return false
  }
  let node = diagram.nodes[idx]
  match node.activation {
    Automatic => true
    Start => state.step == 0
    // Interactive (and, until triggers are wired, OnTrigger) fire when the host
    // has queued an activation for this node via `activate`.
    Interactive | OnTrigger =>
      idx >= 0 && idx < state.pending.length() && state.pending[idx]
    // Passive nodes never self-fire; they still supply/receive when pulled/pushed.
    Passive => false
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

    // Edges touching a routing/transform/time/register node are handled in
    // their dedicated passes (or, for registers, carry no resource flow).
    if is_special(from.kind) || is_special(to.kind) {
      continue
    }
    // An unsatisfied activator disables the edge.
    if edge_blocked(diagram, state, ei) {
      continue
    }

    // A resource edge fires when the active end drives it: a pulling target or
    // a pushing source.
    let pulled = node_active(diagram, state, edge.to) &&
      (to.flow == Pull || to.flow == PullAll)
    let pushed = node_active(diagram, state, edge.from) && from.flow == Push
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
      Source =>
        effective_rate(diagram, state, ei, resolve_rate(edge.rate, state, 0))
      _ =>
        effective_rate(
          diagram,
          state,
          ei,
          resolve_rate(edge.rate, state, stock),
        )
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
  process_gates(diagram, state, work, flows)
  process_converters(diagram, state, work, flows)
  process_time_nodes(diagram, state, work, flows)
  // Interactive activations are consumed by this step only.
  for i in 0..<n {
    state.pending[i] = false
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
