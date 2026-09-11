///|
pub(all) struct SceneRectangle {
  id : String
  kind : String
  x : Int
  z : Int
  width : Int
  depth : Int
} derive(FromJson, ToJson)

///|
pub(all) struct SceneEnemy {
  id : String
  x : Double
  z : Double
  kind : String
  hp : Int
} derive(FromJson, ToJson)

///|
pub(all) struct AuthoredScene {
  version : Int
  rectangles : Array[SceneRectangle]
  spawn : Array[Double]
  enemies : Array[SceneEnemy]
} derive(FromJson, ToJson)

///|
fn scene_enemy_kind(name : String) -> EnemyKind {
  match name { "fast" => Fast; "tank" => Tank; "ranged" => Ranged; _ => Basic }
}

///|
fn scene_dungeon(scene : AuthoredScene) -> DungeonData {
  let grid = @terrain.Grid2D::make(map_cols, map_rows, @terrain.Wall)
  let rooms : Array[@terrain.Room] = []
  // Floor order must never erase an explicit wall.
  for kind in ["floor", "wall"] {
    for rect in scene.rectangles {
      if rect.kind != kind { continue }
      if kind == "floor" {
        rooms.push({rect: {x: rect.x, y: rect.z, w: rect.width, h: rect.depth}, id: rooms.length()})
      }
      for z in rect.z..<(rect.z + rect.depth) {
        for x in rect.x..<(rect.x + rect.width) {
          grid.set(x, z, if kind == "floor" { @terrain.Floor } else { @terrain.Wall })
        }
      }
    }
  }
  {grid, rooms, start_x: scene.spawn[0] * tile_size, start_y: scene.spawn[1] * tile_size,
    height_map: Array::make(map_cols * map_rows, 0.0)}
}

///|
fn scene_enemies(scene : AuthoredScene, dungeon : DungeonData) -> Array[Enemy] {
  scene.enemies.map(fn(enemy) {
    let kind = scene_enemy_kind(enemy.kind)
    make_enemy(enemy.x * tile_size, enemy.z * tile_size, kind, enemy.hp,
      if kind == Fast { enemy_speed_fast } else if kind == Tank { enemy_speed_tank } else { enemy_speed_basic },
      12.0, room_index=find_room_at(dungeon.rooms, enemy.x * tile_size, enemy.z * tile_size))
  })
}

///|
pub fn GameWorld::apply_scene_json(self : GameWorld, source : String) -> Unit raise {
  let scene : AuthoredScene = @json.from_json(@json.parse(source))
  if scene.version != 1 || scene.spawn.length() != 2 || scene.rectangles.is_empty() ||
    scene.rectangles.length() > 1000 || scene.enemies.length() > 128 { fail("Invalid scene shape") }
  let ids : Map[String, Bool] = Map([])
  let mut floors = 0
  for rect in scene.rectangles {
    if ids.contains(rect.id) || rect.id.is_empty() ||
      (rect.kind != "floor" && rect.kind != "wall") || rect.x < 1 || rect.z < 1 ||
      rect.width < 1 || rect.depth < 1 || rect.width > 98 || rect.depth > 78 ||
      rect.x > 99 - rect.width || rect.z > 79 - rect.depth { fail("Invalid scene rectangle") }
    ids[rect.id] = true
    if rect.kind == "floor" { floors = floors + 1 }
  }
  if floors == 0 { fail("Scene needs a floor") }
  let dungeon = scene_dungeon(scene)
  let positions = [scene.spawn]
  for enemy in scene.enemies {
    if ids.contains(enemy.id) || enemy.id.is_empty() || enemy.hp < 1 || enemy.hp > 10000 ||
      !["basic", "fast", "tank", "ranged"].contains(enemy.kind) { fail("Invalid scene enemy") }
    ids[enemy.id] = true
    positions.push([enemy.x, enemy.z])
  }
  for position in positions {
    let x = position[0]
    let z = position[1]
    if !(x >= 1.0 && x < 99.0 && z >= 1.0 && z < 79.0) ||
      check_wall_collision(dungeon.grid, x * tile_size, z * tile_size, 12.0) { fail("Scene actor overlaps a wall") }
  }
  // Commit only after validating the whole recipe; errors preserve the previous level.
  self.authored_scene = Some(scene)
  self.apply_dungeon(self.seed, 1)
}

///|
pub fn GameWorld::scene_snapshot_json(self : GameWorld) -> String {
  let scene : Json = match self.authored_scene { Some(scene) => scene.to_json(); None => Json::null() }
  let result : Json = { "scene": scene, "player": [self.player.x / tile_size, self.player.y / tile_size].to_json(),
    "enemyCount": self.enemies.length().to_json(),
    "tiles": self.dungeon.grid.width.to_json() }
  result.stringify()
}
