///|
/// Spatial transform combining position, rotation, and scale.

///|
pub struct Transform3D {
  position : @math3d.Vec3
  rotation : @math3d.Quaternion
  scale : @math3d.Vec3
} derive(Debug)

///|
pub impl Show for Transform3D with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn Transform3D::new() -> Transform3D {
  {
    position: @math3d.Vec3::zero(),
    rotation: @math3d.Quaternion::identity(),
    scale: @math3d.Vec3::one(),
  }
}

///|
pub fn Transform3D::from_position(pos : @math3d.Vec3) -> Transform3D {
  {
    position: pos,
    rotation: @math3d.Quaternion::identity(),
    scale: @math3d.Vec3::one(),
  }
}

///|
pub fn Transform3D::from_position_rotation(
  pos : @math3d.Vec3,
  rot : @math3d.Quaternion,
) -> Transform3D {
  { position: pos, rotation: rot, scale: @math3d.Vec3::one() }
}

///|
pub fn Transform3D::from_components(
  pos : @math3d.Vec3,
  rot : @math3d.Quaternion,
  scale : @math3d.Vec3,
) -> Transform3D {
  { position: pos, rotation: rot, scale }
}

///|
fn is_translation_only_transform(transform : Transform3D) -> Bool {
  transform.rotation.x == 0.0 &&
  transform.rotation.y == 0.0 &&
  transform.rotation.z == 0.0 &&
  transform.rotation.w == 1.0 &&
  transform.scale.x == 1.0 &&
  transform.scale.y == 1.0 &&
  transform.scale.z == 1.0
}

///|
/// Compute model matrix as T * R * S.
pub fn Transform3D::to_mat4(self : Transform3D) -> @math3d.Mat4 {
  if is_translation_only_transform(self) {
    return @math3d.Mat4::translation(
      self.position.x,
      self.position.y,
      self.position.z,
    )
  }
  let t = @math3d.Mat4::translation(
    self.position.x,
    self.position.y,
    self.position.z,
  )
  let r = self.rotation.to_mat4()
  let s = @math3d.Mat4::scaling(self.scale.x, self.scale.y, self.scale.z)
  t.multiply(r).multiply(s)
}

///|
pub fn Transform3D::with_position(
  self : Transform3D,
  pos : @math3d.Vec3,
) -> Transform3D {
  { ..self, position: pos }
}

///|
pub fn Transform3D::with_rotation(
  self : Transform3D,
  rot : @math3d.Quaternion,
) -> Transform3D {
  { ..self, rotation: rot }
}

///|
pub fn Transform3D::with_scale(
  self : Transform3D,
  s : @math3d.Vec3,
) -> Transform3D {
  { ..self, scale: s }
}

///|
pub fn Transform3D::translate(
  self : Transform3D,
  delta : @math3d.Vec3,
) -> Transform3D {
  { ..self, position: self.position.add(delta) }
}

///|
pub fn Transform3D::rotate(
  self : Transform3D,
  additional : @math3d.Quaternion,
) -> Transform3D {
  { ..self, rotation: self.rotation.multiply(additional).normalize() }
}

///|
pub fn Transform3D::scale_by(
  self : Transform3D,
  factor : @math3d.Vec3,
) -> Transform3D {
  { ..self, scale: self.scale.mul(factor) }
}

///|
/// Forward direction (-Z rotated by quaternion).
pub fn Transform3D::forward(self : Transform3D) -> @math3d.Vec3 {
  self.rotation.rotate_vec3(@math3d.Vec3::new(0.0, 0.0, -1.0))
}

///|
/// Right direction (+X rotated by quaternion).
pub fn Transform3D::right(self : Transform3D) -> @math3d.Vec3 {
  self.rotation.rotate_vec3(@math3d.Vec3::new(1.0, 0.0, 0.0))
}

///|
/// Up direction (+Y rotated by quaternion).
pub fn Transform3D::up(self : Transform3D) -> @math3d.Vec3 {
  self.rotation.rotate_vec3(@math3d.Vec3::new(0.0, 1.0, 0.0))
}

///|
/// Set rotation to look at target from current position.
pub fn Transform3D::look_at(
  self : Transform3D,
  target : @math3d.Vec3,
  world_up : @math3d.Vec3,
) -> Transform3D {
  let forward = target.sub(self.position).normalize()
  let len = forward.length()
  if len < 1.0e-12 {
    return self
  }
  let right = forward.cross(world_up).normalize()
  if right.length() < 1.0e-12 {
    return self
  }
  let up = right.cross(forward)
  // Build rotation matrix (column-major), then extract quaternion.
  // Columns: right, up, -forward
  let rot = quaternion_from_axes(right, up, forward.negate())
  { ..self, rotation: rot }
}

///|
/// Decompose a Mat4 into Transform3D (translation, rotation, scale).
pub fn Transform3D::from_mat4(m : @math3d.Mat4) -> Transform3D {
  let e = m.elements
  // Translation: column 3
  let position = @math3d.Vec3::new(e[12], e[13], e[14])
  // Scale: length of each column vector
  let sx = @math3d.Vec3::new(e[0], e[1], e[2]).length()
  let sy = @math3d.Vec3::new(e[4], e[5], e[6]).length()
  let sz = @math3d.Vec3::new(e[8], e[9], e[10]).length()
  let scale = @math3d.Vec3::new(sx, sy, sz)
  // Rotation: normalize column vectors and extract quaternion
  let inv_sx = if sx > 1.0e-12 { 1.0 / sx } else { 0.0 }
  let inv_sy = if sy > 1.0e-12 { 1.0 / sy } else { 0.0 }
  let inv_sz = if sz > 1.0e-12 { 1.0 / sz } else { 0.0 }
  let right = @math3d.Vec3::new(e[0] * inv_sx, e[1] * inv_sx, e[2] * inv_sx)
  let up = @math3d.Vec3::new(e[4] * inv_sy, e[5] * inv_sy, e[6] * inv_sy)
  let forward = @math3d.Vec3::new(e[8] * inv_sz, e[9] * inv_sz, e[10] * inv_sz)
  let rotation = quaternion_from_axes(right, up, forward)
  { position, rotation, scale }
}

///|
/// Extract quaternion from orthonormal basis (right, up, forward columns).
fn quaternion_from_axes(
  right : @math3d.Vec3,
  up : @math3d.Vec3,
  forward : @math3d.Vec3,
) -> @math3d.Quaternion {
  // Matrix elements: m[row][col] where col0=right, col1=up, col2=forward
  let m00 = right.x
  let m10 = right.y
  let m20 = right.z
  let m01 = up.x
  let m11 = up.y
  let m21 = up.z
  let m02 = forward.x
  let m12 = forward.y
  let m22 = forward.z
  let trace = m00 + m11 + m22
  if trace > 0.0 {
    let s = 0.5 / (trace + 1.0).sqrt()
    @math3d.Quaternion::new(
      (m21 - m12) * s,
      (m02 - m20) * s,
      (m10 - m01) * s,
      0.25 / s,
    )
  } else if m00 > m11 && m00 > m22 {
    let s = 2.0 * (1.0 + m00 - m11 - m22).sqrt()
    @math3d.Quaternion::new(
      0.25 * s,
      (m01 + m10) / s,
      (m02 + m20) / s,
      (m21 - m12) / s,
    )
  } else if m11 > m22 {
    let s = 2.0 * (1.0 + m11 - m00 - m22).sqrt()
    @math3d.Quaternion::new(
      (m01 + m10) / s,
      0.25 * s,
      (m12 + m21) / s,
      (m02 - m20) / s,
    )
  } else {
    let s = 2.0 * (1.0 + m22 - m00 - m11).sqrt()
    @math3d.Quaternion::new(
      (m02 + m20) / s,
      (m12 + m21) / s,
      0.25 * s,
      (m10 - m01) / s,
    )
  }
}

///|
pub extend Transform3D with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Transform3D with Show::{to_string, output}
