// Phase 4: Converter resolution.
//
// A Converter atomically turns inputs into outputs: when active it checks that
// every incoming edge can be fully satisfied; if so it consumes all incoming
// rates and produces all outgoing rates (respecting destination capacity),
// otherwise nothing happens. This models "spend N of X to get M of Y" (e.g.
// buy a building). Modifiers and activators apply to its edges as usual.

///|
/// Resolve every active converter, mutating `work` and `flows` in place.
fn process_converters(
  diagram : Diagram,
  state : SimState,
  work : Array[Int],
  flows : Array[Int],
) -> Unit {
  let edges = diagram.resources
  for ci in 0..<diagram.nodes.length() {
    let c = diagram.nodes[ci]
    // Traders share converter semantics: an atomic resource exchange.
    let is_conv = match c.kind {
      Converter | Trader => true
      _ => false
    }
    if !is_conv || !node_active(diagram, state, ci) {
      continue
    }
    // Collect incoming requirements.
    let in_idx : Array[Int] = []
    let in_from : Array[Int] = []
    let in_req : Array[Int] = []
    for ei in 0..<edges.length() {
      let e = edges[ei]
      if e.to != ci || edge_blocked(diagram, state, ei) {
        continue
      }
      let from = diagram.nodes[e.from]
      let req = match from.kind {
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
      in_idx.push(ei)
      in_from.push(e.from)
      in_req.push(req)
    }
    // Atomic: every input must be fully available.
    let mut ok = true
    for k in 0..<in_idx.length() {
      let from = diagram.nodes[in_from[k]]
      let avail = match from.kind {
        Source => in_req[k]
        _ => work[in_from[k]]
      }
      if avail < in_req[k] {
        ok = false
      }
    }
    if !ok {
      continue
    }
    // Consume inputs.
    for k in 0..<in_idx.length() {
      match diagram.nodes[in_from[k]].kind {
        Source => ()
        _ => work[in_from[k]] = work[in_from[k]] - in_req[k]
      }
      flows[in_idx[k]] = in_req[k]
    }
    // Produce outputs (respecting capacity; drains/sources never store).
    for ei in 0..<edges.length() {
      let e = edges[ei]
      if e.from != ci || edge_blocked(diagram, state, ei) {
        continue
      }
      let to = diagram.nodes[e.to]
      let mut amt = effective_rate(
        diagram,
        state,
        ei,
        resolve_rate(e.rate, state, 0),
      )
      match to.capacity {
        Some(cap) => {
          let room = cap - work[e.to]
          if amt > room {
            amt = room
          }
        }
        None => ()
      }
      if amt < 0 {
        amt = 0
      }
      match to.kind {
        Drain | Source => ()
        _ => work[e.to] = work[e.to] + amt
      }
      flows[ei] = amt
    }
  }
}
