///|
pub(all) struct SceneAction {
  cooldown : Double
  damage : Double
  flashDuration : Double
  flashColor : Int
  recoilDuration : Double
  recoilStrength : Double
  shotSound : String
  hitSound : String
} derive(FromJson)

///|
pub(all) struct SceneSolid {
  id : String
  kind : String
  center : Array[Double]
  size : Array[Double]
  color : Int
} derive(FromJson)

///|
pub(all) struct SceneTarget {
  id : String
  position : Array[Double]
  yaw : Double
} derive(FromJson)

///|
pub(all) struct SceneRecipe {
  bounds : Array[Double]
  spawn : Array[Double]
  solids : Array[SceneSolid]
  targets : Array[SceneTarget]
  waves : Array[Array[Int]]
  timeLimit : Double
  fov : Double
  sky : Int
  sun : Double
  action : SceneAction
} derive(FromJson)

///|
fn vector_from_array(v : Array[Double]) -> @math3d.Vec3 {
  vec(v[0], v[1], v[2])
}

///|
/// The authoring boundary validates the source document before generating this recipe.
pub fn game_from_scene(source : String, ai : Bool) -> Game raise {
  let scene : SceneRecipe = @json.from_json(@json.parse(source))
  let stage : Stage = {
    min_x: scene.bounds[0],
    max_x: scene.bounds[1],
    min_z: scene.bounds[2],
    max_z: scene.bounds[3],
    spawn: vector_from_array(scene.spawn),
    solids: scene.solids.map(fn(s) {
      solid(
        s.id,
        vector_from_array(s.center),
        vector_from_array(s.size),
        s.color,
        kind=s.kind,
      )
    }),
  }
  let g = {
    ..new_game(ai~),
    stage,
    pilot: new_pilot(stage),
    units: [],
    scene: Some(scene),
  }
  append_wave(g)
  g
}

///|
pub fn append_wave(g : Game) -> Unit {
  if g.scene is Some(scene) {
    for index in scene.waves[g.wave] {
      let target = scene.targets[index]
      let position = vector_from_array(target.position)
      g.units.push({
        ..new_enemy(g.units.length()),
        name: target.id,
        position,
        home: position,
        yaw: target.yaw,
      })
    }
  } else {
    for i in 0..<3 {
      g.units.push(new_enemy(g.wave * 3 + i))
    }
  }
}

///|
let default_rifle_action : SceneAction = {
  cooldown: 0.12,
  damage: 12.0,
  flashDuration: 0.035,
  flashColor: 0xffedb4,
  recoilDuration: 0.11,
  recoilStrength: 0.075,
  shotSound: "rifle",
  hitSound: "hit",
}

///|
pub fn rifle_action(g : Game) -> SceneAction {
  if g.scene is Some(scene) {
    scene.action
  } else {
    default_rifle_action
  }
}

///|
pub fn mission_time(g : Game) -> Double {
  if g.scene is Some(scene) {
    scene.timeLimit
  } else {
    180.0
  }
}

///|
pub fn wave_count(g : Game) -> Int {
  if g.scene is Some(scene) {
    scene.waves.length()
  } else {
    3
  }
}
