// Phase 3: state connections (non-resource edges).
//
// Modifier  : a source node's value adds to a resource edge's rate
//             (round(value * factor)); enables feedback loops such as
//             "more buildings -> faster production".
// Activator : a source node's value gates a target node or resource edge —
//             enabled iff value >= factor, otherwise the target does not fire /
//             the edge does not flow.
//
// All conditions read the pre-step snapshot (`state.values`) so results do not
// depend on edge processing order within a step. (Trigger / RateLabel are not
// wired yet.)

///|
/// Sum of Modifier contributions to resource edge `ei`.
fn modifier_bonus(diagram : Diagram, state : SimState, ei : Int) -> Int {
  let mut bonus = 0
  for se in diagram.states {
    if se.kind == Modifier {
      match se.to_edge {
        Some(t) =>
          if t == ei {
            bonus = bonus +
              (state.values[se.from].to_double() * se.factor).to_int()
          }
        None => ()
      }
    }
  }
  bonus
}

///|
/// `base` rate of edge `ei` plus its modifiers, clamped to >= 0.
fn effective_rate(
  diagram : Diagram,
  state : SimState,
  ei : Int,
  base : Int,
) -> Int {
  let w = base + modifier_bonus(diagram, state, ei)
  if w < 0 {
    0
  } else {
    w
  }
}

///|
/// True if any Activator targeting resource edge `ei` is unsatisfied.
fn edge_blocked(diagram : Diagram, state : SimState, ei : Int) -> Bool {
  for se in diagram.states {
    if se.kind == Activator {
      match se.to_edge {
        Some(t) =>
          if t == ei && state.values[se.from].to_double() < se.factor {
            return true
          }
        None => ()
      }
    }
  }
  false
}

///|
/// True if any Activator targeting node `idx` is unsatisfied.
fn node_blocked(diagram : Diagram, state : SimState, idx : Int) -> Bool {
  for se in diagram.states {
    if se.kind == Activator {
      match se.to_node {
        Some(t) =>
          if t == idx && state.values[se.from].to_double() < se.factor {
            return true
          }
        None => ()
      }
    }
  }
  false
}
