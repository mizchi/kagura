///|
struct UIDragGesture {
  source : UINodeId
  pointer : UIPointerId
  start_x : Double
  start_y : Double
  mut x : Double
  mut y : Double
  mut target : UINodeId?
  mut dragging : Bool
}

///|
pub struct UIDragController {
  input : UIPointerInputAdapter
  threshold : Double
  mut gesture : UIDragGesture?
}

///|
pub fn UIDragController::new(threshold? : Double = 8.0) -> UIDragController {
  {
    input: UIPointerInputAdapter::new(),
    threshold: if threshold >= 0.0 {
      threshold
    } else {
      8.0
    },
    gesture: None,
  }
}

///|
pub fn UIDragController::pointer(self : UIDragController) -> UIPointerFrame {
  self.input.pointer()
}

///|
pub fn UIDragController::snapshot(self : UIDragController) -> UIDragSnapshot? {
  self.gesture.map(g => {
    source: g.source,
    target: g.target,
    pointer: g.pointer,
    start_x: g.start_x,
    start_y: g.start_y,
    x: g.x,
    y: g.y,
    dragging: g.dragging,
  })
}

///|
fn drag_event(g : UIDragGesture, phase : UIDragPhase) -> UIEvent {
  Drag({
    phase,
    source: g.source,
    target: g.target,
    pointer: g.pointer,
    start_x: g.start_x,
    start_y: g.start_y,
    x: g.x,
    y: g.y,
  })
}

///|
/// Cancels a pending press or active drag. A started drag always ends once.
pub fn UIDragController::cancel(
  self : UIDragController,
  reason? : UIDragCancelReason = Explicit,
) -> Array[UIEvent] {
  let events = []
  if self.gesture is Some(g) {
    self.gesture = None
    if g.dragging && g.target is Some(_) {
      events.push(drag_event(g, Leave))
    }
    events.push(drag_event(g, Cancel(reason)))
    if g.dragging {
      events.push(drag_event(g, End(false)))
    }
  }
  events
}

///|
fn UIDragController::track_position(
  self : UIDragController,
  g : UIDragGesture,
  x : Double,
  y : Double,
  target_at : (UINodeId, Double, Double) -> UINodeId?,
  events : Array[UIEvent],
) -> Unit {
  let moved = g.x != x || g.y != y
  g.x = x
  g.y = y
  let dx = x - g.start_x
  let dy = y - g.start_y
  let starting = !g.dragging &&
    dx * dx + dy * dy >= self.threshold * self.threshold &&
    (moved || self.threshold == 0.0)
  if starting {
    g.dragging = true
    events.push(drag_event(g, Start))
  }
  if !g.dragging {
    return
  }
  let target = target_at(g.source, x, y)
  if target != g.target {
    if g.target is Some(_) {
      events.push(drag_event(g, Leave))
    }
    g.target = target
    if target is Some(_) {
      events.push(drag_event(g, Enter))
    }
  }
  if moved || starting {
    events.push(drag_event(g, Move))
  }
}

///|
/// UI-only policy: source_at selects a draggable identity; target_at returns
/// the topmost accepting target or None. The caller owns payloads and rules.
/// Edges are consumed even when disabled, avoiding held-input reactivation.
pub fn UIDragController::update(
  self : UIDragController,
  input : @core.InputSnapshot,
  source_at~ : (Double, Double) -> UINodeId?,
  target_at~ : (UINodeId, Double, Double) -> UINodeId?,
  enabled? : Bool = true,
) -> Array[UIEvent] {
  let events = self.input.from_input_snapshot(input)
  for
    event in self.handle_pointer(
      self.input.pointer(),
      source_at~,
      target_at~,
      enabled~,
    ) {
    events.push(event)
  }
  events
}

///|
/// Recognition is independent from InputSnapshot/host acquisition.
pub fn UIDragController::handle_pointer(
  self : UIDragController,
  frame : UIPointerFrame,
  source_at~ : (Double, Double) -> UINodeId?,
  target_at~ : (UINodeId, Double, Double) -> UINodeId?,
  enabled? : Bool = true,
) -> Array[UIEvent] {
  let events : Array[UIEvent] = []
  if !enabled {
    for event in self.cancel(reason=Disabled) {
      events.push(event)
    }
    return events
  }
  if frame.cancelled {
    if self.gesture is Some(g) && g.pointer == frame.pointer {
      for event in self.cancel(reason=InputCancelled) {
        events.push(event)
      }
    }
    return events
  }
  if frame.pressed && self.gesture is None {
    if source_at(frame.x, frame.y) is Some(source) {
      self.gesture = Some({
        source,
        pointer: frame.pointer,
        start_x: frame.x,
        start_y: frame.y,
        x: frame.x,
        y: frame.y,
        target: None,
        dragging: false,
      })
    }
  }
  if self.gesture is Some(g) && g.pointer == frame.pointer {
    if frame.down || frame.released {
      self.track_position(g, frame.x, frame.y, target_at, events)
    }
    if frame.released {
      self.gesture = None
      if !g.dragging {
        events.push(Click(g.source))
      } else if g.target is Some(_) {
        events.push(drag_event(g, Drop))
        events.push(drag_event(g, End(true)))
      } else {
        events.push(drag_event(g, Cancel(NoTarget)))
        events.push(drag_event(g, End(false)))
      }
    }
  }
  events
}
