///|
fn scene_vec(values : Array[Double]) -> @math3d.Vec3 {
  @math3d.Vec3::new(values[0], values[1], values[2])
}

///|
fn scene_color(value : Int) -> @math3d.Vec4 {
  @math3d.Vec4::new(
    ((value >> 16) & 255).to_double() / 255.0,
    ((value >> 8) & 255).to_double() / 255.0,
    (value & 255).to_double() / 255.0,
    1.0,
  )
}

///|
fn GameState::apply_scene_project(
  self : GameState,
  source : String,
) -> Unit raise {
  let session = @scene_data.Session::parse(source, [
    "floor", "wall", "spawn", "item", "enemy", "portal",
  ])
  self.authored = Some(session)
  self.activate_scene()
}

///|
fn GameState::transition_scene(self : GameState, id : String) -> Unit raise {
  guard self.authored is Some(session) else { fail("No authored scene") }
  session.transition(id)
  self.activate_scene()
}

///|
fn GameState::scene_snapshot(self : GameState) -> String {
  guard self.authored is Some(session) else { return "null" }
  let player = self.player.position
  let result : Json = {
    "sceneId": session.current_id(),
    "scene": session.scene().to_json(),
    "player": [player.x, player.y, player.z],
  }
  result.stringify()
}

///|
fn GameState::activate_scene(self : GameState) -> Unit {
  guard self.authored is Some(session) else { return }
  self.items.clear()
  self.enemies.clear()
  self.mode = mode_playing
  for e in session.scene().entities {
    let pos = scene_vec(e.position)
    match e.kind {
      "spawn" => self.player.position = pos
      "item" => self.items.push({ position: pos, active: true, })
      "enemy" =>
        self.enemies.push({ position: pos, waypoints: [pos], waypoint_idx: 0, })
      _ => ()
    }
  }
  self.camera = self.camera.with_target(self.player.position)
}

///|
fn GameState::authored_nodes(
  self : GameState,
  session : @scene_data.Session,
) -> Array[@scene3d.View] {
  let nodes : Array[@scene3d.View] = []
  let mut item_index = 0
  let mut enemy_index = 0
  for e in session.scene().entities {
    let mut pos = scene_vec(e.position)
    let mut mesh = self.meshes.wall
    match e.kind {
      "spawn" => {
        pos = self.player.position
        mesh = self.meshes.player
      }
      "item" => {
        let item = self.items[item_index]
        item_index += 1
        if !item.active {
          continue
        }
        pos = item.position
        mesh = self.meshes.item
      }
      "enemy" => {
        pos = self.enemies[enemy_index].position
        enemy_index += 1
        mesh = self.meshes.enemy
      }
      _ => ()
    }
    nodes.push(
      @scene3d.mesh(
        key=e.id,
        mesh~,
        position=pos,
        scale=scene_vec(e.scale),
        color=scene_color(e.color),
      ),
    )
  }
  nodes
}

///|
/// Standalone native/browser startup uses the compiled MoonBit scene declarations.
fn GameState::load_default_scene(self : GameState) -> Unit {
  let project = @scenes.project() catch { error => abort(error.to_string()) }
  self.apply_scene_project(project.to_json().stringify()) catch {
    error => abort(error.to_string())
  }
}
