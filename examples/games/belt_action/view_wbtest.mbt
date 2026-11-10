///|
test "elite defense and counter openings are announced in the rendered game" {
  let g = @sim.new_game()
  g.start()
  g.enemies.clear()
  g.spawn(3, 400, 372)
  let e = g.enemies[0]
  e.action = "windup"
  let braced = @scene.ui_snapshot_from_scene(
    view(g),
    screen_width=960,
    screen_height=540,
  )
  assert_true(braced.nodes.any(n => n.text == Some("BRACED")))
  assert_true(
    braced.nodes.any(n => {
      n.id == "attack-lane-\{e.id}" &&
      n.height == e.attack_depth() * 2 &&
      n.top == e.aim_z - e.attack_depth()
    }),
  )
  e.action = "recover"
  let open = @scene.ui_snapshot_from_scene(
    view(g),
    screen_width=960,
    screen_height=540,
  )
  assert_true(open.nodes.any(n => n.text == Some("OPEN")))
  assert_false(open.nodes.any(n => n.text == Some("BRACED")))
}
