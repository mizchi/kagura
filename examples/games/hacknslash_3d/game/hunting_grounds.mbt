// The Ashwood: open meadows connected by a winding pilgrim road. Every object
// that blocks movement is authored into the same grid consumed by pathfinding.

///|
pub fn hunting_hash(x : Int, z : Int, seed : Int) -> Int {
  ((x * 7919 + z * 104729 + seed % 10000 * 31) % 10007 + 10007) % 10007
}

///|
pub fn hunting_road_z(x : Int) -> Double {
  40.0 + @math.sin(x.to_double() * 0.09) * 9.0
}

///|
pub fn hunting_landmark(x : Int, z : Int) -> Bool {
  (x == 27 && z == 46) || (x == 51 && z == 28) || (x == 87 && z == 48)
}

///|
pub fn hunting_clearings() -> Array[@terrain.Room] {
  [
    { id: 0, rect: { x: 14, y: 43, w: 12, h: 12, }, },
    { id: 1, rect: { x: 33, y: 30, w: 12, h: 12, }, },
    { id: 2, rect: { x: 53, y: 23, w: 14, h: 14, }, },
    { id: 3, rect: { x: 70, y: 41, w: 14, h: 14, }, },
    { id: 4, rect: { x: 37, y: 56, w: 12, h: 12, }, },
  ]
}

///|
pub fn generate_hunting_grounds(seed : Int) -> DungeonData {
  let grid = @terrain.Grid2D::make(map_cols, map_rows, @terrain.Floor)
  let rooms = hunting_clearings()
  for z in 0..<map_rows {
    for x in 0..<map_cols {
      if x < 2 || z < 2 || x >= map_cols - 2 || z >= map_rows - 2 {
        grid.set(x, z, @terrain.Wall)
        continue
      }
      if hunting_landmark(x, z) {
        grid.set(x, z, @terrain.Wall)
        continue
      }
      let road = (z.to_double() - hunting_road_z(x)).abs() < 2.4 ||
        ((x - 43).abs() < 2 && z > 36 && z < 66)
      if road {
        grid.set(x, z, @terrain.Corridor)
        continue
      }
      let mut clearing = false
      for room in rooms {
        let r = room.rect
        if x >= r.x - 2 &&
          x <= r.x + r.w + 1 &&
          z >= r.y - 2 &&
          z <= r.y + r.h + 1 {
          clearing = true
        }
      }
      // Sparse islands with a two-tile gap: no hidden maze or sealed pockets.
      if !clearing &&
        x % 3 == 0 &&
        z % 3 == 0 &&
        hunting_hash(x, z, seed) % 10 < 8 {
        grid.set(x, z, @terrain.Wall)
      }
    }
  }
  let start = rooms[0].rect.center()
  {
    grid,
    rooms,
    start_x: start.x.to_double() * tile_size + tile_size / 2.0,
    start_y: start.y.to_double() * tile_size + tile_size / 2.0,
    height_map: Array::make(map_cols * map_rows, 0.0),
  }
}

///|
fn append_hunting_approach_enemies(
  enemies : Array[Enemy],
  dungeon : DungeonData,
  params : BalanceParams,
  floor : Int,
) -> Unit {
  // The dungeon spawner skips the starting room. In an open woodland this
  // left the whole initial camera empty; put a small pack ahead of the hunter.
  // Four tiles of breathing room keep the first encounter from being a spawn hit.
  for
    (offset, kind) in [
      ((-4.0, -4.0), Basic),
      ((-2.0, -5.0), Fast),
      ((0.0, -5.5), Ranged),
    ] {
    let config = find_enemy_type_config(kind)
    let enemy = make_enemy(
      dungeon.start_x + offset.0 * tile_size,
      dungeon.start_y + offset.1 * tile_size,
      kind,
      params.scale_enemy_hp_for_floor(
        (params.basic_hp * config.hp_param).to_int().max(1),
        floor,
      ),
      params.scale_enemy_speed_for_floor(
        params.enemy_speed_basic * 0.6 * @cmp.minimum(1.0, config.speed_param),
        floor,
      ),
      config.size,
      room_index=0,
    )
    // Let the first mixed pack be readable before ranged attacks and charges.
    enemy.shoot_cooldown = 150
    enemy.charge_cooldown = 180
    enemies.push(enemy)
  }
}

///|
fn equip_hunter_skills(skills : SkillTree) -> Unit {
  for id in [PowerStrike, Whirlwind, SplittingFireball, IceNova] {
    let index = skills.find_index(id)
    if index >= 0 && skills.nodes[index].level == 0 {
      skills.nodes[index].level = 1
    }
  }
}

///|
pub fn GameWorld::ensure_hunter_loadout(self : GameWorld) -> Unit {
  if self.hunting_grounds {
    equip_hunter_skills(self.skills)
    self.refresh_player_stats()
  }
}
