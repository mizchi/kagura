///|
fn scene_vec(values : Array[Double]) -> @math3d.Vec3 {
  @math3d.Vec3::new(values[0], values[1], values[2])
}

///|
fn scene_color(value : Int) -> @math3d.Vec4 {
  @math3d.Vec4::new(((value >> 16) & 255).to_double()/255.0, ((value >> 8) & 255).to_double()/255.0, (value & 255).to_double()/255.0, 1.0)
}

///|
fn GameState::apply_scene_project(self : GameState, source : String) -> Unit raise {
  let session = @scene_data.Session::parse(source, ["floor", "wall", "spawn", "target", "box"])
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
  let player = self.camera.position
  let result : Json = { "sceneId": session.current_id(), "scene": session.scene().to_json(), "player": [player.x, player.y, player.z] }
  result.stringify()
}

///|
fn GameState::activate_scene(self : GameState) -> Unit {
  guard self.authored is Some(session) else { return }
  self.targets.clear()
  self.pillars.clear()
  self.boxes.clear()
  self.bullets.clear()
  self.velocity_y = 0.0
  self.on_ground = true
  for e in session.scene().entities {
    let pos = scene_vec(e.position)
    if e.kind == "spawn" {
      self.camera = @camera3d.FPSCamera::new(pos, 0.0, 0.0, self.camera.fov_y_rad, self.camera.aspect, self.camera.near, self.camera.far)
    }
    if e.kind == "target" { self.targets.push({position: pos, active: true}) }
  }
}

///|
fn GameState::authored_scene(self : GameState, session : @scene_data.Session) -> @scene3d.Scene3D {
  let objects : Array[@scene3d.Object3D] = []
  let mut target_index = 0
  for e in session.scene().entities {
    if e.kind == "spawn" { continue }
    let mut pos = scene_vec(e.position)
    let mut mesh = self.meshes.wall
    if e.kind == "target" {
      let target = self.targets[target_index]
      target_index += 1
      if !target.active { continue }
      pos = target.position
      mesh = self.meshes.target
    }
    objects.push(@scene3d.object3d(mesh~,position=pos,scale=scene_vec(e.scale),color=scene_color(e.color)))
  }
  for b in self.bullets { objects.push(@scene3d.object3d(mesh=self.meshes.bullet,position=b.position,color=color_bullet)) }
  @scene3d.scene3d(objects~,camera=self.camera.to_camera3d(),lighting=self.lighting)
}

///| Standalone native/browser startup uses the compiled MoonBit scene declarations.
fn GameState::load_default_scene(self : GameState) -> Unit {
  let project = @scenes.project() catch { error => abort(error.to_string()) }
  self.apply_scene_project(project.to_json().stringify()) catch { error => abort(error.to_string()) }
}
