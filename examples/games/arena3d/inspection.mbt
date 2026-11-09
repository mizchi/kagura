///|
/// Pausing owns simulation/input state only; the renderer continues presenting.
fn GameState::set_inspection_paused(self : GameState, paused : Bool) -> Unit {
  if self.inspection_paused == paused {
    return
  }
  self.inspection_paused = paused
  self.inspection_revision += 1
  self.input = @inpututil.new_input_helper()
  self.looking = false
}

///|
fn observation_number(
  id : String,
  label : String,
  unit : String,
  value : Double,
  writable : Bool,
) -> Json {
  {
    "id": id,
    "label": label,
    "unit": unit,
    "kind": "number",
    "value": value,
    "access": if writable {
      "runtime"
    } else {
      "readonly"
    },
  }
}

///|
fn observation_bool(id : String, label : String, value : Bool) -> Json {
  {
    "id": id,
    "label": label,
    "unit": "",
    "kind": "boolean",
    "value": value,
    "access": "readonly",
  }
}

///|
fn observation_motion(
  position : @math3d.Vec3,
  velocity : @math3d.Vec3,
  writable : Bool,
) -> Array[Json] {
  [
    observation_number("position.x", "Position X", "m", position.x, writable),
    observation_number("position.y", "Position Y", "m", position.y, writable),
    observation_number("position.z", "Position Z", "m", position.z, writable),
    observation_number("velocity.x", "Velocity X", "m/s", velocity.x, writable),
    observation_number("velocity.y", "Velocity Y", "m/s", velocity.y, writable),
    observation_number("velocity.z", "Velocity Z", "m/s", velocity.z, writable),
  ]
}

///|
fn GameState::inspection_subjects(
  self : GameState,
  editable_motion : Bool,
) -> Array[Json] {
  let player_fields = observation_motion(
    self.player.position,
    self.physics
    .get_body(player_body_id)
    .map(body => body.velocity)
    .unwrap_or(@math3d.Vec3::zero()),
    editable_motion,
  )
  player_fields.push(observation_bool("grounded", "Grounded", self.on_ground))
  player_fields.push(
    observation_bool("firstPerson", "First person", self.first_person),
  )
  let subjects : Array[Json] = [
    {
      "id": "game",
      "name": "Game",
      "fields": [
        observation_number(
          "frameCount",
          "Frame count",
          "ticks",
          self.frame_count.to_double(),
          false,
        ),
        observation_number("score", "Score", "", self.score.to_double(), false),
        observation_number(
          "rainCount",
          "Rain count",
          "",
          self.rain_count.to_double(),
          false,
        ),
      ],
    },
    { "id": "player", "name": "Player", "fields": player_fields },
  ]
  for prop in self.props {
    if self.physics.get_body(prop.id) is Some(body) {
      let fields = observation_motion(
        body.position,
        body.velocity,
        editable_motion && body.is_dynamic(),
      )
      fields.push(observation_bool("sleeping", "Sleeping", body.is_sleeping))
      subjects.push({
        "id": "prop:\{prop.id}",
        "name": "Body " + prop.key,
        "fields": fields,
      })
    }
  }
  subjects
}

///|
fn GameState::inspection_scope(self : GameState) -> String {
  match self.authored {
    Some(session) => session.current_id()
    None => "standalone"
  }
}

///|
/// Publish one atomic read. Observations never grant editing permissions.
fn GameState::runtime_observation(self : GameState) -> String {
  let state = @json.parse(self.scene_snapshot()) catch {
    error => abort(error.to_string())
  }
  Json({
    "state": state,
    "inspection": {
      "scope": self.inspection_scope(),
      "subjects": self.inspection_subjects(false),
    },
  }).stringify()
}

///|
fn GameState::runtime_fields(self : GameState) -> String {
  let value : Json = {
    "revision": self.inspection_revision,
    "paused": self.inspection_paused,
    "scope": self.inspection_scope(),
    "subjects": self.inspection_subjects(true),
  }
  value.stringify()
}

///|
/// Resolve only declared, dynamic subjects; body IDs alone do not grant writes.
fn GameState::editable_body_index(self : GameState, subject : String) -> Int32 raise {
  let id = if subject == "player" {
    player_body_id
  } else {
    guard self.props.iter().find_first(prop => subject == "prop:\{prop.id}") is Some(prop) else {
      fail("Inspection subject is not writable")
    }
    prop.id
  }
  for index, body in self.physics.bodies {
    if body.id == id && body.is_dynamic() {
      return index
    }
  }
  fail("Dynamic inspection body unavailable")
}

///|
/// Pure validation and reduction preserve every unedited body property.
fn edited_body_motion(
  body : @physics3d.RigidBody,
  field : String,
  value : Double,
) -> @physics3d.RigidBody raise {
  let position_field = match field {
    "position.x" | "position.y" | "position.z" => true
    "velocity.x" | "velocity.y" | "velocity.z" => false
    _ => fail("Inspection field is not writable")
  }
  let limit = if position_field { 10000.0 } else { 1000.0 }
  if !(value >= -limit && value <= limit) {
    fail(
      if position_field {
        "Body position must be finite and within +/-10000 m"
      } else {
        "Body velocity must be finite and within +/-1000 m/s"
      },
    )
  }
  let position = match field {
    "position.x" => @math3d.Vec3::new(value, body.position.y, body.position.z)
    "position.y" => @math3d.Vec3::new(body.position.x, value, body.position.z)
    "position.z" => @math3d.Vec3::new(body.position.x, body.position.y, value)
    _ => body.position
  }
  let velocity = match field {
    "velocity.x" => @math3d.Vec3::new(value, body.velocity.y, body.velocity.z)
    "velocity.y" => @math3d.Vec3::new(body.velocity.x, value, body.velocity.z)
    "velocity.z" => @math3d.Vec3::new(body.velocity.x, body.velocity.y, value)
    _ => body.velocity
  }
  {
    ..body,
    position,
    velocity,
    is_sleeping: false,
    sleep_timer: 0.0,
  }
}

///|
/// Validate first, then commit motion, grounding and the player's camera together.
fn GameState::edit_runtime_field(
  self : GameState,
  subject : String,
  field : String,
  value : Double,
  revision : Int32,
  scope : String,
) -> Unit raise {
  if !self.inspection_paused {
    fail("Runtime must be paused")
  }
  if revision != self.inspection_revision {
    fail("Runtime field revision conflict")
  }
  if scope != self.inspection_scope() {
    fail("Runtime field scope conflict")
  }
  let index = self.editable_body_index(subject)
  let body = self.physics.bodies[index]
  let next = edited_body_motion(body, field, value)
  let bodies = self.physics.bodies.copy()
  bodies[index] = next
  if body.id != player_body_id {
    // A teleported support can disappear from underneath a sleeping stack.
    // Wake sleepers so gravity/contact discovery runs again on resume. Their
    // poses, velocities, forces and material properties remain unchanged.
    for i, other in bodies {
      if other.is_dynamic() && other.is_sleeping {
        bodies[i] = { ..other, is_sleeping: false, sleep_timer: 0.0, }
      }
    }
  }
  let grounded = match bodies.iter().find_first(body => body.id == player_body_id) {
    Some(player) => @character3d.sphere_ground_contact(player, bodies, self.motor) is Some(_)
    None => false
  }
  let camera = if body.id == player_body_id {
    self.camera.with_target(next.position)
  } else {
    self.camera
  }
  for i, body in bodies {
    self.physics.bodies[i] = body
  }
  self.physics.contact_cache.clear()
  if body.id == player_body_id {
    self.player.position = next.position
  }
  self.on_ground = grounded
  self.camera = camera
  self.inspection_revision += 1
}
