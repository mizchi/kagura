///|
test "authored wave order and variable enemy counts retain stable combat indices" {
  let recipe : Json = {
    "bounds": [-60, 60, -60, 60],
    "spawn": [0, 0, -40],
    "solids": [],
    "targets": [
      { "id": "alpha", "position": [-10, 0, 10], "yaw": 1 },
      { "id": "beta", "position": [10, 0, 10], "yaw": 2 },
      { "id": "scout", "position": [0, 0, 20], "yaw": 3 },
    ],
    "waves": [[2], [0, 1]],
    "timeLimit": 30,
    "fov": 70,
    "sky": 0xb5cbd3,
    "sun": 2,
    "action": {
      "cooldown": 0.2,
      "damage": 180,
      "flashDuration": 0.04,
      "flashColor": 0xffffff,
      "recoilDuration": 0.1,
      "recoilStrength": 0.08,
      "shotSound": "rifle",
      "hitSound": "hit",
    },
  }
  let g = game_from_scene(recipe.stringify(), true)
  start_playing(g)
  assert_eq(g.units.length(), 1)
  assert_eq(g.units[0].name, "scout")
  assert_eq(g.units[0].yaw, 3.0)
  g.units[0].hp = 0.0
  finish_mission(g, 0.1)
  assert_eq(g.wave, 1)
  assert_eq(g.phase, "playing")
  assert_eq(g.units.length(), 3)
  assert_eq(g.units[1].name, "alpha")
  assert_eq(g.units[2].name, "beta")
  for index, unit in g.units {
    assert_eq(unit.id, index)
    unit.hp = 0.0
  }
  finish_mission(g, 0.1)
  assert_eq(g.phase, "won")
  assert_eq(g.wave, 1)
}
