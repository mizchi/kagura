///|
let shot_speed : Double = 16.0

///|
let shot_range : Double = 40.0

///|
let shot_capacity : Int = 12

///|
let shot_impact_frames : Int = 12

///|
struct Shot {
  mut active : Bool
  mut position : @math3d.Vec3
  direction : @math3d.Vec3
  mut travelled : Double
  mut impact_frames : Int
}

///|
struct ShotHit {
  distance : Double
  body_id : Int?
  enemy_index : Int?
}

///|
fn GameState::trace_shot(
  self : GameState,
  ray : @collision3d.Ray,
  range : Double,
) -> ShotHit {
  let mut distance = range
  let mut body_id : Int? = None
  let mut enemy_index : Int? = None
  for body in self.physics.bodies {
    if body.id == player_body_id {
      continue
    }
    let hit = body.raycast(ray)
    if hit.hit && hit.distance <= distance {
      distance = hit.distance
      body_id = Some(body.id)
    }
  }
  for i, enemy in self.enemies {
    if !enemy.active {
      continue
    }
    let hit = ray.intersects_sphere(
      @collision3d.Sphere::new(enemy.position, 0.55),
    )
    if hit.hit && hit.distance < distance {
      distance = hit.distance
      enemy_index = Some(i)
    }
  }
  { distance, body_id, enemy_index, }
}

///|
/// Converge from a visible muzzle to the reticle, instead of hiding the whole
/// flight behind it. Check the eye-to-muzzle segment before using that offset.
fn GameState::fire_aimed_shot(self : GameState) -> Unit {
  let eye = self.eye()
  let direction = self.aim_direction()
  let ray = @collision3d.Ray::new(eye, direction)
  let target = ray.point_at(self.trace_shot(ray, shot_range).distance.max(0.1))
  let right = self.camera.orientation().rotate_vec3(@math3d.Vec3::unit_x())
  let up = self.camera.orientation().rotate_vec3(@math3d.Vec3::unit_y())
  let offset = right.scale(0.55).sub(up.scale(0.18))
  let clearance = self.trace_shot(
    @collision3d.Ray::new(eye, offset.normalize()),
    offset.length(),
  )
  let muzzle = if clearance.body_id is Some(_) ||
    clearance.enemy_index is Some(_) {
    eye
  } else {
    eye.add(offset)
  }
  self.fire_shot(muzzle, target.sub(muzzle))
}

///|
fn GameState::fire_shot(
  self : GameState,
  origin : @math3d.Vec3,
  direction : @math3d.Vec3,
) -> Unit {
  guard direction.length_squared() > 1.0e-12 else { return }
  let shot : Shot = {
    active: true,
    position: origin,
    direction: direction.normalize(),
    travelled: 0.0,
    impact_frames: 0,
  }
  for i, old in self.shots {
    if !old.active {
      self.shots[i] = shot
      self.shot_frames = 10
      return
    }
  }
  if self.shots.length() < shot_capacity {
    self.shots.push(shot)
    self.shot_frames = 10
  }
}

///|
/// Sweep only this tick's travel segment against the current scene. Impulses
/// happen on arrival, and thin walls cannot be skipped between visible frames.
fn GameState::update_shots(self : GameState) -> Unit {
  for shot in self.shots {
    if !shot.active {
      continue
    }
    if shot.impact_frames > 0 {
      shot.impact_frames -= 1
      shot.active = shot.impact_frames > 0
      continue
    }
    let step = (shot_speed / 60.0).min(shot_range - shot.travelled)
    let ray = @collision3d.Ray::new(shot.position, shot.direction)
    let hit = self.trace_shot(ray, step)
    shot.position = ray.point_at(hit.distance)
    shot.travelled += hit.distance
    if hit.enemy_index is Some(index) {
      self.enemies[index].active = false
      self.score += 25
      shot.impact_frames = shot_impact_frames
    } else if hit.body_id is Some(id) {
      self.physics.apply_impulse(id, shot.direction.scale(12.0))
      shot.impact_frames = shot_impact_frames
    } else if shot.travelled >= shot_range - 1.0e-9 {
      shot.active = false
    }
  }
}

///|
let shot_head_material : @scene3d.Material = @scene3d.Material::new(
  color=@math3d.Vec4::new(3.0, 2.4, 0.6, 1.0),
  emissive=@math3d.Vec3::new(1.0, 0.8, 0.3),
)

///|
let shot_trail_material : @scene3d.Material = @scene3d.Material::new(
  color=@math3d.Vec4::new(2.0, 0.85, 0.08, 1.0),
  emissive=@math3d.Vec3::new(0.9, 0.3, 0.04),
)

///|
fn GameState::append_shot_nodes(
  self : GameState,
  nodes : Array[@scene3d.View],
) -> Unit {
  // Reuse the sphere mesh. At most five nodes per slot, including impact sparks.
  for slot, shot in self.shots {
    if !shot.active {
      continue
    }
    let impact = shot.impact_frames > 0
    let fade = shot.impact_frames.to_double() / shot_impact_frames.to_double()
    let center = if impact {
      shot.position.sub(shot.direction.scale(0.08))
    } else {
      shot.position
    }
    let diameter = if impact { 0.3 + 0.5 * fade } else { 0.38 }
    nodes.push(
      @scene3d.mesh(
        key="shot-\{slot}-head",
        mesh=self.meshes.player,
        position=center,
        scale=@math3d.Vec3::one().scale(diameter),
        material=Some(shot_head_material),
      ),
    )
    let sideways = if shot.direction.y.abs() < 0.9 {
      shot.direction.cross(@math3d.Vec3::unit_y()).normalize()
    } else {
      @math3d.Vec3::unit_x()
    }
    let up = sideways.cross(shot.direction).normalize()
    for i in 0..<4 {
      let offset = if impact {
        let axis = match i {
          0 => sideways
          1 => sideways.scale(-1.0)
          2 => up
          _ => up.scale(-1.0)
        }
        axis.scale(0.25 + (1.0 - fade) * 0.65)
      } else {
        shot.direction.scale(-((i + 1).to_double() * 0.28).min(shot.travelled))
      }
      let size = if impact {
        0.08 + 0.18 * fade
      } else {
        0.3 - i.to_double() * 0.05
      }
      nodes.push(
        @scene3d.mesh(
          key="shot-\{slot}-trail-\{i}",
          mesh=self.meshes.player,
          position=center.add(offset),
          scale=@math3d.Vec3::one().scale(size),
          material=Some(shot_trail_material),
        ),
      )
    }
  }
}
