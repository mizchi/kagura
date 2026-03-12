///|
test "auto_play_input routes toward nearby equipment pickup when no enemy is visible" {
  let world = GameWorld::new(seed=42)
  world.items = [
    {
      x: world.player.x + tile_size,
      y: world.player.y,
      vx: 0.0,
      vy: 0.0,
      kind: Equipment({
        name: "Bronze Dagger",
        rarity: Rare,
        slot: Weapon,
        atk_bonus: 3,
        def_bonus: 0,
        hp_bonus: 0,
        prefix: None,
        suffix: None,
        icon_id: 1,
      }),
      alive: true,
      spawn_frame: world.frame_count,
    },
  ]

  let (dx, dy, enemy_idx, enemy_dist_sq) = auto_play_input(world)

  assert_eq(enemy_idx, -1)
  assert_true(enemy_dist_sq > 0.0)
  assert_true(dx > 0.5)
  assert_true(dy.abs() < 0.2)
}
