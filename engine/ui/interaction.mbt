///|
/// Application-owned availability, shared by presentation, input and snapshots.
/// Selected / drop-target styling cannot make an unavailable action operable.
#derive(Debug, Eq)
pub struct UIInteractionState {
  available : Bool
  selected : Bool
  drop_target : Bool
  disabled_reason : String?
}

///|
pub fn UIInteractionState::new(
  available~ : Bool = true,
  selected~ : Bool = false,
  drop_target~ : Bool = false,
  disabled_reason~ : String? = None,
) -> UIInteractionState {
  {
    available,
    selected: available && selected,
    drop_target: available && drop_target,
    disabled_reason: if available {
      None
    } else {
      disabled_reason
    },
  }
}

///|
/// A disabled child consumes its hit area instead of clicking through to a parent.
pub fn hit_test_interactive(
  layouts : Array[LayoutResult],
  x : Double,
  y : Double,
  state_for : (UINodeId) -> UIInteractionState,
  drop_only~ : Bool = false,
) -> UINodeId? {
  if drop_only {
    for l in layouts {
      if point_in_rect(l.rect, x, y) && state_for(l.node_id).drop_target {
        return Some(l.node_id)
      }
    }
    return None
  }
  hit_test(layouts, x, y).filter(id => state_for(id).available)
}

///|
/// Read only explicitly annotated actions, in paint order. Unavailable actions
/// occlude actions behind them; decorative labels do not intercept input.
pub fn UISnapshot::hit_test(
  self : UISnapshot,
  x : Double,
  y : Double,
  drop_only~ : Bool = false,
) -> UISnapshotNode? {
  for i in 0..<self.nodes.length() {
    let node = self.nodes[self.nodes.length() - 1 - i]
    if !node.visible || node.interaction is None {
      continue
    }
    if drop_only && !node.interaction.unwrap().drop_target {
      continue
    }
    if node.hit is Some(r) &&
      x >= r.left &&
      x < r.left + r.width &&
      y >= r.top &&
      y < r.top + r.height {
      return if node.interaction.unwrap().available { Some(node) } else { None }
    }
  }
  None
}

///|
pub extend UIInteractionState with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UIInteractionState with Eq::{equal, not_equal}
