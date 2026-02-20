///|
fn approx(a : Double, b : Double) -> Bool {
  (a - b).abs() < 0.01
}

///|
test "UITree add and get node" {
  let tree = UITree::new()
  let style = default_node_style()
  let id = tree.add_node(style, [])
  assert_eq!(tree.node_count(), 1)
  match tree.get_node(id) {
    Some(node) => {
      assert_eq!(node.id.value, id.value)
      assert_eq!(node.children.length(), 0)
    }
    None => fail!("expected node")
  }
}

///|
test "UITree parent-child" {
  let tree = UITree::new()
  let style = default_node_style()
  let child1 = tree.add_node(style, [])
  let child2 = tree.add_node(style, [])
  let parent = tree.add_node(style, [child1, child2])
  assert_eq!(tree.node_count(), 3)
  match tree.get_node(parent) {
    Some(node) => assert_eq!(node.children.length(), 2)
    None => fail!("expected parent")
  }
}

///|
test "default_layout_constraint" {
  let c = default_layout_constraint(800.0, 600.0)
  assert_eq!(c.min_width, 0.0)
  assert_eq!(c.min_height, 0.0)
  assert_eq!(c.max_width, 800.0)
  assert_eq!(c.max_height, 600.0)
}

///|
test "SimpleLayoutEngine single node fixed size" {
  let tree = UITree::new()
  let style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(100.0),
    height: UISizing::Fixed(50.0),
  }
  let root = tree.add_node(style, [])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 1)
  assert_true!(approx(results[0].rect.x, 0.0))
  assert_true!(approx(results[0].rect.y, 0.0))
  assert_true!(approx(results[0].rect.width, 100.0))
  assert_true!(approx(results[0].rect.height, 50.0))
}

///|
test "SimpleLayoutEngine row layout" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(40.0),
    height: UISizing::Fixed(30.0),
  }
  let c1 = tree.add_node(child_style, [])
  let c2 = tree.add_node(child_style, [])
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Row,
    gap: 10.0,
  }
  let root = tree.add_node(parent_style, [c1, c2])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  // Should have 3 results: c1, c2, root
  assert_eq!(results.length(), 3)
  // c1 at x=0
  assert_true!(approx(results[0].rect.x, 0.0))
  assert_true!(approx(results[0].rect.width, 40.0))
  // c2 at x=40+10=50
  assert_true!(approx(results[1].rect.x, 50.0))
  assert_true!(approx(results[1].rect.width, 40.0))
  // root auto-sized: 40+10+40 = 90 wide, 30 tall
  assert_true!(approx(results[2].rect.width, 90.0))
  assert_true!(approx(results[2].rect.height, 30.0))
}

///|
test "SimpleLayoutEngine column layout" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(40.0),
    height: UISizing::Fixed(30.0),
  }
  let c1 = tree.add_node(child_style, [])
  let c2 = tree.add_node(child_style, [])
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Column,
    gap: 5.0,
  }
  let root = tree.add_node(parent_style, [c1, c2])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 3)
  // c1 at y=0
  assert_true!(approx(results[0].rect.y, 0.0))
  // c2 at y=30+5=35
  assert_true!(approx(results[1].rect.y, 35.0))
  // root: 40 wide, 30+5+30 = 65 tall
  assert_true!(approx(results[2].rect.width, 40.0))
  assert_true!(approx(results[2].rect.height, 65.0))
}

///|
test "SimpleLayoutEngine with padding" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(40.0),
    height: UISizing::Fixed(30.0),
  }
  let c1 = tree.add_node(child_style, [])
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    padding_left: 10.0,
    padding_top: 5.0,
    padding_right: 10.0,
    padding_bottom: 5.0,
  }
  let root = tree.add_node(parent_style, [c1])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  // Child should be offset by padding
  assert_true!(approx(results[0].rect.x, 10.0))
  assert_true!(approx(results[0].rect.y, 5.0))
  // Parent auto-size: 10+40+10=60 wide, 5+30+5=40 tall
  assert_true!(approx(results[1].rect.width, 60.0))
  assert_true!(approx(results[1].rect.height, 40.0))
}

///|
test "SimpleUIInputAdapter pointer events" {
  let adapter = SimpleUIInputAdapter::new()
  // First frame: cursor at (100, 200), no buttons
  let snap1 = @core.new_input_snapshot_full(100.0, 200.0, 0.0, 0.0, [], [], [], [])
  let events1 = adapter.from_input_snapshot(snap1)
  // Should have PointerMove since position changed from (0,0)
  assert_eq!(events1.length(), 1)
  // Second frame: mouse button pressed
  let snap2 = @core.new_input_snapshot_full(100.0, 200.0, 0.0, 0.0, [], [0], [], [])
  let events2 = adapter.from_input_snapshot(snap2)
  assert_eq!(events2.length(), 1) // PointerDown
  // Third frame: mouse button released
  let snap3 = @core.new_input_snapshot_full(100.0, 200.0, 0.0, 0.0, [], [], [], [])
  let events3 = adapter.from_input_snapshot(snap3)
  assert_eq!(events3.length(), 1) // PointerUp
}

///|
test "SimpleUIInputAdapter key events" {
  let adapter = SimpleUIInputAdapter::new()
  let snap1 = @core.new_input_snapshot_full(0.0, 0.0, 0.0, 0.0, [65], [], [], [])
  let events1 = adapter.from_input_snapshot(snap1)
  // KeyDown(65)
  let mut has_key_down = false
  for event in events1 {
    match event {
      UIEvent::KeyDown(65) => has_key_down = true
      _ => ()
    }
  }
  assert_true!(has_key_down)
  // Release key
  let snap2 = @core.new_input_snapshot_full(0.0, 0.0, 0.0, 0.0, [], [], [], [])
  let events2 = adapter.from_input_snapshot(snap2)
  let mut has_key_up = false
  for event in events2 {
    match event {
      UIEvent::KeyUp(65) => has_key_up = true
      _ => ()
    }
  }
  assert_true!(has_key_up)
}

///|
test "SimpleUIInputAdapter scroll events" {
  let adapter = SimpleUIInputAdapter::new()
  let snap = @core.new_input_snapshot_full(0.0, 0.0, 1.0, -2.0, [], [], [], [])
  let events = adapter.from_input_snapshot(snap)
  let mut has_scroll = false
  for event in events {
    match event {
      UIEvent::Scroll(_, _) => has_scroll = true
      _ => ()
    }
  }
  assert_true!(has_scroll)
}

///|
test "SimpleUIRenderAdapter produces commands" {
  let shader = @gfx.new_shader_handle(1, "ui_shader")
  let adapter = SimpleUIRenderAdapter::new(shader, 0)
  let frame = @core.new_frame_budget(1, 1.0, 0)
  let target = @gfx.new_image_handle(1, 640, 480)
  let layouts = [
    {
      node_id: { value: 1 },
      rect: { x: 10.0, y: 20.0, width: 100.0, height: 50.0 },
    },
  ]
  let commands = adapter.build_draw_commands(frame, layouts, target)
  assert_eq!(commands.length(), 1)
  assert_eq!(commands[0].vertex_data.length(), 16)
  assert_eq!(commands[0].indices.length(), 6)
}

///|
test "point_in_rect" {
  let rect : LayoutRect = { x: 10.0, y: 20.0, width: 100.0, height: 50.0 }
  assert_true!(point_in_rect(rect, 10.0, 20.0))
  assert_true!(point_in_rect(rect, 50.0, 40.0))
  assert_true!(not(point_in_rect(rect, 9.0, 20.0)))
  assert_true!(not(point_in_rect(rect, 110.0, 20.0)))
  assert_true!(not(point_in_rect(rect, 50.0, 70.0)))
}

///|
test "hit_test finds topmost node" {
  let layouts : Array[LayoutResult] = [
    {
      node_id: { value: 1 },
      rect: { x: 0.0, y: 0.0, width: 200.0, height: 200.0 },
    },
    {
      node_id: { value: 2 },
      rect: { x: 50.0, y: 50.0, width: 100.0, height: 100.0 },
    },
  ]
  // Point inside both -> topmost (node 2)
  match hit_test(layouts, 75.0, 75.0) {
    Some(id) => assert_eq!(id.value, 2)
    None => fail!("expected hit")
  }
  // Point inside only node 1
  match hit_test(layouts, 10.0, 10.0) {
    Some(id) => assert_eq!(id.value, 1)
    None => fail!("expected hit")
  }
  // Point outside all
  match hit_test(layouts, 300.0, 300.0) {
    Some(_) => fail!("expected no hit")
    None => ()
  }
}

///|
test "hit_test_all" {
  let layouts : Array[LayoutResult] = [
    {
      node_id: { value: 1 },
      rect: { x: 0.0, y: 0.0, width: 200.0, height: 200.0 },
    },
    {
      node_id: { value: 2 },
      rect: { x: 50.0, y: 50.0, width: 100.0, height: 100.0 },
    },
  ]
  let all = hit_test_all(layouts, 75.0, 75.0)
  assert_eq!(all.length(), 2)
  assert_eq!(all[0].value, 1)
  assert_eq!(all[1].value, 2)
}

///|
test "UIFocusManager focus and blur" {
  let mgr = UIFocusManager::new()
  mgr.set_focusable([{ value: 1 }, { value: 2 }, { value: 3 }])
  // Initially no focus
  match mgr.current_focus() {
    None => ()
    Some(_) => fail!("expected no focus")
  }
  // Focus node 1
  let events = mgr.focus({ value: 1 })
  assert_eq!(events.length(), 1)
  match events[0] {
    FocusGained(id) => assert_eq!(id.value, 1)
    _ => fail!("expected FocusGained")
  }
  // Focus node 2 (should blur node 1)
  let events2 = mgr.focus({ value: 2 })
  assert_eq!(events2.length(), 2)
  match events2[0] {
    FocusLost(id) => assert_eq!(id.value, 1)
    _ => fail!("expected FocusLost")
  }
  match events2[1] {
    FocusGained(id) => assert_eq!(id.value, 2)
    _ => fail!("expected FocusGained")
  }
  // Focus same node (no events)
  let events3 = mgr.focus({ value: 2 })
  assert_eq!(events3.length(), 0)
  // Blur
  let events4 = mgr.blur()
  assert_eq!(events4.length(), 1)
  match events4[0] {
    FocusLost(id) => assert_eq!(id.value, 2)
    _ => fail!("expected FocusLost")
  }
  // Blur again (no events)
  let events5 = mgr.blur()
  assert_eq!(events5.length(), 0)
}

///|
test "UIFocusManager focus_next and focus_prev" {
  let mgr = UIFocusManager::new()
  let ids : Array[UINodeId] = [{ value: 10 }, { value: 20 }, { value: 30 }]
  mgr.set_focusable(ids)
  // focus_next from no focus -> first
  let e1 = mgr.focus_next()
  assert_eq!(e1.length(), 1)
  match mgr.current_focus() {
    Some(id) => assert_eq!(id.value, 10)
    None => fail!("expected focus")
  }
  // focus_next -> second
  let _ = mgr.focus_next()
  match mgr.current_focus() {
    Some(id) => assert_eq!(id.value, 20)
    None => fail!("expected focus")
  }
  // focus_next -> third
  let _ = mgr.focus_next()
  match mgr.current_focus() {
    Some(id) => assert_eq!(id.value, 30)
    None => fail!("expected focus")
  }
  // focus_next wraps to first
  let _ = mgr.focus_next()
  match mgr.current_focus() {
    Some(id) => assert_eq!(id.value, 10)
    None => fail!("expected focus")
  }
  // focus_prev wraps to last
  let _ = mgr.focus_prev()
  match mgr.current_focus() {
    Some(id) => assert_eq!(id.value, 30)
    None => fail!("expected focus")
  }
}

///|
test "UIFocusManager handle_pointer_down" {
  let mgr = UIFocusManager::new()
  mgr.set_focusable([{ value: 1 }, { value: 2 }])
  let layouts : Array[LayoutResult] = [
    {
      node_id: { value: 1 },
      rect: { x: 0.0, y: 0.0, width: 100.0, height: 100.0 },
    },
    {
      node_id: { value: 2 },
      rect: { x: 100.0, y: 0.0, width: 100.0, height: 100.0 },
    },
  ]
  // Click on node 1
  let e1 = mgr.handle_pointer_down(layouts, 50.0, 50.0)
  assert_eq!(e1.length(), 1)
  match mgr.current_focus() {
    Some(id) => assert_eq!(id.value, 1)
    None => fail!("expected focus")
  }
  // Click on node 2 (blurs 1, focuses 2)
  let e2 = mgr.handle_pointer_down(layouts, 150.0, 50.0)
  assert_eq!(e2.length(), 2)
  match mgr.current_focus() {
    Some(id) => assert_eq!(id.value, 2)
    None => fail!("expected focus")
  }
  // Click outside (blurs)
  let e3 = mgr.handle_pointer_down(layouts, 300.0, 300.0)
  assert_eq!(e3.length(), 1)
  match mgr.current_focus() {
    None => ()
    Some(_) => fail!("expected no focus")
  }
}

///|
test "ui_events_from_input_edge" {
  let key_state = @inpututil.new_key_input_state()
  let mouse_state = @inpututil.new_mouse_input_state()
  // Frame 1: press key 65 and mouse button 0
  let snap1 = @core.new_input_snapshot_full(
    100.0, 200.0, 0.0, 0.0, [65], [0], [], [],
  )
  @inpututil.update_key_input_state(key_state, snap1)
  @inpututil.update_mouse_input_state(mouse_state, snap1)
  let events1 = ui_events_from_input_edge(
    key_state, mouse_state, 100.0, 200.0,
  )
  // Should have KeyDown(65) + PointerDown
  let mut has_key_down = false
  let mut has_pointer_down = false
  for event in events1 {
    match event {
      UIEvent::KeyDown(65) => has_key_down = true
      UIEvent::PointerDown(_, _) => has_pointer_down = true
      _ => ()
    }
  }
  assert_true!(has_key_down)
  assert_true!(has_pointer_down)
  // Frame 2: release both
  let snap2 = @core.new_input_snapshot_full(100.0, 200.0, 0.0, 0.0, [], [], [], [])
  @inpututil.update_key_input_state(key_state, snap2)
  @inpututil.update_mouse_input_state(mouse_state, snap2)
  let events2 = ui_events_from_input_edge(
    key_state, mouse_state, 100.0, 200.0,
  )
  let mut has_key_up = false
  let mut has_pointer_up = false
  for event in events2 {
    match event {
      UIEvent::KeyUp(65) => has_key_up = true
      UIEvent::PointerUp(_, _) => has_pointer_up = true
      _ => ()
    }
  }
  assert_true!(has_key_up)
  assert_true!(has_pointer_up)
  // Frame 3: no changes -> no events
  let snap3 = @core.new_input_snapshot_full(100.0, 200.0, 0.0, 0.0, [], [], [], [])
  @inpututil.update_key_input_state(key_state, snap3)
  @inpututil.update_mouse_input_state(mouse_state, snap3)
  let events3 = ui_events_from_input_edge(
    key_state, mouse_state, 100.0, 200.0,
  )
  assert_eq!(events3.length(), 0)
}

///|
test "justify-content Center" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(30.0),
    height: UISizing::Fixed(20.0),
  }
  let c1 = tree.add_node(child_style, [])
  let c2 = tree.add_node(child_style, [])
  // Parent 200px wide, two 30px children = 60px used, 140px free
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Row,
    width: UISizing::Fixed(200.0),
    height: UISizing::Fixed(100.0),
    justify_content: @layout_types.Alignment::Center,
  }
  let root = tree.add_node(parent_style, [c1, c2])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  // Children centered: start = 70, c1 at 70, c2 at 100
  assert_eq!(results.length(), 3)
  assert_true!(approx(results[0].rect.x, 70.0))
  assert_true!(approx(results[1].rect.x, 100.0))
}

///|
test "justify-content SpaceBetween" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(40.0),
    height: UISizing::Fixed(20.0),
  }
  let c1 = tree.add_node(child_style, [])
  let c2 = tree.add_node(child_style, [])
  let c3 = tree.add_node(child_style, [])
  // Parent 200px wide, three 40px = 120px used, 80px free
  // SpaceBetween: first at 0, gap = 40, items at 0, 80, 160
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Row,
    width: UISizing::Fixed(200.0),
    height: UISizing::Fixed(50.0),
    justify_content: @layout_types.Alignment::SpaceBetween,
  }
  let root = tree.add_node(parent_style, [c1, c2, c3])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 4)
  assert_true!(approx(results[0].rect.x, 0.0))
  assert_true!(approx(results[1].rect.x, 80.0))
  assert_true!(approx(results[2].rect.x, 160.0))
}

///|
test "justify-content End" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(30.0),
    height: UISizing::Fixed(20.0),
  }
  let c1 = tree.add_node(child_style, [])
  // Parent 100px, child 30px, free 70px
  // End: child at 70
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Row,
    width: UISizing::Fixed(100.0),
    height: UISizing::Fixed(50.0),
    justify_content: @layout_types.Alignment::End,
  }
  let root = tree.add_node(parent_style, [c1])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 2)
  assert_true!(approx(results[0].rect.x, 70.0))
}

///|
test "align-items Center (row)" {
  let tree = UITree::new()
  let c1 = tree.add_node(
    { ..default_node_style(), width: UISizing::Fixed(30.0), height: UISizing::Fixed(20.0) },
    [],
  )
  let c2 = tree.add_node(
    { ..default_node_style(), width: UISizing::Fixed(30.0), height: UISizing::Fixed(40.0) },
    [],
  )
  // Row container, 100px tall. Line cross = 40 (tallest child).
  // c1 (20px tall) centered in 40px cross => offset = 10
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Row,
    width: UISizing::Fixed(200.0),
    height: UISizing::Fixed(100.0),
    align: @layout_types.Alignment::Center,
  }
  let root = tree.add_node(parent_style, [c1, c2])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 3)
  // c1 y = 0 + (40-20)/2 = 10
  assert_true!(approx(results[0].rect.y, 10.0))
  // c2 y = 0 (tallest, no offset)
  assert_true!(approx(results[1].rect.y, 0.0))
}

///|
test "align-items End (column)" {
  let tree = UITree::new()
  let c1 = tree.add_node(
    { ..default_node_style(), width: UISizing::Fixed(30.0), height: UISizing::Fixed(20.0) },
    [],
  )
  let c2 = tree.add_node(
    { ..default_node_style(), width: UISizing::Fixed(50.0), height: UISizing::Fixed(20.0) },
    [],
  )
  // Column container, cross axis = width. Line cross = 50 (widest).
  // c1 (30px) End aligned: offset = 50 - 30 = 20
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Column,
    width: UISizing::Fixed(200.0),
    height: UISizing::Fixed(100.0),
    align: @layout_types.Alignment::End,
  }
  let root = tree.add_node(parent_style, [c1, c2])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 3)
  // c1 x = 0 + (50 - 30) = 20
  assert_true!(approx(results[0].rect.x, 20.0))
  // c2 x = 0 (widest)
  assert_true!(approx(results[1].rect.x, 0.0))
}

///|
test "flex-wrap Wrap" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(60.0),
    height: UISizing::Fixed(30.0),
  }
  let c1 = tree.add_node(child_style, [])
  let c2 = tree.add_node(child_style, [])
  let c3 = tree.add_node(child_style, [])
  // Container 150px wide. 60+60=120 fits, 60+60+60=180 doesn't.
  // So line 1: c1, c2 (120px). Line 2: c3 (60px).
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Row,
    width: UISizing::Fixed(150.0),
    height: UISizing::Fixed(100.0),
    flex_wrap: UIFlexWrap::Wrap,
  }
  let root = tree.add_node(parent_style, [c1, c2, c3])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 4)
  // Line 1: c1 at (0, 0), c2 at (60, 0)
  assert_true!(approx(results[0].rect.x, 0.0))
  assert_true!(approx(results[0].rect.y, 0.0))
  assert_true!(approx(results[1].rect.x, 60.0))
  assert_true!(approx(results[1].rect.y, 0.0))
  // Line 2: c3 at (0, 30)
  assert_true!(approx(results[2].rect.x, 0.0))
  assert_true!(approx(results[2].rect.y, 30.0))
}

///|
test "flex-wrap with gap" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(40.0),
    height: UISizing::Fixed(20.0),
  }
  let c1 = tree.add_node(child_style, [])
  let c2 = tree.add_node(child_style, [])
  let c3 = tree.add_node(child_style, [])
  // Container 100px wide, gap 10. 40+10+40=90 fits, +10+40=140 doesn't.
  // Line 1: c1, c2. Line 2: c3.
  // Cross gap between lines = 10.
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Row,
    width: UISizing::Fixed(100.0),
    height: UISizing::Fixed(80.0),
    gap: 10.0,
    flex_wrap: UIFlexWrap::Wrap,
  }
  let root = tree.add_node(parent_style, [c1, c2, c3])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 4)
  // Line 1: c1 at (0,0), c2 at (50, 0)
  assert_true!(approx(results[0].rect.x, 0.0))
  assert_true!(approx(results[1].rect.x, 50.0))
  // Line 2: c3 at (0, 30) (20 height + 10 gap)
  assert_true!(approx(results[2].rect.y, 30.0))
}

///|
test "flex-wrap with justify-content and align-items" {
  let tree = UITree::new()
  let c1 = tree.add_node(
    { ..default_node_style(), width: UISizing::Fixed(40.0), height: UISizing::Fixed(20.0) },
    [],
  )
  let c2 = tree.add_node(
    { ..default_node_style(), width: UISizing::Fixed(40.0), height: UISizing::Fixed(30.0) },
    [],
  )
  let c3 = tree.add_node(
    { ..default_node_style(), width: UISizing::Fixed(40.0), height: UISizing::Fixed(15.0) },
    [],
  )
  // Container 100px wide, wrap. Line 1: c1+c2 (80px, cross=30). Line 2: c3 (40px, cross=15).
  // justify: Center, align: Center
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Row,
    width: UISizing::Fixed(100.0),
    height: UISizing::Fixed(100.0),
    flex_wrap: UIFlexWrap::Wrap,
    justify_content: @layout_types.Alignment::Center,
    align: @layout_types.Alignment::Center,
  }
  let root = tree.add_node(parent_style, [c1, c2, c3])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 4)
  // Line 1: free_main = 100 - 80 = 20, center => start = 10
  // c1 at x=10, c2 at x=50
  assert_true!(approx(results[0].rect.x, 10.0))
  assert_true!(approx(results[1].rect.x, 50.0))
  // Line 1 cross = 30. c1 (20px) centered: y = (30-20)/2 = 5
  assert_true!(approx(results[0].rect.y, 5.0))
  // c2 (30px) fills line cross: y = 0
  assert_true!(approx(results[1].rect.y, 0.0))
  // Line 2: free_main = 100 - 40 = 60, center => start = 30
  // c3 at x=30, y=30 (line1 cross)
  assert_true!(approx(results[2].rect.x, 30.0))
  assert_true!(approx(results[2].rect.y, 30.0))
}

///|
test "UIFocusManager focus_next empty focusable_ids" {
  let mgr = UIFocusManager::new()
  // No focusable nodes set
  let events = mgr.focus_next()
  assert_eq!(events.length(), 0)
  match mgr.current_focus() {
    None => ()
    Some(_) => fail!("expected no focus")
  }
}

///|
test "UIFocusManager focus_prev empty focusable_ids" {
  let mgr = UIFocusManager::new()
  let events = mgr.focus_prev()
  assert_eq!(events.length(), 0)
  match mgr.current_focus() {
    None => ()
    Some(_) => fail!("expected no focus")
  }
}

///|
test "UIFocusManager handle_pointer_down non-focusable node" {
  let mgr = UIFocusManager::new()
  // node 1 is focusable, node 2 is not
  mgr.set_focusable([{ value: 1 }])
  let layouts : Array[LayoutResult] = [
    {
      node_id: { value: 1 },
      rect: { x: 0.0, y: 0.0, width: 100.0, height: 100.0 },
    },
    {
      node_id: { value: 2 },
      rect: { x: 100.0, y: 0.0, width: 100.0, height: 100.0 },
    },
  ]
  // Focus node 1 first
  let _ = mgr.handle_pointer_down(layouts, 50.0, 50.0)
  match mgr.current_focus() {
    Some(id) => assert_eq!(id.value, 1)
    None => fail!("expected focus on 1")
  }
  // Click on non-focusable node 2 -> should blur
  let e = mgr.handle_pointer_down(layouts, 150.0, 50.0)
  assert_eq!(e.length(), 1) // FocusLost(1)
  match mgr.current_focus() {
    None => ()
    Some(_) => fail!("expected no focus after clicking non-focusable")
  }
}

///|
test "hit_test empty layouts" {
  let layouts : Array[LayoutResult] = []
  match hit_test(layouts, 50.0, 50.0) {
    None => ()
    Some(_) => fail!("expected no hit on empty layouts")
  }
  let all = hit_test_all(layouts, 50.0, 50.0)
  assert_eq!(all.length(), 0)
}

///|
test "point_in_rect boundary and zero-size" {
  let rect : LayoutRect = { x: 10.0, y: 20.0, width: 100.0, height: 50.0 }
  // Exactly on right edge (exclusive)
  assert_true!(not(point_in_rect(rect, 110.0, 20.0)))
  // Exactly on bottom edge (exclusive)
  assert_true!(not(point_in_rect(rect, 50.0, 70.0)))
  // Zero-size rect
  let zero_rect : LayoutRect = { x: 5.0, y: 5.0, width: 0.0, height: 0.0 }
  assert_true!(not(point_in_rect(zero_rect, 5.0, 5.0)))
  // Negative coordinates
  let neg_rect : LayoutRect = { x: -10.0, y: -10.0, width: 20.0, height: 20.0 }
  assert_true!(point_in_rect(neg_rect, 0.0, 0.0))
  assert_true!(point_in_rect(neg_rect, -10.0, -10.0))
  assert_true!(not(point_in_rect(neg_rect, 10.0, 10.0)))
}

///|
test "SimpleLayoutEngine Percent sizing" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Percent(50.0),
    height: UISizing::Percent(25.0),
  }
  let c1 = tree.add_node(child_style, [])
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(200.0),
    height: UISizing::Fixed(100.0),
  }
  let root = tree.add_node(parent_style, [c1])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 2)
  // Child: 50% of 200 = 100, 25% of 100 = 25
  assert_true!(approx(results[0].rect.width, 100.0))
  assert_true!(approx(results[0].rect.height, 25.0))
}

///|
test "SimpleLayoutEngine asymmetric padding" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(30.0),
    height: UISizing::Fixed(20.0),
  }
  let c1 = tree.add_node(child_style, [])
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    padding_left: 5.0,
    padding_top: 10.0,
    padding_right: 15.0,
    padding_bottom: 20.0,
  }
  let root = tree.add_node(parent_style, [c1])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  // Child offset by padding_left, padding_top
  assert_true!(approx(results[0].rect.x, 5.0))
  assert_true!(approx(results[0].rect.y, 10.0))
  // Parent auto-size: 5+30+15=50, 10+20+20=50
  assert_true!(approx(results[1].rect.width, 50.0))
  assert_true!(approx(results[1].rect.height, 50.0))
}

///|
test "UITree get_node non-existent" {
  let tree = UITree::new()
  match tree.get_node({ value: 999 }) {
    None => ()
    Some(_) => fail!("expected None for non-existent node")
  }
}

///|
test "SimpleUIInputAdapter simultaneous buttons and keys" {
  let adapter = SimpleUIInputAdapter::new()
  // Press two keys and two mouse buttons at once
  let snap = @core.new_input_snapshot_full(
    50.0, 60.0, 0.0, 0.0, [65, 66], [0, 2], [], [],
  )
  let events = adapter.from_input_snapshot(snap)
  let mut pointer_moves = 0
  let mut pointer_downs = 0
  let mut key_downs = 0
  for event in events {
    match event {
      UIEvent::PointerMove(_, _) => pointer_moves = pointer_moves + 1
      UIEvent::PointerDown(_, _) => pointer_downs = pointer_downs + 1
      UIEvent::KeyDown(_) => key_downs = key_downs + 1
      _ => ()
    }
  }
  assert_true!(pointer_moves >= 1) // cursor moved from (0,0)
  assert_eq!(pointer_downs, 2) // two mouse buttons pressed
  assert_eq!(key_downs, 2) // two keys pressed
}

///|
test "SimpleUIRenderAdapter multiple nodes" {
  let shader = @gfx.new_shader_handle(1, "ui_shader")
  let adapter = SimpleUIRenderAdapter::new(shader, 0)
  let frame = @core.new_frame_budget(1, 1.0, 0)
  let target = @gfx.new_image_handle(1, 640, 480)
  let layouts = [
    {
      node_id: { value: 1 },
      rect: { x: 0.0, y: 0.0, width: 100.0, height: 50.0 },
    },
    {
      node_id: { value: 2 },
      rect: { x: 100.0, y: 0.0, width: 50.0, height: 50.0 },
    },
    {
      node_id: { value: 3 },
      rect: { x: 0.0, y: 50.0, width: 200.0, height: 30.0 },
    },
  ]
  let commands = adapter.build_draw_commands(frame, layouts, target)
  assert_eq!(commands.length(), 3)
  for cmd in commands {
    assert_eq!(cmd.vertex_data.length(), 16)
    assert_eq!(cmd.indices.length(), 6)
  }
}

///|
test "justify-content SpaceAround" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(20.0),
    height: UISizing::Fixed(20.0),
  }
  let c1 = tree.add_node(child_style, [])
  let c2 = tree.add_node(child_style, [])
  // Parent 100px wide, two 20px children = 40px, free = 60px
  // SpaceAround: space = 60/4 = 15 at half-edges, 30 between
  // c1 at 15, c2 at 15+20+30 = 65
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Row,
    width: UISizing::Fixed(100.0),
    height: UISizing::Fixed(50.0),
    justify_content: @layout_types.Alignment::SpaceAround,
  }
  let root = tree.add_node(parent_style, [c1, c2])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 3)
  // c1 at x=15 (half-space)
  assert_true!(approx(results[0].rect.x, 15.0))
  // c2 at x=65
  assert_true!(approx(results[1].rect.x, 65.0))
}

///|
test "justify-content Column direction" {
  let tree = UITree::new()
  let child_style : UINodeStyle = {
    ..default_node_style(),
    width: UISizing::Fixed(40.0),
    height: UISizing::Fixed(20.0),
  }
  let c1 = tree.add_node(child_style, [])
  let c2 = tree.add_node(child_style, [])
  // Column 100px tall, two 20px children = 40px, free = 60px
  // SpaceAround: gap = 60/3 = 20, items at 20, 60
  // Actually SpaceAround puts space/2 at edges: 10, then item, gap=30, item, 10
  // Let me use Center instead: start = 30
  let parent_style : UINodeStyle = {
    ..default_node_style(),
    direction: UIDirection::Column,
    width: UISizing::Fixed(40.0),
    height: UISizing::Fixed(100.0),
    justify_content: @layout_types.Alignment::Center,
  }
  let root = tree.add_node(parent_style, [c1, c2])
  let engine = SimpleLayoutEngine::new(tree)
  let results = engine.compute_layout(root, default_layout_constraint(800.0, 600.0))
  assert_eq!(results.length(), 3)
  // Center: free=60, start=30. c1 at y=30, c2 at y=50
  assert_true!(approx(results[0].rect.y, 30.0))
  assert_true!(approx(results[1].rect.y, 50.0))
}
