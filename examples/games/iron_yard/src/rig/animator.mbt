///|
pub(all) struct Animator {
  asset : Asset
  mut movement : Double
  mut heading : Double
  mut previous_gait : Double
  mut walk_time : Double
  mut airborne : Double
  idle : Array[@transform3d.Transform3D]
  boost : Array[@transform3d.Transform3D]
  mut pose : Array[@transform3d.Transform3D]
  world : Array[@math3d.Mat4]
  rotations : Array[@math3d.Quaternion]
}

///|
pub fn new_animator(asset : Asset) -> Animator {
  {
    asset,
    movement: 0.0,
    heading: 0.0,
    previous_gait: 0.0,
    walk_time: 0.0,
    airborne: 0.0,
    idle: sample(asset, "Idle", 0.0),
    boost: sample(asset, "Boost", 1.4),
    pose: sample(asset, "Idle", 0.0),
    world: Array::make(asset.bones.length(), @math3d.Mat4::identity()),
    rotations: Array::make(asset.bones.length(), @math3d.Quaternion::identity()),
  }
}

///|
pub fn axis_delta(angle : Double) -> Double {
  let d = angle - @math.PI * ((angle + @math.PI / 2.0) / @math.PI).floor()
  if (d.abs() - @math.PI / 2.0).abs() < 0.00000001 {
    -@math.PI / 2.0
  } else {
    d
  }
}

///|
fn update_world(
  a : Animator,
  root : @math3d.Mat4,
  rotation : @math3d.Quaternion,
) -> Unit {
  for i in 0..<a.asset.bones.length() {
    let parent = a.asset.bones[i].parent
    a.world[i] = (if parent < 0 { root } else { a.world[parent] }).multiply(
      a.pose[i].to_mat4(),
    )
    a.rotations[i] = (if parent < 0 { rotation } else { a.rotations[parent] }).multiply(
      a.pose[i].rotation,
    )
  }
}

///|
pub fn transform_point(matrix : @math3d.Mat4, p : @math3d.Vec3) -> @math3d.Vec3 {
  let v = matrix.mul_vec4(@math3d.Vec4::new(p.x, p.y, p.z, 1.0))
  @sim.vec(v.x, v.y, v.z)
}

///|
pub fn update_animator(
  a : Animator,
  p : @sim.Pilot,
  focus : @math3d.Vec3,
  delta : Double,
  attack_age : Double,
) -> @sim.CombatFrame {
  if p.gait < a.previous_gait {
    a.heading = p.yaw
    a.movement = 0.0
    a.walk_time = 0.0
    a.airborne = 0.0
    a.previous_gait = p.gait
  }
  let speed = (p.velocity.x * p.velocity.x + p.velocity.z * p.velocity.z).sqrt()
  let blend = 1.0 - @math.exp(-10.0 * @sim.clamp(delta, 0.0, 0.1))
  a.airborne += ((if p.grounded { 0.0 } else { 1.0 }) - a.airborne) * blend
  a.movement += ((if speed > 0.04 { 1.0 } else { 0.0 }) - a.movement) * blend
  if speed > 0.04 {
    a.heading += axis_delta(@math.atan2(p.velocity.x, p.velocity.z) - a.heading) *
      blend
  }
  let along = p.velocity.x * @math.sin(a.heading) +
    p.velocity.z * @math.cos(a.heading)
  a.walk_time += (p.gait - a.previous_gait) *
    (if along > 0.0 { 1.0 } else if along < 0.0 { -1.0 } else { 0.0 })
  a.previous_gait = p.gait
  let walk = sample(a.asset, "Walk", a.walk_time)
  let flight = @sim.max(p.boost, a.airborne)
  for i in 0..<a.pose.length() {
    let idle = a.idle[i]
    let boost = a.boost[i]
    let rotation = idle.rotation
      .slerp(walk[i].rotation, a.movement)
      .slerp(boost.rotation, flight)
    let position = if a.asset.bones[i].name == "Motion" {
      @sim.vec(
        0.0,
        walk[i].position.y * a.movement * (1.0 - flight) +
        boost.position.y * flight,
        0.0,
      )
    } else {
      idle.position
    }
    a.pose[i] = @transform3d.Transform3D::from_components(
      position,
      rotation,
      idle.scale.lerp(boost.scale, p.boost),
    )
  }
  let root_rotation = @math3d.Quaternion::from_axis_angle(
    @sim.vec(0.0, 1.0, 0.0),
    a.heading,
  )
  let root = @transform3d.Transform3D::from_position_rotation(
    p.position,
    root_rotation,
  ).to_mat4()
  update_world(a, root, root_rotation)
  for name in ["Torso", "Head", "LeftCannon", "RightCannon", "RightHand"] {
    for i in 0..<a.asset.bones.length() {
      if a.asset.bones[i].name == name {
        let origin = transform_point(a.world[i], @sim.vec(0.0, 0.0, 0.0))
        let ray = focus.sub(origin)
        let yaw = @math.atan2(ray.x, ray.z)
        let pitch = -@math.atan2(ray.y, (ray.x * ray.x + ray.z * ray.z).sqrt())
        let desired = @math3d.Quaternion::from_axis_angle(
          @sim.vec(0.0, 1.0, 0.0),
          yaw,
        ).multiply(
          @math3d.Quaternion::from_axis_angle(@sim.vec(1.0, 0.0, 0.0), pitch),
        )
        let parent = a.asset.bones[i].parent
        let parent_rotation = if parent < 0 {
          root_rotation
        } else {
          a.rotations[parent]
        }
        let mut pose = parent_rotation.inverse().multiply(desired)
        if name == "RightHand" && attack_age >= 0.0 && attack_age < 0.11 {
          let recoil = 0.075 *
            @math.sin(@math.PI * attack_age / 0.11) *
            @math.exp(-3.0 * attack_age / 0.11)
          pose = pose.multiply(
            @math3d.Quaternion::from_axis_angle(
              @sim.vec(1.0, 0.0, 0.0),
              -recoil,
            ),
          )
        }
        a.pose[i] = a.pose[i].with_rotation(pose)
        update_world(a, root, root_rotation)
      }
    }
  }
  let mut rifle = p.position
  let mut left = p.position
  let mut right = p.position
  for i in 0..<a.asset.bones.length() {
    match a.asset.bones[i].name {
      "RightHand" =>
        rifle = transform_point(a.world[i], @sim.vec(0.0, -0.08, 2.18))
      "LeftCannon" =>
        left = transform_point(a.world[i], @sim.vec(0.0, 0.2, 1.94))
      "RightCannon" =>
        right = transform_point(a.world[i], @sim.vec(0.0, 0.2, 1.94))
      _ => ()
    }
  }
  { eye: @sim.camera_position(p), aim: focus, rifle, left, right }
}
