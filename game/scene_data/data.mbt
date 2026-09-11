///|
/// Portable, renderer-independent scene recipe. Editor adapters compile into this contract.
pub(all) struct Entity {
  id : String
  kind : String
  position : Array[Double]
  scale : Array[Double]
  color : Int
  target : String
} derive(FromJson, ToJson)

///|
pub(all) struct Definition {
  version : Int
  entities : Array[Entity]
} derive(FromJson, ToJson)

///|
pub(all) struct Entry {
  id : String
  data : Definition
} derive(FromJson, ToJson)

///|
pub(all) struct Project {
  entry : String
  scenes : Array[Entry]
} derive(FromJson, ToJson)

///|
pub struct Session {
  project : Project
  flow : @scene_flow.Flow
}

///|
pub fn Session::parse(source : String, kinds : Array[String]) -> Session raise {
  Session::new(@json.from_json(@json.parse(source)), kinds)
}

///|
pub fn Session::new(project : Project, kinds : Array[String]) -> Session raise {
  let flow = @scene_flow.Flow::new(project.scenes.map(e => e.id), project.entry)
  if project.scenes.length() > 64 {
    fail("Too many scenes")
  }
  for entry in project.scenes {
    let scene = entry.data
    if scene.version != 1 || scene.entities.length() > 512 {
      fail("Invalid scene version/size")
    }
    let ids : Array[String] = []
    let mut spawns = 0
    let mut floors = 0
    for e in scene.entities {
      if e.id.is_empty() || ids.contains(e.id) || !kinds.contains(e.kind) {
        fail("Invalid entity ID/kind")
      }
      ids.push(e.id)
      if e.position.length() != 3 || e.scale.length() != 3 {
        fail("Invalid transform")
      }
      for v in e.position {
        if !(v >= -1000.0 && v <= 1000.0) {
          fail("Invalid position")
        }
      }
      for v in e.scale {
        if !(v > 0.0 && v <= 2000.0) {
          fail("Invalid scale")
        }
      }
      if e.color < 0 || e.color > 0xffffff {
        fail("Invalid color")
      }
      if e.kind == "spawn" {
        spawns += 1
      }
      if e.kind == "floor" {
        floors += 1
        if (e.position[1] + e.scale[1] / 2.0).abs() > 0.00001 {
          fail("Floor surface must be at Y=0")
        }
      }
      if e.kind == "portal" {
        if !project.scenes.any(entry => entry.id == e.target) {
          fail("Unknown portal destination")
        }
      } else if e.target != "" {
        fail("Only portals have a destination")
      }
    }
    if spawns != 1 || floors == 0 {
      fail("Scene needs one spawn and a floor")
    }
    let spawn = scene.entities.filter(e => e.kind == "spawn")[0]
    if scene.blocked(spawn.position[0], spawn.position[2], 0.5) {
      fail("Spawn is blocked")
    }
  }
  // Copy the decoded recipe so caller mutations cannot invalidate a live session.
  let copy : Project = @json.from_json(project.to_json())
  { project: copy, flow, }
}

///|
pub fn Session::current_id(self : Session) -> String {
  self.flow.current()
}

///|
pub fn Session::scene(self : Session) -> Definition {
  for entry in self.project.scenes {
    if entry.id == self.flow.current() {
      return entry.data
    }
  }
  abort("Scene flow invariant violated")
}

///|
/// All recipes have already been validated; runtime activation is synchronous.
pub fn Session::transition(self : Session, id : String) -> Unit raise {
  let ticket = self.flow.request(id)
  ignore(self.flow.commit(ticket))
}

///|
pub fn Session::portal_at(self : Session, x : Double, z : Double) -> String? {
  for e in self.scene().entities {
    if e.kind == "portal" {
      let portal = @scene_flow.Portal::{
        x: e.position[0],
        z: e.position[2],
        radius: e.scale[0] / 2.0,
        target: e.target,
      }
      if portal.contains(x, z) {
        return Some(e.target)
      }
    }
  }
  None
}

///|
/// Floor bounds and solid AABBs share the geometry used by the renderer.
pub fn Definition::blocked(
  self : Definition,
  x : Double,
  z : Double,
  radius : Double,
) -> Bool {
  let mut floor = false
  for e in self.entities {
    let dx = (x - e.position[0]).abs()
    let dz = (z - e.position[2]).abs()
    if e.kind == "floor" &&
      dx + radius <= e.scale[0] / 2.0 &&
      dz + radius <= e.scale[2] / 2.0 {
      floor = true
    }
    if (e.kind == "wall" || e.kind == "box" || e.kind == "pillar") &&
      dx < e.scale[0] / 2.0 + radius &&
      dz < e.scale[2] / 2.0 + radius {
      return true
    }
  }
  !floor
}
