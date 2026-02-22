///|
fn approx(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-9
}

///|
let pi : Double = 3.14159265358979323846

// ============================================================
// Vec3 Tests
// ============================================================

///|
test "Vec3 constructors" {
  let z = Vec3::zero()
  assert_eq(z.x, 0.0)
  assert_eq(z.y, 0.0)
  assert_eq(z.z, 0.0)
  let o = Vec3::one()
  assert_eq(o.x, 1.0)
  assert_eq(o.y, 1.0)
  assert_eq(o.z, 1.0)
  let ux = Vec3::unit_x()
  assert_eq(ux.x, 1.0)
  assert_eq(ux.y, 0.0)
  assert_eq(ux.z, 0.0)
  let uy = Vec3::unit_y()
  assert_eq(uy.x, 0.0)
  assert_eq(uy.y, 1.0)
  assert_eq(uy.z, 0.0)
  let uz = Vec3::unit_z()
  assert_eq(uz.x, 0.0)
  assert_eq(uz.y, 0.0)
  assert_eq(uz.z, 1.0)
}

///|
test "Vec3 arithmetic" {
  let a = Vec3::new(1.0, 2.0, 3.0)
  let b = Vec3::new(4.0, 5.0, 6.0)
  let sum = a.add(b)
  assert_eq(sum.x, 5.0)
  assert_eq(sum.y, 7.0)
  assert_eq(sum.z, 9.0)
  let diff = a.sub(b)
  assert_eq(diff.x, -3.0)
  assert_eq(diff.y, -3.0)
  assert_eq(diff.z, -3.0)
  let scaled = a.scale(2.0)
  assert_eq(scaled.x, 2.0)
  assert_eq(scaled.y, 4.0)
  assert_eq(scaled.z, 6.0)
  let neg = a.negate()
  assert_eq(neg.x, -1.0)
  assert_eq(neg.y, -2.0)
  assert_eq(neg.z, -3.0)
  let m = a.mul(b)
  assert_eq(m.x, 4.0)
  assert_eq(m.y, 10.0)
  assert_eq(m.z, 18.0)
  let d = b.div(a)
  assert_eq(d.x, 4.0)
  assert_true(approx(d.y, 2.5))
  assert_eq(d.z, 2.0)
}

///|
test "Vec3 dot and cross" {
  let a = Vec3::new(1.0, 0.0, 0.0)
  let b = Vec3::new(0.0, 1.0, 0.0)
  assert_eq(a.dot(b), 0.0)
  let c = a.cross(b)
  assert_eq(c.x, 0.0)
  assert_eq(c.y, 0.0)
  assert_eq(c.z, 1.0)
  let d = Vec3::new(2.0, 3.0, 4.0)
  let e = Vec3::new(5.0, 6.0, 7.0)
  assert_eq(d.dot(e), 56.0)
  let f = d.cross(e)
  assert_eq(f.x, -3.0)
  assert_eq(f.y, 6.0)
  assert_eq(f.z, -3.0)
}

///|
test "Vec3 length and normalize" {
  let v = Vec3::new(3.0, 4.0, 0.0)
  assert_eq(v.length_squared(), 25.0)
  assert_eq(v.length(), 5.0)
  let n = v.normalize()
  assert_true(approx(n.x, 0.6))
  assert_true(approx(n.y, 0.8))
  assert_true(approx(n.z, 0.0))
  assert_true(approx(n.length(), 1.0))
  let z = Vec3::zero().normalize()
  assert_eq(z.x, 0.0)
  assert_eq(z.y, 0.0)
  assert_eq(z.z, 0.0)
}

///|
test "Vec3 distance" {
  let a = Vec3::new(1.0, 2.0, 3.0)
  let b = Vec3::new(4.0, 6.0, 3.0)
  assert_eq(a.distance(b), 5.0)
  assert_eq(a.distance_squared(b), 25.0)
}

///|
test "Vec3 lerp" {
  let a = Vec3::new(0.0, 0.0, 0.0)
  let b = Vec3::new(10.0, 20.0, 30.0)
  let mid = a.lerp(b, 0.5)
  assert_eq(mid.x, 5.0)
  assert_eq(mid.y, 10.0)
  assert_eq(mid.z, 15.0)
  let start = a.lerp(b, 0.0)
  assert_eq(start.x, 0.0)
  let end_ = a.lerp(b, 1.0)
  assert_eq(end_.x, 10.0)
}

///|
test "Vec3 min max clamp" {
  let a = Vec3::new(1.0, 5.0, 3.0)
  let b = Vec3::new(4.0, 2.0, 6.0)
  let mn = a.min(b)
  assert_eq(mn.x, 1.0)
  assert_eq(mn.y, 2.0)
  assert_eq(mn.z, 3.0)
  let mx = a.max(b)
  assert_eq(mx.x, 4.0)
  assert_eq(mx.y, 5.0)
  assert_eq(mx.z, 6.0)
  let v = Vec3::new(-1.0, 10.0, 5.0)
  let clamped = v.clamp(Vec3::zero(), Vec3::new(5.0, 5.0, 5.0))
  assert_eq(clamped.x, 0.0)
  assert_eq(clamped.y, 5.0)
  assert_eq(clamped.z, 5.0)
}

///|
test "Vec3 reflect" {
  let v = Vec3::new(1.0, -1.0, 0.0)
  let n = Vec3::new(0.0, 1.0, 0.0)
  let r = v.reflect(n)
  assert_true(approx(r.x, 1.0))
  assert_true(approx(r.y, 1.0))
  assert_true(approx(r.z, 0.0))
}

///|
test "Vec3 approx_eq" {
  let a = Vec3::new(1.0, 2.0, 3.0)
  let b = Vec3::new(1.0000001, 2.0000001, 3.0000001)
  assert_true(a.approx_eq(b, 0.001))
  assert_false(a.approx_eq(Vec3::new(1.1, 2.0, 3.0), 0.01))
}

// ============================================================
// Vec4 Tests
// ============================================================

///|
test "Vec4 constructors" {
  let z = Vec4::zero()
  assert_eq(z.x, 0.0)
  assert_eq(z.w, 0.0)
  let v3 = Vec3::new(1.0, 2.0, 3.0)
  let v4 = Vec4::from_vec3(v3, 1.0)
  assert_eq(v4.x, 1.0)
  assert_eq(v4.y, 2.0)
  assert_eq(v4.z, 3.0)
  assert_eq(v4.w, 1.0)
  let back = v4.to_vec3()
  assert_eq(back.x, 1.0)
  assert_eq(back.z, 3.0)
}

///|
test "Vec4 arithmetic" {
  let a = Vec4::new(1.0, 2.0, 3.0, 4.0)
  let b = Vec4::new(5.0, 6.0, 7.0, 8.0)
  let sum = a.add(b)
  assert_eq(sum.x, 6.0)
  assert_eq(sum.w, 12.0)
  let diff = a.sub(b)
  assert_eq(diff.x, -4.0)
  let scaled = a.scale(2.0)
  assert_eq(scaled.x, 2.0)
  assert_eq(scaled.w, 8.0)
  assert_eq(a.dot(b), 70.0)
}

///|
test "Vec4 length and normalize" {
  let v = Vec4::new(1.0, 0.0, 0.0, 0.0)
  assert_eq(v.length(), 1.0)
  let v2 = Vec4::new(2.0, 0.0, 0.0, 0.0)
  let n = v2.normalize()
  assert_true(approx(n.x, 1.0))
  assert_true(approx(n.length(), 1.0))
}

///|
test "Vec4 approx_eq" {
  let a = Vec4::new(1.0, 2.0, 3.0, 4.0)
  let b = Vec4::new(1.0001, 2.0001, 3.0001, 4.0001)
  assert_true(a.approx_eq(b, 0.001))
  assert_false(a.approx_eq(b, 0.00001))
}

// ============================================================
// Mat4 Tests
// ============================================================

///|
test "Mat4 identity" {
  let m = Mat4::identity()
  assert_eq(m.elements[0], 1.0)
  assert_eq(m.elements[5], 1.0)
  assert_eq(m.elements[10], 1.0)
  assert_eq(m.elements[15], 1.0)
  assert_eq(m.elements[1], 0.0)
  assert_eq(m.elements[4], 0.0)
}

///|
test "Mat4 identity multiply" {
  let id = Mat4::identity()
  let m = Mat4::translation(1.0, 2.0, 3.0)
  let result = id.multiply(m)
  assert_true(result.approx_eq(m, 1.0e-9))
  let result2 = m.multiply(id)
  assert_true(result2.approx_eq(m, 1.0e-9))
}

///|
test "Mat4 mul_vec4" {
  let m = Mat4::translation(10.0, 20.0, 30.0)
  let v = Vec4::new(1.0, 2.0, 3.0, 1.0)
  let result = m.mul_vec4(v)
  assert_true(approx(result.x, 11.0))
  assert_true(approx(result.y, 22.0))
  assert_true(approx(result.z, 33.0))
  assert_true(approx(result.w, 1.0))
}

///|
test "Mat4 transpose" {
  let m = Mat4::from_cols(
    Vec4::new(1.0, 2.0, 3.0, 4.0),
    Vec4::new(5.0, 6.0, 7.0, 8.0),
    Vec4::new(9.0, 10.0, 11.0, 12.0),
    Vec4::new(13.0, 14.0, 15.0, 16.0),
  )
  let t = m.transpose()
  // Column-major: m.at(row, col) = elements[col*4+row]
  // Transposed: t.at(row, col) = m.at(col, row)
  assert_eq(t.at(0, 0), 1.0)
  assert_eq(t.at(0, 1), 2.0) // was m.at(1, 0)
  assert_eq(t.at(1, 0), 5.0) // was m.at(0, 1)
}

///|
test "Mat4 determinant identity" {
  let id = Mat4::identity()
  assert_true(approx(id.determinant(), 1.0))
}

///|
test "Mat4 inverse" {
  let m = Mat4::translation(3.0, 4.0, 5.0)
  let inv = m.inverse()
  let product = m.multiply(inv)
  assert_true(product.approx_eq(Mat4::identity(), 1.0e-9))
}

///|
test "Mat4 inverse scaling" {
  let m = Mat4::scaling(2.0, 3.0, 4.0)
  let inv = m.inverse()
  let product = m.multiply(inv)
  assert_true(product.approx_eq(Mat4::identity(), 1.0e-9))
}

///|
test "Mat4 translation" {
  let m = Mat4::translation(5.0, 10.0, 15.0)
  // Column-major: translation in column 3
  assert_eq(m.elements[12], 5.0)
  assert_eq(m.elements[13], 10.0)
  assert_eq(m.elements[14], 15.0)
}

///|
test "Mat4 scaling" {
  let m = Mat4::scaling(2.0, 3.0, 4.0)
  assert_eq(m.elements[0], 2.0)
  assert_eq(m.elements[5], 3.0)
  assert_eq(m.elements[10], 4.0)
}

///|
test "Mat4 rotation_x" {
  let m = Mat4::rotation_x(pi / 2.0)
  // Rotating (0, 1, 0) by 90 degrees around X should give (0, 0, 1)
  let v = Vec4::new(0.0, 1.0, 0.0, 1.0)
  let result = m.mul_vec4(v)
  assert_true(approx(result.x, 0.0))
  assert_true(approx(result.y, 0.0))
  assert_true(approx(result.z, 1.0))
}

///|
test "Mat4 rotation_y" {
  let m = Mat4::rotation_y(pi / 2.0)
  // Rotating (0, 0, 1) by 90 degrees around Y should give (1, 0, 0)
  let v = Vec4::new(0.0, 0.0, 1.0, 1.0)
  let result = m.mul_vec4(v)
  assert_true(approx(result.x, 1.0))
  assert_true(approx(result.y, 0.0))
  assert_true(approx(result.z, 0.0))
}

///|
test "Mat4 rotation_z" {
  let m = Mat4::rotation_z(pi / 2.0)
  // Rotating (1, 0, 0) by 90 degrees around Z should give (0, 1, 0)
  let v = Vec4::new(1.0, 0.0, 0.0, 1.0)
  let result = m.mul_vec4(v)
  assert_true(approx(result.x, 0.0))
  assert_true(approx(result.y, 1.0))
  assert_true(approx(result.z, 0.0))
}

///|
test "Mat4 perspective" {
  let m = Mat4::perspective(pi / 4.0, 16.0 / 9.0, 0.1, 100.0)
  // Should not be zero
  assert_true(m.elements[0] != 0.0)
  assert_true(m.elements[5] != 0.0)
  // element[11] should be -1 for perspective
  assert_true(approx(m.elements[11], -1.0))
  // element[15] should be 0
  assert_true(approx(m.elements[15], 0.0))
}

///|
test "Mat4 orthographic" {
  let m = Mat4::orthographic(-1.0, 1.0, -1.0, 1.0, 0.1, 100.0)
  // Diagonal should have scaling values
  assert_true(m.elements[0] != 0.0)
  assert_true(m.elements[5] != 0.0)
  assert_true(m.elements[10] != 0.0)
  assert_eq(m.elements[15], 1.0)
}

///|
test "Mat4 look_at" {
  let eye = Vec3::new(0.0, 0.0, 5.0)
  let target = Vec3::zero()
  let up = Vec3::unit_y()
  let view = Mat4::look_at(eye, target, up)
  // Transform eye position: should be at origin in view space
  let eye_view = view.mul_vec4(Vec4::from_vec3(eye, 1.0))
  assert_true(approx(eye_view.x, 0.0))
  assert_true(approx(eye_view.y, 0.0))
  assert_true(approx(eye_view.z, 0.0))
}

///|
test "Mat4 to_flat_array" {
  let m = Mat4::identity()
  let arr = m.to_flat_array()
  assert_eq(arr.length(), 16)
  assert_eq(arr[0], 1.0)
  assert_eq(arr[5], 1.0)
  assert_eq(arr[10], 1.0)
  assert_eq(arr[15], 1.0)
}

///|
test "Mat4 from_cols" {
  let m = Mat4::from_cols(
    Vec4::new(1.0, 0.0, 0.0, 0.0),
    Vec4::new(0.0, 1.0, 0.0, 0.0),
    Vec4::new(0.0, 0.0, 1.0, 0.0),
    Vec4::new(0.0, 0.0, 0.0, 1.0),
  )
  assert_true(m.approx_eq(Mat4::identity(), 1.0e-9))
}

// ============================================================
// Quaternion Tests
// ============================================================

///|
test "Quaternion identity" {
  let q = Quaternion::identity()
  assert_eq(q.x, 0.0)
  assert_eq(q.y, 0.0)
  assert_eq(q.z, 0.0)
  assert_eq(q.w, 1.0)
}

///|
test "Quaternion from_axis_angle" {
  let q = Quaternion::from_axis_angle(Vec3::unit_y(), pi / 2.0)
  assert_true(approx(q.length(), 1.0))
  // Rotate (1, 0, 0) by 90 around Y: should get (0, 0, -1)
  let v = Vec3::new(1.0, 0.0, 0.0)
  let result = q.rotate_vec3(v)
  assert_true(approx(result.x, 0.0))
  assert_true(approx(result.y, 0.0))
  assert_true(approx(result.z, -1.0))
}

///|
test "Quaternion from_euler" {
  // 90 degrees around X
  let q = Quaternion::from_euler(pi / 2.0, 0.0, 0.0)
  let v = Vec3::new(0.0, 1.0, 0.0)
  let result = q.rotate_vec3(v)
  assert_true(approx(result.x, 0.0))
  assert_true(approx(result.y, 0.0))
  assert_true(approx(result.z, 1.0))
}

///|
test "Quaternion to_mat4" {
  let q = Quaternion::from_axis_angle(Vec3::unit_z(), pi / 2.0)
  let m = q.to_mat4()
  // Should match rotation_z(pi/2)
  let expected = Mat4::rotation_z(pi / 2.0)
  assert_true(m.approx_eq(expected, 1.0e-9))
}

///|
test "Quaternion multiply" {
  let q1 = Quaternion::from_axis_angle(Vec3::unit_y(), pi / 2.0)
  let q2 = Quaternion::from_axis_angle(Vec3::unit_y(), pi / 2.0)
  let combined = q1.multiply(q2)
  // Two 90-degree rotations = 180 degrees
  let v = Vec3::new(1.0, 0.0, 0.0)
  let result = combined.rotate_vec3(v)
  assert_true(approx(result.x, -1.0))
  assert_true(approx(result.y, 0.0))
  assert_true(approx(result.z, 0.0))
}

///|
test "Quaternion conjugate and inverse" {
  let q = Quaternion::from_axis_angle(Vec3::unit_x(), pi / 4.0)
  let conj = q.conjugate()
  assert_eq(conj.x, -q.x)
  assert_eq(conj.y, -q.y)
  assert_eq(conj.z, -q.z)
  assert_eq(conj.w, q.w)
  let inv = q.inverse()
  let product = q.multiply(inv)
  assert_true(product.approx_eq(Quaternion::identity(), 1.0e-9))
}

///|
test "Quaternion slerp" {
  let q1 = Quaternion::identity()
  let q2 = Quaternion::from_axis_angle(Vec3::unit_y(), pi)
  let mid = q1.slerp(q2, 0.5)
  assert_true(approx(mid.length(), 1.0))
  // At t=0 should be q1
  let start = q1.slerp(q2, 0.0)
  assert_true(start.approx_eq(q1, 1.0e-9))
  // At t=1 should be q2
  let end_ = q1.slerp(q2, 1.0)
  assert_true(end_.approx_eq(q2, 1.0e-9))
}

///|
test "Quaternion slerp nlerp fallback" {
  let q = Quaternion::identity()
  // Same quaternion: dot ~= 1.0, should use nlerp
  let result = q.slerp(q, 0.5)
  assert_true(result.approx_eq(q, 1.0e-9))
}

///|
test "Quaternion normalize" {
  let q = Quaternion::new(1.0, 2.0, 3.0, 4.0)
  let n = q.normalize()
  assert_true(approx(n.length(), 1.0))
}

///|
test "Quaternion approx_eq" {
  let a = Quaternion::new(0.0, 0.0, 0.0, 1.0)
  let b = Quaternion::new(0.0, 0.0, 0.0, 1.0001)
  assert_true(a.approx_eq(b, 0.001))
  assert_false(a.approx_eq(b, 0.00001))
}
