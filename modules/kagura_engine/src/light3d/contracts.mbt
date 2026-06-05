///|
/// Lighting types and uniform buffer encoding for 3D rendering.

///|
pub struct DirectionalLight {
  direction : @math3d.Vec3
  color : @math3d.Vec3
  intensity : Double
} derive(Debug)

///|
pub impl Show for DirectionalLight with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn DirectionalLight::new(
  direction : @math3d.Vec3,
  color : @math3d.Vec3,
  intensity : Double,
) -> DirectionalLight {
  { direction: direction.normalize(), color, intensity }
}

///|
pub fn DirectionalLight::default() -> DirectionalLight {
  {
    direction: @math3d.Vec3::new(0.0, -1.0, 0.0),
    color: @math3d.Vec3::one(),
    intensity: 1.0,
  }
}

///|
pub struct AmbientLight {
  color : @math3d.Vec3
  intensity : Double
} derive(Debug)

///|
pub impl Show for AmbientLight with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn AmbientLight::new(
  color : @math3d.Vec3,
  intensity : Double,
) -> AmbientLight {
  { color, intensity }
}

///|
pub fn AmbientLight::default() -> AmbientLight {
  { color: @math3d.Vec3::one(), intensity: 0.2 }
}

///|
pub struct PointLight {
  position : @math3d.Vec3
  color : @math3d.Vec3
  intensity : Double
  radius : Double
} derive(Debug)

///|
pub impl Show for PointLight with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn PointLight::new(
  position : @math3d.Vec3,
  color : @math3d.Vec3,
  intensity : Double,
  radius : Double,
) -> PointLight {
  { position, color, intensity, radius }
}

///|
pub struct SpotLight {
  position : @math3d.Vec3
  direction : @math3d.Vec3
  color : @math3d.Vec3
  intensity : Double
  radius : Double
  inner_angle : Double
  outer_angle : Double
} derive(Debug)

///|
pub impl Show for SpotLight with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn SpotLight::new(
  position : @math3d.Vec3,
  direction : @math3d.Vec3,
  color : @math3d.Vec3,
  intensity : Double,
  radius : Double,
  inner_angle : Double,
  outer_angle : Double,
) -> SpotLight {
  {
    position,
    direction: direction.normalize(),
    color,
    intensity,
    radius,
    inner_angle,
    outer_angle,
  }
}

///|
pub struct LightingEnvironment {
  directional : DirectionalLight
  ambient : AmbientLight
  point_lights : Array[PointLight]
  spot_lights : Array[SpotLight]
} derive(Debug)

///|
pub impl Show for LightingEnvironment with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn LightingEnvironment::new(
  directional : DirectionalLight,
  ambient : AmbientLight,
  point_lights? : Array[PointLight] = [],
  spot_lights? : Array[SpotLight] = [],
) -> LightingEnvironment {
  { directional, ambient, point_lights, spot_lights }
}

///|
pub fn LightingEnvironment::default() -> LightingEnvironment {
  {
    directional: DirectionalLight::default(),
    ambient: AmbientLight::default(),
    point_lights: [],
    spot_lights: [],
  }
}

// Encode a Double as the IEEE 754 f32 bit pattern (round to nearest-even),
// for placement into shader uniform buffers. Equivalent to gfx.double_to_f32_bits
// up to 1-ULP rounding (gfx truncates the mantissa, this rounds correctly);
// shader-side math is unaffected, and the hardware-mapped intrinsic chain
// avoids the int64 emulation cost on the JS target.

///|
fn f32(v : Double) -> Int {
  v.to_float().reinterpret_as_int()
}

///|
fn is_translation_only_model(model : @math3d.Mat4) -> Bool {
  model.elements[0] == 1.0 &&
  model.elements[1] == 0.0 &&
  model.elements[2] == 0.0 &&
  model.elements[3] == 0.0 &&
  model.elements[4] == 0.0 &&
  model.elements[5] == 1.0 &&
  model.elements[6] == 0.0 &&
  model.elements[7] == 0.0 &&
  model.elements[8] == 0.0 &&
  model.elements[9] == 0.0 &&
  model.elements[10] == 1.0 &&
  model.elements[11] == 0.0 &&
  model.elements[15] == 1.0
}

///|
/// Encode lighting environment as 12 uniform dwords:
/// [0-3]: direction.xyz + 0 (padding)
/// [4-7]: color*intensity + intensity
/// [8-11]: ambient_color*intensity + ambient_intensity
pub fn light_uniform_dwords(env : LightingEnvironment) -> Array[Int] {
  let d = env.directional
  let a = env.ambient
  [
    f32(d.direction.x),
    f32(d.direction.y),
    f32(d.direction.z),
    f32(0.0),
    f32(d.color.x * d.intensity),
    f32(d.color.y * d.intensity),
    f32(d.color.z * d.intensity),
    f32(d.intensity),
    f32(a.color.x * a.intensity),
    f32(a.color.y * a.intensity),
    f32(a.color.z * a.intensity),
    f32(a.intensity),
  ]
}

///|
/// Encode normal matrix (inverse-transpose of model's upper 3x3) as 12 dwords.
/// Stored as 3 vec4f columns (xyz + padding).
pub fn normal_matrix_uniform_dwords(model : @math3d.Mat4) -> Array[Int] {
  if is_translation_only_model(model) {
    return [
      f32(1.0),
      f32(0.0),
      f32(0.0),
      f32(0.0),
      f32(0.0),
      f32(1.0),
      f32(0.0),
      f32(0.0),
      f32(0.0),
      f32(0.0),
      f32(1.0),
      f32(0.0),
    ]
  }
  let inv = model.inverse()
  let inv_t = inv.transpose()
  // Extract upper 3x3 as three columns, each padded to vec4f
  [
    f32(inv_t.elements[0]),
    f32(inv_t.elements[1]),
    f32(inv_t.elements[2]),
    f32(0.0),
    f32(inv_t.elements[4]),
    f32(inv_t.elements[5]),
    f32(inv_t.elements[6]),
    f32(0.0),
    f32(inv_t.elements[8]),
    f32(inv_t.elements[9]),
    f32(inv_t.elements[10]),
    f32(0.0),
  ]
}
