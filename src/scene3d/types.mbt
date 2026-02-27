///|
pub(all) struct Object3D {
  mesh : @mesh3d.Mesh3D
  transform : @transform3d.Transform3D
  color : @math3d.Vec4
}

///|
pub(all) struct Scene3D {
  objects : Array[Object3D]
  camera : @camera3d.Camera3D
  lighting : @light3d.LightingEnvironment
}
