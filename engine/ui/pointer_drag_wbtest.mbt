///|
fn touch_drag_input(touches : Array[@core.TouchPoint]) -> @core.InputSnapshot {
  @core.new_input_snapshot_full(-1.0, -1.0, 0.0, 0.0, [], [], touches, [])
}

///|
test "touch input cannot steal a mouse gesture before mouse release" {
  let controller = UIDragController::new()
  let _ = drag_update(controller, 10.0, 10.0, true)
  let _ = drag_update(controller, 110.0, 10.0, true)
  let other_touch = [@core.new_touch_point(8, 150.0, 10.0)]
  let _ = controller.update(
    @core.new_input_snapshot_full(110.0, 10.0, 0.0, 0.0, [], [0], other_touch, []),
    source_at=drag_source,
    target_at=drag_target,
  )
  assert_eq(controller.pointer().pointer, Mouse)
  assert_eq(controller.snapshot().unwrap().target.unwrap().value, 20)
  let events = controller.update(
    @core.new_input_snapshot_full(110.0, 10.0, 0.0, 0.0, [], [], other_touch, []),
    source_at=drag_source,
    target_at=drag_target,
  )
  assert_eq(drag_phases(events), [Drop, End(true)])
}

///|
test "touch dragging keeps the owning finger and releases at its last position" {
  let controller = UIDragController::new()
  let _ = controller.update(
    touch_drag_input([@core.new_touch_point(7, 10.0, 10.0)]),
    source_at=drag_source,
    target_at=drag_target,
  )
  let _ = controller.update(
    touch_drag_input([
      @core.new_touch_point(8, 150.0, 10.0),
      @core.new_touch_point(7, 110.0, 10.0),
    ]),
    source_at=drag_source,
    target_at=drag_target,
  )
  assert_eq(controller.snapshot().unwrap().pointer, Touch(7))
  assert_eq(controller.snapshot().unwrap().target.unwrap().value, 20)
  let released = controller.update(
    touch_drag_input([@core.new_touch_point(8, 150.0, 10.0)]),
    source_at=drag_source,
    target_at=drag_target,
  )
  assert_eq(drag_phases(released), [Drop, End(true)])
  assert_true(
    released.any(e => {
      match e {
        Drag({ phase: Drop, pointer: Touch(7), x: 110.0, .. }) => true
        _ => false
      }
    }),
  )
  let _ = controller.update(
    touch_drag_input([@core.new_touch_point(8, 10.0, 10.0)]),
    source_at=drag_source,
    target_at=drag_target,
  )
  assert_true(controller.snapshot() is None)
}

///|
test "another pointer cannot move release or cancel a captured gesture" {
  let controller = UIDragController::new()
  let _ = controller.handle_pointer(
    UIPointerFrame::new(Touch(7), 10.0, 10.0, pressed=true, down=true),
    source_at=drag_source,
    target_at=drag_target,
  )
  let _ = controller.handle_pointer(
    UIPointerFrame::new(Touch(7), 110.0, 10.0, down=true),
    source_at=drag_source,
    target_at=drag_target,
  )
  for
    frame in [
      UIPointerFrame::new(Touch(8), 150.0, 10.0, down=true),
      UIPointerFrame::new(Touch(8), 150.0, 10.0, released=true),
      UIPointerFrame::new(Touch(8), 150.0, 10.0, cancelled=true),
    ] {
    assert_eq(
      controller
      .handle_pointer(frame, source_at=drag_source, target_at=drag_target)
      .length(),
      0,
    )
  }
  assert_eq(controller.snapshot().unwrap().target.unwrap().value, 20)
}

///|
test "zero threshold starts immediately and custom threshold delays recognition" {
  let immediate = UIDragController::new(threshold=0.0)
  assert_eq(drag_phases(drag_update(immediate, 10.0, 10.0, true)), [Start, Move])
  let delayed = UIDragController::new(threshold=20.0)
  let _ = drag_update(delayed, 10.0, 10.0, true)
  assert_eq(drag_phases(drag_update(delayed, 29.0, 10.0, true)).length(), 0)
  assert_eq(drag_phases(drag_update(delayed, 30.0, 10.0, true)), [Start, Move])
}

///|
test "Escape and secondary buttons cancel without turning release into a click" {
  for
    cancel_input in [
      @core.new_input_snapshot_full(110.0, 10.0, 0.0, 0.0, [27], [0], [], []),
      @core.new_input_snapshot_full(110.0, 10.0, 0.0, 0.0, [256], [0], [], []),
      @core.new_input_snapshot_full(110.0, 10.0, 0.0, 0.0, [], [0, 2], [], []),
    ] {
    let controller = UIDragController::new()
    let _ = drag_update(controller, 10.0, 10.0, true)
    let _ = drag_update(controller, 110.0, 10.0, true)
    let events = controller.update(
      cancel_input,
      source_at=drag_source,
      target_at=drag_target,
    )
    assert_eq(drag_phases(events), [Leave, Cancel(InputCancelled), End(false)])
    assert_eq(
      drag_phases(drag_update(controller, 110.0, 10.0, false)).length(),
      0,
    )
  }
}

///|
test "drop policy filters a geometrically present but rejected target" {
  let controller = UIDragController::new()
  let _ = drag_update(controller, 10.0, 10.0, true)
  let events = controller.update(
    drag_input(110.0, 10.0, false),
    source_at=drag_source,
    target_at=fn(_, _, _) { None },
  )
  assert_eq(drag_phases(events), [Start, Move, Cancel(NoTarget), End(false)])
}

///|
test "events and snapshots keep their original values as the gesture advances" {
  let controller = UIDragController::new()
  let _ = drag_update(controller, 10.0, 10.0, true)
  let entered = drag_update(controller, 110.0, 10.0, true)
  let old = controller.snapshot().unwrap()
  let _ = drag_update(controller, 150.0, 10.0, true)
  assert_eq(old.x, 110.0)
  assert_eq(old.target.unwrap().value, 20)
  assert_true(
    entered.any(e => {
      match e {
        Drag({ phase: Enter, target: Some(id), .. }) => id.value == 20
        _ => false
      }
    }),
  )
}

///|
test "a stationary pointer retargets when acceptance or layout changes" {
  let controller = UIDragController::new()
  let _ = drag_update(controller, 10.0, 10.0, true)
  let _ = drag_update(controller, 110.0, 10.0, true)
  let events = controller.update(
    drag_input(110.0, 10.0, true),
    source_at=drag_source,
    target_at=fn(_, _, _) { None },
  )
  assert_eq(drag_phases(events), [Leave])
  assert_true(controller.snapshot().unwrap().target is None)
}

///|
test "independent controllers do not share capture or pointer coordinates" {
  let first = UIDragController::new()
  let second = UIDragController::new()
  let _ = drag_update(first, 10.0, 10.0, true)
  let _ = drag_update(first, 110.0, 10.0, true)
  let _ = drag_update(second, 20.0, 10.0, true)
  assert_true(first.snapshot().unwrap().dragging)
  assert_false(second.snapshot().unwrap().dragging)
  assert_eq(second.pointer().x, 20.0)
}
