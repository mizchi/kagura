///|
test "opening a modal cancels active dragging and closing restores the opener" {
  let drag = UIDragController::new()
  let focus = UIFocusManager::new()
  let opener = UINodeId::new(1)
  focus.set_focusable([opener])
  let _ = focus.focus(opener)
  let source = (_, _) => Some(opener)
  let target = (_, _, _) => Some(UINodeId::new(2))
  let _ = drag.handle_pointer(
    UIPointerFrame::new(Mouse, 0.0, 0.0, pressed=true, down=true),
    source_at=source,
    target_at=target,
  )
  let _ = drag.handle_pointer(
    UIPointerFrame::new(Mouse, 20.0, 0.0, down=true),
    source_at=source,
    target_at=target,
  )
  assert_true(drag.snapshot().unwrap().dragging)
  let layer = UIModalLayer::new(drag~, focus~)
  let dialog = UINodeId::new(900)
  let close = UINodeId::new(901)
  assert_true(layer.open(dialog, focusable=[close]))
  assert_true(drag.snapshot() is None)
  let cancelled = layer.drain_events()
  assert_true(cancelled.any(e => e is Drag({ phase: Cancel(Explicit), .. })))
  assert_true(cancelled.any(e => e is Drag({ phase: End(false), .. })))
  assert_eq(layer.drain_events().length(), 0)
  assert_eq(focus.current_focus(), Some(close))
  assert_false(layer.accepts(opener))
  assert_true(layer.accepts(close))
  assert_false(
    layer.interaction(close, UIInteractionState::new(drop_target=true)).drop_target,
  )
  let blocked = layer.interaction(
    opener,
    UIInteractionState::new(selected=true, drop_target=true),
  )
  assert_false(blocked.available || blocked.selected || blocked.drop_target)
  assert_eq(layer.close(Cancel).unwrap().restore_focus, Some(opener))
  assert_eq(focus.current_focus(), Some(opener))
  assert_true(layer.accepts(opener))
}

///|
test "modal pointer scope rejects background clicks and every drop while open" {
  let layer = UIModalLayer::new(drag=UIDragController::new())
  let background = UINodeId::new(1)
  let close = UINodeId::new(901)
  let _ = layer.open(
    UINodeId::new(900),
    focusable=[close],
    backdrop=Some(UINodeId::new(904)),
  )
  assert_true(layer.accepts(UINodeId::new(904)))
  for source in [background, close] {
    let down = layer.handle_pointer(
      UIPointerFrame::new(Mouse, 0.0, 0.0, pressed=true, down=true),
      source_at=(_, _) => Some(source),
      target_at=(_, _, _) => Some(background),
    )
    let up = layer.handle_pointer(
      UIPointerFrame::new(Mouse, 0.0, 0.0, released=true),
      source_at=(_, _) => Some(source),
      target_at=(_, _, _) => Some(background),
    )
    assert_false(down.any(e => e is Drag(_)))
    assert_eq(up.any(e => e is Click(_)), source == close)
  }
  let source = (_, _) => Some(close)
  let target = (_, _, _) => Some(background)
  let _ = layer.handle_pointer(
    UIPointerFrame::new(Mouse, 0.0, 0.0, pressed=true, down=true),
    source_at=source,
    target_at=target,
  )
  let _ = layer.handle_pointer(
    UIPointerFrame::new(Mouse, 20.0, 0.0, down=true),
    source_at=source,
    target_at=target,
  )
  let up = layer.handle_pointer(
    UIPointerFrame::new(Mouse, 20.0, 0.0, released=true),
    source_at=source,
    target_at=target,
  )
  assert_false(up.any(e => e is Drag({ phase: Drop, .. })))
}

///|
test "nested modal layers restore parent scope and its focused child" {
  let layer = UIModalLayer::new(drag=UIDragController::new())
  let _ = layer.open(
    UINodeId::new(900),
    focusable=[901, 902].map(UINodeId::new),
  )
  layer.cycle(1)
  let _ = layer.open(UINodeId::new(910), focusable=[UINodeId::new(911)])
  assert_false(layer.accepts(UINodeId::new(902)))
  let _ = layer.close(Explicit)
  assert_eq(layer.current().unwrap().focused, UINodeId::new(902))
  assert_true(layer.accepts(UINodeId::new(902)))
  let _ = layer.close(Explicit)
  assert_true(layer.current() is None)
}
