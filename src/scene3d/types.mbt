///|
pub(all) struct Material {
  color : @math3d.Vec4
  src_image_id : Int // -1 = no texture
  metallic : Double // 0.0 = dielectric (default)
  roughness : Double // 0.5 (default)
  emissive : @math3d.Vec3 // (0,0,0) (default)
}

///|
pub fn Material::new(
  color~ : @math3d.Vec4 = @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0),
  src_image_id~ : Int = -1,
  metallic~ : Double = 0.0,
  roughness~ : Double = 0.5,
  emissive~ : @math3d.Vec3 = @math3d.Vec3::new(0.0, 0.0, 0.0),
) -> Material {
  { color, src_image_id, metallic, roughness, emissive }
}

///|
pub(all) struct Object3D {
  mesh : @mesh3d.Mesh3D
  transform : @transform3d.Transform3D
  color : @math3d.Vec4
  material : Material?
  sort_bias : Double // positive = render earlier (farther), e.g. ground planes
}

///|
pub(all) struct Scene3D {
  objects : Array[Object3D]
  camera : @camera3d.Camera3D
  lighting : @light3d.LightingEnvironment
}

///|
/// Per-instance data for instanced rendering.
pub(all) struct InstanceData {
  transform : @transform3d.Transform3D
  color : @math3d.Vec4
}

///|
pub fn InstanceData::new(
  transform~ : @transform3d.Transform3D = @transform3d.Transform3D::new(),
  color~ : @math3d.Vec4 = @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0),
) -> InstanceData {
  { transform, color }
}
