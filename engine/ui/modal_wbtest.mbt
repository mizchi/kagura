///|
test "modal confines focus and restores its opener" {
  let modals = UIModalController::new()
  let dialog = UINodeId::new(10)
  let opener = UINodeId::new(1)
  let first = UINodeId::new(11)
  let second = UINodeId::new(12)
  let _ = modals.open(dialog, opener=Some(opener), focusable=[first, second])
  assert_eq(modals.current().unwrap().focused, first)
  assert_false(modals.focus(opener))
  assert_true(modals.focus(second))
  modals.cycle(1)
  assert_eq(modals.current().unwrap().focused, first)
  let closed = modals.close(Explicit)
  assert_eq(closed.unwrap().restore_focus, Some(opener))
  assert_true(modals.current() is None)
  assert_true(modals.close(Explicit) is None)
}

///|
test "nested popup closes only the top and retains parent focus" {
  let modals = UIModalController::new()
  let _ = modals.open(UINodeId::new(10), focusable=[UINodeId::new(11)])
  let _ = modals.open(UINodeId::new(20), opener=Some(UINodeId::new(11)))
  assert_false(modals.accepts(UINodeId::new(10)))
  assert_true(modals.accepts(UINodeId::new(20)))
  assert_false(modals.open(UINodeId::new(20)))
  assert_eq(modals.close(Cancel).unwrap().id.value, 20)
  assert_eq(modals.current().unwrap().id.value, 10)
  assert_eq(modals.current().unwrap().focused.value, 11)
}

///|
test "modal owns copies of the focus contract and handles an empty list" {
  let modals = UIModalController::new()
  let ids = [UINodeId::new(11)]
  let _ = modals.open(UINodeId::new(10), focusable=ids)
  ids.clear()
  modals.cycle(-1)
  assert_eq(modals.current().unwrap().focused.value, 11)
  let snapshot = modals.current().unwrap()
  snapshot.focusable.clear()
  assert_true(modals.focus(UINodeId::new(11)))
}
