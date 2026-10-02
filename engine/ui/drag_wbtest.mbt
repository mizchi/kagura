///|
fn drag_input(x : Double, y : Double, down : Bool) -> @core.InputSnapshot {
  @core.new_input_snapshot_full(
    x,
    y,
    0.0,
    0.0,
    [],
    if down {
      [0]
    } else {
      []
    },
    [],
    [],
  )
}

///|
fn drag_source(x : Double, y : Double) -> UINodeId? {
  if x >= 0.0 && x < 40.0 && y >= 0.0 && y < 40.0 {
    Some(UINodeId::new(10))
  } else {
    None
  }
}

///|
fn drag_target(_source : UINodeId, x : Double, _y : Double) -> UINodeId? {
  if x >= 100.0 && x < 140.0 {
    Some(UINodeId::new(20))
  } else if x >= 140.0 && x < 180.0 {
    Some(UINodeId::new(30))
  } else {
    None
  }
}

///|
fn drag_update(
  controller : UIDragController,
  x : Double,
  y : Double,
  down : Bool,
) -> Array[UIEvent] {
  controller.update(
    drag_input(x, y, down),
    source_at=drag_source,
    target_at=drag_target,
  )
}

///|
fn drag_phases(events : Array[UIEvent]) -> Array[UIDragPhase] {
  let phases = []
  for event in events {
    if event is Drag(drag) {
      phases.push(drag.phase)
    }
  }
  phases
}

///|
test "drag captures a source and starts only after the movement threshold" {
  let controller = UIDragController::new()
  assert_eq(drag_phases(drag_update(controller, 10.0, 10.0, true)).length(), 0)
  assert_false(controller.snapshot().unwrap().dragging)
  assert_eq(drag_phases(drag_update(controller, 17.0, 10.0, true)).length(), 0)
  assert_eq(drag_phases(drag_update(controller, 18.0, 10.0, true)), [
    Start,
    Move,
  ])
  assert_eq(controller.snapshot().unwrap().source.value, 10)
}

///|
test "clicking a draggable emits click without any drag or drop" {
  let controller = UIDragController::new()
  let _ = drag_update(controller, 10.0, 10.0, true)
  let events = drag_update(controller, 12.0, 10.0, false)
  assert_eq(drag_phases(events).length(), 0)
  assert_true(
    events.any(e => {
      match e {
        Click(id) => id.value == 10
        _ => false
      }
    }),
  )
  assert_true(controller.snapshot() is None)
}

///|
test "target changes emit leave before enter and release drops exactly once" {
  let controller = UIDragController::new()
  let _ = drag_update(controller, 10.0, 10.0, true)
  assert_eq(drag_phases(drag_update(controller, 110.0, 10.0, true)), [
    Start,
    Enter,
    Move,
  ])
  assert_eq(drag_phases(drag_update(controller, 150.0, 10.0, true)), [
    Leave,
    Enter,
    Move,
  ])
  assert_eq(drag_phases(drag_update(controller, 150.0, 10.0, false)), [
    Drop,
    End(true),
  ])
  assert_eq(
    drag_phases(drag_update(controller, 150.0, 10.0, false)).length(),
    0,
  )
  assert_true(controller.snapshot() is None)
}

///|
test "release coordinates choose the final target even without a move tick" {
  let controller = UIDragController::new()
  let _ = drag_update(controller, 10.0, 10.0, true)
  let _ = drag_update(controller, 110.0, 10.0, true)
  let events = drag_update(controller, 150.0, 10.0, false)
  assert_eq(drag_phases(events), [Leave, Enter, Move, Drop, End(true)])
  assert_true(
    events.any(e => {
      match e {
        Drag({ phase: Drop, target: Some(id), .. }) => id.value == 30
        _ => false
      }
    }),
  )
}

///|
test "a rejected or outside drop cancels and ends without dropping" {
  let controller = UIDragController::new()
  let _ = drag_update(controller, 10.0, 10.0, true)
  let _ = drag_update(controller, 60.0, 10.0, true)
  assert_eq(drag_phases(drag_update(controller, 60.0, 10.0, false)), [
    Cancel(NoTarget),
    End(false),
  ])
}

///|
test "explicit cancellation ends the gesture and is idempotent" {
  let controller = UIDragController::new()
  let _ = drag_update(controller, 10.0, 10.0, true)
  let _ = drag_update(controller, 110.0, 10.0, true)
  assert_eq(drag_phases(controller.cancel()), [
    Leave,
    Cancel(Explicit),
    End(false),
  ])
  assert_eq(controller.cancel().length(), 0)
  assert_eq(
    drag_phases(drag_update(controller, 110.0, 10.0, false)).length(),
    0,
  )
}

///|
test "disabled interaction consumes edges and cannot begin a held drag later" {
  let controller = UIDragController::new()
  let _ = controller.update(
    drag_input(10.0, 10.0, true),
    source_at=drag_source,
    target_at=drag_target,
    enabled=false,
  )
  let _ = drag_update(controller, 110.0, 10.0, true)
  assert_true(controller.snapshot() is None)
  assert_eq(
    drag_phases(drag_update(controller, 110.0, 10.0, false)).length(),
    0,
  )
}
