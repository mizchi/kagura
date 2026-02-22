///|
/// 3D vector and matrix math utilities.
///
/// Provides Vec3, Vec4, Mat4, and Quaternion types for 3D game math.
/// Mat4 uses column-major layout (GPU-compatible).

// ============================================================
// Vec3
// ============================================================

///|
pub struct Vec3 {
  x : Double
  y : Double
  z : Double
} derive(Show)

///|
pub fn Vec3::new(x : Double, y : Double, z : Double) -> Vec3 {
  { x, y, z }
}

///|
pub fn Vec3::zero() -> Vec3 {
  { x: 0.0, y: 0.0, z: 0.0 }
}

///|
pub fn Vec3::one() -> Vec3 {
  { x: 1.0, y: 1.0, z: 1.0 }
}

///|
pub fn Vec3::unit_x() -> Vec3 {
  { x: 1.0, y: 0.0, z: 0.0 }
}

///|
pub fn Vec3::unit_y() -> Vec3 {
  { x: 0.0, y: 1.0, z: 0.0 }
}

///|
pub fn Vec3::unit_z() -> Vec3 {
  { x: 0.0, y: 0.0, z: 1.0 }
}

///|
pub fn Vec3::add(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x + other.x, y: self.y + other.y, z: self.z + other.z }
}

///|
pub fn Vec3::sub(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x - other.x, y: self.y - other.y, z: self.z - other.z }
}

///|
pub fn Vec3::scale(self : Vec3, s : Double) -> Vec3 {
  { x: self.x * s, y: self.y * s, z: self.z * s }
}

///|
pub fn Vec3::negate(self : Vec3) -> Vec3 {
  { x: -self.x, y: -self.y, z: -self.z }
}

///|
pub fn Vec3::mul(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x * other.x, y: self.y * other.y, z: self.z * other.z }
}

///|
pub fn Vec3::div(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x / other.x, y: self.y / other.y, z: self.z / other.z }
}

///|
pub fn Vec3::dot(self : Vec3, other : Vec3) -> Double {
  self.x * other.x + self.y * other.y + self.z * other.z
}

///|
pub fn Vec3::cross(self : Vec3, other : Vec3) -> Vec3 {
  {
    x: self.y * other.z - self.z * other.y,
    y: self.z * other.x - self.x * other.z,
    z: self.x * other.y - self.y * other.x,
  }
}

///|
pub fn Vec3::length_squared(self : Vec3) -> Double {
  self.x * self.x + self.y * self.y + self.z * self.z
}

///|
pub fn Vec3::length(self : Vec3) -> Double {
  self.length_squared().sqrt()
}

///|
pub fn Vec3::normalize(self : Vec3) -> Vec3 {
  let len = self.length()
  if len < 1.0e-12 {
    Vec3::zero()
  } else {
    self.scale(1.0 / len)
  }
}

///|
pub fn Vec3::distance(self : Vec3, other : Vec3) -> Double {
  self.sub(other).length()
}

///|
pub fn Vec3::distance_squared(self : Vec3, other : Vec3) -> Double {
  self.sub(other).length_squared()
}

///|
pub fn Vec3::lerp(self : Vec3, other : Vec3, t : Double) -> Vec3 {
  {
    x: self.x + (other.x - self.x) * t,
    y: self.y + (other.y - self.y) * t,
    z: self.z + (other.z - self.z) * t,
  }
}

///|
pub fn Vec3::min(self : Vec3, other : Vec3) -> Vec3 {
  {
    x: @cmp.minimum(self.x, other.x),
    y: @cmp.minimum(self.y, other.y),
    z: @cmp.minimum(self.z, other.z),
  }
}

///|
pub fn Vec3::max(self : Vec3, other : Vec3) -> Vec3 {
  {
    x: @cmp.maximum(self.x, other.x),
    y: @cmp.maximum(self.y, other.y),
    z: @cmp.maximum(self.z, other.z),
  }
}

///|
pub fn Vec3::clamp(self : Vec3, min : Vec3, max : Vec3) -> Vec3 {
  self.max(min).min(max)
}

///|
pub fn Vec3::reflect(self : Vec3, normal : Vec3) -> Vec3 {
  self.sub(normal.scale(2.0 * self.dot(normal)))
}

///|
pub fn Vec3::approx_eq(self : Vec3, other : Vec3, epsilon : Double) -> Bool {
  (self.x - other.x).abs() < epsilon &&
  (self.y - other.y).abs() < epsilon &&
  (self.z - other.z).abs() < epsilon
}

// ============================================================
// Vec4
// ============================================================

///|
pub struct Vec4 {
  x : Double
  y : Double
  z : Double
  w : Double
} derive(Show)

///|
pub fn Vec4::new(x : Double, y : Double, z : Double, w : Double) -> Vec4 {
  { x, y, z, w }
}

///|
pub fn Vec4::zero() -> Vec4 {
  { x: 0.0, y: 0.0, z: 0.0, w: 0.0 }
}

///|
pub fn Vec4::from_vec3(v : Vec3, w : Double) -> Vec4 {
  { x: v.x, y: v.y, z: v.z, w }
}

///|
pub fn Vec4::to_vec3(self : Vec4) -> Vec3 {
  { x: self.x, y: self.y, z: self.z }
}

///|
pub fn Vec4::add(self : Vec4, other : Vec4) -> Vec4 {
  {
    x: self.x + other.x,
    y: self.y + other.y,
    z: self.z + other.z,
    w: self.w + other.w,
  }
}

///|
pub fn Vec4::sub(self : Vec4, other : Vec4) -> Vec4 {
  {
    x: self.x - other.x,
    y: self.y - other.y,
    z: self.z - other.z,
    w: self.w - other.w,
  }
}

///|
pub fn Vec4::scale(self : Vec4, s : Double) -> Vec4 {
  { x: self.x * s, y: self.y * s, z: self.z * s, w: self.w * s }
}

///|
pub fn Vec4::dot(self : Vec4, other : Vec4) -> Double {
  self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w
}

///|
pub fn Vec4::length(self : Vec4) -> Double {
  self.dot(self).sqrt()
}

///|
pub fn Vec4::normalize(self : Vec4) -> Vec4 {
  let len = self.length()
  if len < 1.0e-12 {
    Vec4::zero()
  } else {
    self.scale(1.0 / len)
  }
}

///|
pub fn Vec4::approx_eq(self : Vec4, other : Vec4, epsilon : Double) -> Bool {
  (self.x - other.x).abs() < epsilon &&
  (self.y - other.y).abs() < epsilon &&
  (self.z - other.z).abs() < epsilon &&
  (self.w - other.w).abs() < epsilon
}

// ============================================================
// Mat4 (4x4 matrix, column-major, GPU-compatible)
// ============================================================

///|
pub struct Mat4 {
  elements : FixedArray[Double]
} derive(Show)

///|
pub fn Mat4::identity() -> Mat4 {
  {
    elements: [
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
      0.0, 1.0,
    ],
  }
}

///|
pub fn Mat4::zero() -> Mat4 {
  {
    elements: [
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0,
    ],
  }
}

///|
/// Create Mat4 from four column vectors.
pub fn Mat4::from_cols(
  c0 : Vec4,
  c1 : Vec4,
  c2 : Vec4,
  c3 : Vec4,
) -> Mat4 {
  {
    elements: [
      c0.x, c0.y, c0.z, c0.w, c1.x, c1.y, c1.z, c1.w, c2.x, c2.y, c2.z, c2.w,
      c3.x, c3.y, c3.z, c3.w,
    ],
  }
}

///|
/// Access element at (row, col). Column-major: index = col * 4 + row.
fn Mat4::at(self : Mat4, row : Int, col : Int) -> Double {
  self.elements[col * 4 + row]
}

///|
/// Set element at (row, col).
fn Mat4::set(self : Mat4, row : Int, col : Int, value : Double) -> Unit {
  self.elements[col * 4 + row] = value
}

///|
pub fn Mat4::multiply(self : Mat4, other : Mat4) -> Mat4 {
  let result = Mat4::zero()
  for col in 0..<4 {
    for row in 0..<4 {
      let mut sum = 0.0
      for k in 0..<4 {
        sum = sum + self.at(row, k) * other.at(k, col)
      }
      result.set(row, col, sum)
    }
  }
  result
}

///|
pub fn Mat4::mul_vec4(self : Mat4, v : Vec4) -> Vec4 {
  {
    x: self.at(0, 0) * v.x +
      self.at(0, 1) * v.y +
      self.at(0, 2) * v.z +
      self.at(0, 3) * v.w,
    y: self.at(1, 0) * v.x +
      self.at(1, 1) * v.y +
      self.at(1, 2) * v.z +
      self.at(1, 3) * v.w,
    z: self.at(2, 0) * v.x +
      self.at(2, 1) * v.y +
      self.at(2, 2) * v.z +
      self.at(2, 3) * v.w,
    w: self.at(3, 0) * v.x +
      self.at(3, 1) * v.y +
      self.at(3, 2) * v.z +
      self.at(3, 3) * v.w,
  }
}

///|
pub fn Mat4::transpose(self : Mat4) -> Mat4 {
  let result = Mat4::zero()
  for row in 0..<4 {
    for col in 0..<4 {
      result.set(row, col, self.at(col, row))
    }
  }
  result
}

///|
pub fn Mat4::determinant(self : Mat4) -> Double {
  let m = self.elements
  let a00 = m[0]
  let a01 = m[1]
  let a02 = m[2]
  let a03 = m[3]
  let a10 = m[4]
  let a11 = m[5]
  let a12 = m[6]
  let a13 = m[7]
  let a20 = m[8]
  let a21 = m[9]
  let a22 = m[10]
  let a23 = m[11]
  let a30 = m[12]
  let a31 = m[13]
  let a32 = m[14]
  let a33 = m[15]
  let b00 = a00 * a11 - a01 * a10
  let b01 = a00 * a12 - a02 * a10
  let b02 = a00 * a13 - a03 * a10
  let b03 = a01 * a12 - a02 * a11
  let b04 = a01 * a13 - a03 * a11
  let b05 = a02 * a13 - a03 * a12
  let b06 = a20 * a31 - a21 * a30
  let b07 = a20 * a32 - a22 * a30
  let b08 = a20 * a33 - a23 * a30
  let b09 = a21 * a32 - a22 * a31
  let b10 = a21 * a33 - a23 * a31
  let b11 = a22 * a33 - a23 * a32
  b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06
}

///|
pub fn Mat4::inverse(self : Mat4) -> Mat4 {
  let m = self.elements
  let a00 = m[0]
  let a01 = m[1]
  let a02 = m[2]
  let a03 = m[3]
  let a10 = m[4]
  let a11 = m[5]
  let a12 = m[6]
  let a13 = m[7]
  let a20 = m[8]
  let a21 = m[9]
  let a22 = m[10]
  let a23 = m[11]
  let a30 = m[12]
  let a31 = m[13]
  let a32 = m[14]
  let a33 = m[15]
  let b00 = a00 * a11 - a01 * a10
  let b01 = a00 * a12 - a02 * a10
  let b02 = a00 * a13 - a03 * a10
  let b03 = a01 * a12 - a02 * a11
  let b04 = a01 * a13 - a03 * a11
  let b05 = a02 * a13 - a03 * a12
  let b06 = a20 * a31 - a21 * a30
  let b07 = a20 * a32 - a22 * a30
  let b08 = a20 * a33 - a23 * a30
  let b09 = a21 * a32 - a22 * a31
  let b10 = a21 * a33 - a23 * a31
  let b11 = a22 * a33 - a23 * a32
  let det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 +
    b05 * b06
  if det.abs() < 1.0e-12 {
    return Mat4::identity()
  }
  let inv_det = 1.0 / det
  let result = Mat4::zero()
  result.elements[0] = (a11 * b11 - a12 * b10 + a13 * b09) * inv_det
  result.elements[1] = (a02 * b10 - a01 * b11 - a03 * b09) * inv_det
  result.elements[2] = (a31 * b05 - a32 * b04 + a33 * b03) * inv_det
  result.elements[3] = (a22 * b04 - a21 * b05 - a23 * b03) * inv_det
  result.elements[4] = (a12 * b08 - a10 * b11 - a13 * b07) * inv_det
  result.elements[5] = (a00 * b11 - a02 * b08 + a03 * b07) * inv_det
  result.elements[6] = (a32 * b02 - a30 * b05 - a33 * b01) * inv_det
  result.elements[7] = (a20 * b05 - a22 * b02 + a23 * b01) * inv_det
  result.elements[8] = (a10 * b10 - a11 * b08 + a13 * b06) * inv_det
  result.elements[9] = (a01 * b08 - a00 * b10 - a03 * b06) * inv_det
  result.elements[10] = (a30 * b04 - a31 * b02 + a33 * b00) * inv_det
  result.elements[11] = (a21 * b02 - a20 * b04 - a23 * b00) * inv_det
  result.elements[12] = (a11 * b07 - a10 * b09 - a12 * b06) * inv_det
  result.elements[13] = (a00 * b09 - a01 * b07 + a02 * b06) * inv_det
  result.elements[14] = (a31 * b01 - a30 * b03 - a32 * b00) * inv_det
  result.elements[15] = (a20 * b03 - a21 * b01 + a22 * b00) * inv_det
  result
}

///|
pub fn Mat4::translation(x : Double, y : Double, z : Double) -> Mat4 {
  let m = Mat4::identity()
  m.elements[12] = x
  m.elements[13] = y
  m.elements[14] = z
  m
}

///|
pub fn Mat4::scaling(x : Double, y : Double, z : Double) -> Mat4 {
  let m = Mat4::zero()
  m.elements[0] = x
  m.elements[5] = y
  m.elements[10] = z
  m.elements[15] = 1.0
  m
}

///|
pub fn Mat4::rotation_x(angle_rad : Double) -> Mat4 {
  let c = @math.cos(angle_rad)
  let s = @math.sin(angle_rad)
  let m = Mat4::identity()
  m.elements[5] = c
  m.elements[6] = s
  m.elements[9] = -s
  m.elements[10] = c
  m
}

///|
pub fn Mat4::rotation_y(angle_rad : Double) -> Mat4 {
  let c = @math.cos(angle_rad)
  let s = @math.sin(angle_rad)
  let m = Mat4::identity()
  m.elements[0] = c
  m.elements[2] = -s
  m.elements[8] = s
  m.elements[10] = c
  m
}

///|
pub fn Mat4::rotation_z(angle_rad : Double) -> Mat4 {
  let c = @math.cos(angle_rad)
  let s = @math.sin(angle_rad)
  let m = Mat4::identity()
  m.elements[0] = c
  m.elements[1] = s
  m.elements[4] = -s
  m.elements[5] = c
  m
}

///|
/// Perspective projection matrix (WebGPU depth range [0, 1]).
pub fn Mat4::perspective(
  fov_y_rad : Double,
  aspect : Double,
  near : Double,
  far : Double,
) -> Mat4 {
  let f = 1.0 / @math.tan(fov_y_rad / 2.0)
  let nf = 1.0 / (near - far)
  let m = Mat4::zero()
  m.elements[0] = f / aspect
  m.elements[5] = f
  m.elements[10] = far * nf
  m.elements[11] = -1.0
  m.elements[14] = near * far * nf
  m
}

///|
/// Orthographic projection matrix (WebGPU depth range [0, 1]).
pub fn Mat4::orthographic(
  left : Double,
  right : Double,
  bottom : Double,
  top : Double,
  near : Double,
  far : Double,
) -> Mat4 {
  let lr = 1.0 / (left - right)
  let bt = 1.0 / (bottom - top)
  let nf = 1.0 / (near - far)
  let m = Mat4::zero()
  m.elements[0] = -2.0 * lr
  m.elements[5] = -2.0 * bt
  m.elements[10] = nf
  m.elements[12] = (left + right) * lr
  m.elements[13] = (top + bottom) * bt
  m.elements[14] = near * nf
  m.elements[15] = 1.0
  m
}

///|
/// View matrix from eye position, target point, and up direction.
pub fn Mat4::look_at(eye : Vec3, target : Vec3, up : Vec3) -> Mat4 {
  let f = target.sub(eye).normalize()
  let s = f.cross(up).normalize()
  let u = s.cross(f)
  let m = Mat4::identity()
  m.elements[0] = s.x
  m.elements[4] = s.y
  m.elements[8] = s.z
  m.elements[1] = u.x
  m.elements[5] = u.y
  m.elements[9] = u.z
  m.elements[2] = -f.x
  m.elements[6] = -f.y
  m.elements[10] = -f.z
  m.elements[12] = -s.dot(eye)
  m.elements[13] = -u.dot(eye)
  m.elements[14] = f.dot(eye)
  m
}

///|
pub fn Mat4::to_flat_array(self : Mat4) -> Array[Double] {
  let arr : Array[Double] = []
  for i in 0..<16 {
    arr.push(self.elements[i])
  }
  arr
}

///|
pub fn Mat4::approx_eq(self : Mat4, other : Mat4, epsilon : Double) -> Bool {
  for i in 0..<16 {
    if (self.elements[i] - other.elements[i]).abs() >= epsilon {
      return false
    }
  }
  true
}

// ============================================================
// Quaternion
// ============================================================

///|
pub struct Quaternion {
  x : Double
  y : Double
  z : Double
  w : Double
} derive(Show)

///|
pub fn Quaternion::identity() -> Quaternion {
  { x: 0.0, y: 0.0, z: 0.0, w: 1.0 }
}

///|
pub fn Quaternion::new(
  x : Double,
  y : Double,
  z : Double,
  w : Double,
) -> Quaternion {
  { x, y, z, w }
}

///|
pub fn Quaternion::from_axis_angle(axis : Vec3, angle_rad : Double) -> Quaternion {
  let half = angle_rad / 2.0
  let s = @math.sin(half)
  let a = axis.normalize()
  { x: a.x * s, y: a.y * s, z: a.z * s, w: @math.cos(half) }
}

///|
/// Create quaternion from Euler angles (XYZ rotation order).
pub fn Quaternion::from_euler(
  pitch : Double,
  yaw : Double,
  roll : Double,
) -> Quaternion {
  let cx = @math.cos(pitch / 2.0)
  let sx = @math.sin(pitch / 2.0)
  let cy = @math.cos(yaw / 2.0)
  let sy = @math.sin(yaw / 2.0)
  let cz = @math.cos(roll / 2.0)
  let sz = @math.sin(roll / 2.0)
  {
    x: sx * cy * cz + cx * sy * sz,
    y: cx * sy * cz - sx * cy * sz,
    z: cx * cy * sz + sx * sy * cz,
    w: cx * cy * cz - sx * sy * sz,
  }
}

///|
pub fn Quaternion::to_mat4(self : Quaternion) -> Mat4 {
  let x = self.x
  let y = self.y
  let z = self.z
  let w = self.w
  let x2 = x + x
  let y2 = y + y
  let z2 = z + z
  let xx = x * x2
  let xy = x * y2
  let xz = x * z2
  let yy = y * y2
  let yz = y * z2
  let zz = z * z2
  let wx = w * x2
  let wy = w * y2
  let wz = w * z2
  let m = Mat4::zero()
  m.elements[0] = 1.0 - yy - zz
  m.elements[1] = xy + wz
  m.elements[2] = xz - wy
  m.elements[4] = xy - wz
  m.elements[5] = 1.0 - xx - zz
  m.elements[6] = yz + wx
  m.elements[8] = xz + wy
  m.elements[9] = yz - wx
  m.elements[10] = 1.0 - xx - yy
  m.elements[15] = 1.0
  m
}

///|
pub fn Quaternion::rotate_vec3(self : Quaternion, v : Vec3) -> Vec3 {
  let qv = Vec3::new(self.x, self.y, self.z)
  let uv = qv.cross(v)
  let uuv = qv.cross(uv)
  v.add(uv.scale(2.0 * self.w)).add(uuv.scale(2.0))
}

///|
pub fn Quaternion::length(self : Quaternion) -> Double {
  (self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w).sqrt()
}

///|
pub fn Quaternion::normalize(self : Quaternion) -> Quaternion {
  let len = self.length()
  if len < 1.0e-12 {
    Quaternion::identity()
  } else {
    let inv = 1.0 / len
    { x: self.x * inv, y: self.y * inv, z: self.z * inv, w: self.w * inv }
  }
}

///|
pub fn Quaternion::multiply(self : Quaternion, other : Quaternion) -> Quaternion {
  {
    x: self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y,
    y: self.w * other.y - self.x * other.z + self.y * other.w + self.z * other.x,
    z: self.w * other.z + self.x * other.y - self.y * other.x + self.z * other.w,
    w: self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z,
  }
}

///|
pub fn Quaternion::conjugate(self : Quaternion) -> Quaternion {
  { x: -self.x, y: -self.y, z: -self.z, w: self.w }
}

///|
pub fn Quaternion::inverse(self : Quaternion) -> Quaternion {
  let len_sq = self.x * self.x +
    self.y * self.y +
    self.z * self.z +
    self.w * self.w
  if len_sq < 1.0e-12 {
    Quaternion::identity()
  } else {
    let inv = 1.0 / len_sq
    { x: -self.x * inv, y: -self.y * inv, z: -self.z * inv, w: self.w * inv }
  }
}

///|
/// Spherical linear interpolation with short-path correction.
/// Falls back to normalized lerp when quaternions are nearly parallel.
pub fn Quaternion::slerp(
  self : Quaternion,
  other : Quaternion,
  t : Double,
) -> Quaternion {
  let mut dot = self.x * other.x +
    self.y * other.y +
    self.z * other.z +
    self.w * other.w
  let mut bx = other.x
  let mut by = other.y
  let mut bz = other.z
  let mut bw = other.w
  // Short path: negate if dot < 0
  if dot < 0.0 {
    dot = -dot
    bx = -bx
    by = -by
    bz = -bz
    bw = -bw
  }
  // Nearly parallel: use nlerp fallback
  if dot > 0.9995 {
    let rx = self.x + (bx - self.x) * t
    let ry = self.y + (by - self.y) * t
    let rz = self.z + (bz - self.z) * t
    let rw = self.w + (bw - self.w) * t
    Quaternion::new(rx, ry, rz, rw).normalize()
  } else {
    let theta = @math.acos(dot)
    let sin_theta = @math.sin(theta)
    let s0 = @math.sin((1.0 - t) * theta) / sin_theta
    let s1 = @math.sin(t * theta) / sin_theta
    {
      x: self.x * s0 + bx * s1,
      y: self.y * s0 + by * s1,
      z: self.z * s0 + bz * s1,
      w: self.w * s0 + bw * s1,
    }
  }
}

///|
pub fn Quaternion::approx_eq(
  self : Quaternion,
  other : Quaternion,
  epsilon : Double,
) -> Bool {
  (self.x - other.x).abs() < epsilon &&
  (self.y - other.y).abs() < epsilon &&
  (self.z - other.z).abs() < epsilon &&
  (self.w - other.w).abs() < epsilon
}
