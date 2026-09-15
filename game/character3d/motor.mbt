///|
/// Speeds are in units/second, accelerations in units/second squared.
pub(all) struct MotorConfig {
  speed : Double
  response_time : Double
  ground_acceleration : Double
  ground_braking : Double
  air_acceleration : Double
  air_braking : Double
  jump_speed : Double
  max_slope_cos : Double
  probe_distance : Double
}

///|
pub fn MotorConfig::default() -> MotorConfig {
  {
    speed: 4.8,
    response_time: 0.12,
    ground_acceleration: 30.0,
    ground_braking: 6.0,
    air_acceleration: 6.0,
    air_braking: 0.5,
    jump_speed: 5.2,
    max_slope_cos: 0.65,
    probe_distance: 0.06,
  }
}

///|
/// Unit contact normal points from the support toward the character. Velocity is
/// sampled at the contact point, allowing control relative to moving supports.
pub(all) struct GroundContact {
  body_id : Int
  normal : @math3d.Vec3
  velocity : @math3d.Vec3
}

///|
/// Pure controller policy: the caller applies mass * acceleration before the
/// fixed physics step. No position or velocity is overwritten here.
pub fn motor_acceleration(
  config : MotorConfig,
  velocity : @math3d.Vec3,
  direction : @math3d.Vec3,
  ground : GroundContact?,
  gravity : @math3d.Vec3,
  dt : Double,
) -> @math3d.Vec3 {
  if dt <= 0.0 {
    return @math3d.Vec3::zero()
  }
  let normal = match ground {
    Some(support) => support.normal
    None => @math3d.Vec3::unit_y()
  }
  let support_velocity = match ground {
    Some(support) => support.velocity
    None => @math3d.Vec3::zero()
  }
  let horizontal = @math3d.Vec3::new(direction.x, 0.0, direction.z)
  let input_amount = horizontal.length().min(1.0)
  let wish = tangent(horizontal, normal)
  let target = if wish.length_squared() > 1.0e-12 {
    wish.normalize().scale(config.speed * input_amount)
  } else {
    @math3d.Vec3::zero()
  }
  let current = tangent(velocity.sub(support_velocity), normal)
  let correction = target.sub(current).scale(1.0 / config.response_time.max(dt))
  let acceleration = if ground is Some(_) {
    correction.sub(tangent(gravity, normal))
  } else {
    correction
  }
  let limit = match (ground, input_amount > 0.0001) {
    (Some(_), true) => config.ground_acceleration
    (Some(_), false) => config.ground_braking
    (None, true) => config.air_acceleration
    (None, false) => config.air_braking
  }
  let length = acceleration.length()
  if length > limit.max(0.0) && length > 1.0e-12 {
    acceleration.scale(limit.max(0.0) / length)
  } else {
    acceleration
  }
}

///|
fn tangent(value : @math3d.Vec3, normal : @math3d.Vec3) -> @math3d.Vec3 {
  value.sub(normal.scale(value.dot(normal)))
}
