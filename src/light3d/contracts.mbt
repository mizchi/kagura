///|
/// Lighting types and uniform buffer encoding for 3D rendering.

///|
pub struct DirectionalLight {
  direction : @math3d.Vec3
  color : @math3d.Vec3
  intensity : Double
} derive(Show)

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
} derive(Show)

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
pub struct LightingEnvironment {
  directional : DirectionalLight
  ambient : AmbientLight
} derive(Show)

///|
pub fn LightingEnvironment::new(
  directional : DirectionalLight,
  ambient : AmbientLight,
) -> LightingEnvironment {
  { directional, ambient }
}

///|
pub fn LightingEnvironment::default() -> LightingEnvironment {
  {
    directional: DirectionalLight::default(),
    ambient: AmbientLight::default(),
  }
}

///|
fn f32(v : Double) -> Int {
  @gfx.double_to_f32_bits(v)
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
