// Phase 2: Gate resolution.
//
// A Gate stores nothing. When active it pulls along its incoming edges, sums
// the total, and distributes it across its outgoing edges either by weight
// ratio (Deterministic, integer largest-remainder split) or by weighted random
// per unit (Probabilistic, seeded). Amounts that exceed a destination's
// capacity are dropped (gates do not hold resources).

///|
/// Integer split of `total` across `weights` using the largest-remainder method.
fn split_det(total : Int, weights : Array[Double]) -> Array[Int] {
  let k = weights.length()
  let result = Array::make(k, 0)
  if k == 0 || total <= 0 {
    return result
  }
  let mut sumw = 0.0
  for w in weights {
    sumw = sumw + w
  }
  if sumw <= 0.0 {
    // Degenerate weights: distribute as evenly as possible, front-loaded.
    let mut rem = total
    let mut i = 0
    while rem > 0 {
      result[i % k] = result[i % k] + 1
      rem = rem - 1
      i = i + 1
    }
    return result
  }
  let frac = Array::make(k, 0.0)
  let mut assigned = 0
  for i in 0..<k {
    let exact = total.to_double() * weights[i] / sumw
    let base = exact.to_int()
    result[i] = base
    frac[i] = exact - base.to_double()
    assigned = assigned + base
  }
  // Remainder is < k; give one each to the largest fractional parts.
  let mut rem = total - assigned
  while rem > 0 {
    let mut bi = 0
    let mut bf = -1.0
    for i in 0..<k {
      if frac[i] > bf {
        bf = frac[i]
        bi = i
      }
    }
    result[bi] = result[bi] + 1
    frac[bi] = -1.0
    rem = rem - 1
  }
  result
}

///|
/// Distribute `total` units one at a time, each routed to a weighted-random edge.
fn split_prob(
  state : SimState,
  total : Int,
  weights : Array[Double],
) -> Array[Int] {
  let k = weights.length()
  let result = Array::make(k, 0)
  if k == 0 || total <= 0 {
    return result
  }
  let mut sumw = 0.0
  for w in weights {
    sumw = sumw + w
  }
  if sumw <= 0.0 {
    for _ in 0..<total {
      result[next_int(state, k)] = result[next_int(state, k)] + 1
    }
    return result
  }
  for _ in 0..<total {
    let r = (next_u64(state) % 1000000).to_int().to_double() / 1000000.0 * sumw
    let mut acc = 0.0
    let mut chosen = k - 1
    for i in 0..<k {
      acc = acc + weights[i]
      if r < acc {
        chosen = i
        break
      }
    }
    result[chosen] = result[chosen] + 1
  }
  result
}

///|
/// Resolve every active gate, mutating `work` (per-node values) and `flows`
/// (per-edge amounts) in place. Called by `step` after the direct-edge pass.
fn process_gates(
  diagram : Diagram,
  state : SimState,
  work : Array[Int],
  flows : Array[Int],
) -> Unit {
  let edges = diagram.resources
  for gi in 0..<diagram.nodes.length() {
    let g = diagram.nodes[gi]
    if g.kind != Gate || !node_active(g, state.step) {
      continue
    }
    // Pull from incoming edges.
    let mut total = 0
    for ei in 0..<edges.length() {
      let e = edges[ei]
      if e.to != gi {
        continue
      }
      let from = diagram.nodes[e.from]
      let want = match from.kind {
        Source => resolve_rate(e.rate, state, 0)
        _ => resolve_rate(e.rate, state, work[e.from])
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
      total = total + amt
      flows[ei] = amt
    }
    // Collect outgoing edges and their weights.
    let out_idx : Array[Int] = []
    let weights : Array[Double] = []
    for ei in 0..<edges.length() {
      if edges[ei].from == gi {
        out_idx.push(ei)
        weights.push(edges[ei].weight)
      }
    }
    let shares = match g.gate_mode {
      Deterministic => split_det(total, weights)
      Probabilistic => split_prob(state, total, weights)
    }
    // Place shares at destinations (respecting capacity; excess is dropped).
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
