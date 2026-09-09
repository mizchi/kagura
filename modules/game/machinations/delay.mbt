// Phase 4: time nodes (Delay and Queue).
//
// Delay: pulls along incoming edges each step, holds the amount for `param`
//        steps, then releases it along outgoing edges (a fixed-length delay
//        line). param <= 0 behaves as a 1-step delay.
// Queue: pulls into a single store and releases up to `param` per step (FIFO).
//
// Released amounts are distributed across outgoing edges by weight (same
// largest-remainder split as gates); overflow beyond capacity is dropped.

///|
fn process_time_nodes(
  diagram : Diagram,
  state : SimState,
  work : Array[Int],
  flows : Array[Int],
) -> Unit {
  let edges = diagram.resources
  for ni in 0..<diagram.nodes.length() {
    let node = diagram.nodes[ni]
    let is_delay = match node.kind {
      Delay => true
      _ => false
    }
    let is_queue = match node.kind {
      Queue => true
      _ => false
    }
    if (!is_delay && !is_queue) || !node_active(diagram, state, ni) {
      continue
    }
    // Pull from incoming edges.
    let mut incoming = 0
    for ei in 0..<edges.length() {
      let e = edges[ei]
      if e.to != ni || edge_blocked(diagram, state, ei) {
        continue
      }
      let from = diagram.nodes[e.from]
      let want = match from.kind {
        Source =>
          effective_rate(diagram, state, ei, resolve_rate(e.rate, state, 0))
        _ =>
          effective_rate(
            diagram,
            state,
            ei,
            resolve_rate(e.rate, state, work[e.from]),
          )
      }
      let avail = match from.kind {
        Source => want
        _ => work[e.from]
      }
      let mut amt = if want < avail { want } else { avail }
      if amt < 0 {
        amt = 0
      }
      match from.kind {
        Source => ()
        _ => work[e.from] = work[e.from] - amt
      }
      incoming = incoming + amt
      flows[ei] = amt
    }
    // Advance the buffer and compute the released amount.
    let buf = state.buffers[ni]
    let mut release = 0
    if is_delay {
      let d = buf.length()
      if d > 0 {
        release = buf[0]
        for i in 0..<(d - 1) {
          buf[i] = buf[i + 1]
        }
        buf[d - 1] = incoming
      } else {
        release = incoming
      }
    } else {
      buf[0] = buf[0] + incoming
      let r = if node.param > 0 { node.param } else { 1 }
      release = if buf[0] < r { buf[0] } else { r }
      buf[0] = buf[0] - release
    }
    // Distribute the release across outgoing edges.
    let out_idx : Array[Int] = []
    let weights : Array[Double] = []
    for ei in 0..<edges.length() {
      if edges[ei].from == ni && !edge_blocked(diagram, state, ei) {
        out_idx.push(ei)
        weights.push(edges[ei].weight)
      }
    }
    let shares = split_det(release, weights)
    for k in 0..<out_idx.length() {
      let ei = out_idx[k]
      let to = diagram.nodes[edges[ei].to]
      let mut place = shares[k]
      match to.capacity {
        Some(cap) => {
          let room = cap - work[edges[ei].to]
          if place > room {
            place = room
          }
        }
        None => ()
      }
      if place < 0 {
        place = 0
      }
      match to.kind {
        Drain | Source => ()
        _ => work[edges[ei].to] = work[edges[ei].to] + place
      }
      flows[ei] = place
    }
  }
}
