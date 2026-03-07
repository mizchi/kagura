// ============================================================
// Shared helpers for 3D rendering (frustum culling, AABB, transforms)
// ============================================================

// ============================================================
// Frustum Culling
// ============================================================

///|
/// A plane in Hessian normal form: nx*x + ny*y + nz*z + d = 0
priv struct Plane {
  nx : Double
  ny : Double
  nz : Double
  d : Double
}

///|
/// Six clipping planes extracted from the view-projection matrix.
priv struct Frustum {
  planes : FixedArray[Plane] // 6 planes: left, right, bottom, top, near, far
}

///|
/// Extract 6 frustum planes from a view-projection matrix (Griggs-Hartmann method).
fn Frustum::from_vp(vp : @math3d.Mat4) -> Frustum {
  let e = vp.elements
  // Row vectors of the VP matrix
  let r0x = e[0]
  let r0y = e[4]
  let r0z = e[8]
  let r0w = e[12]
  let r1x = e[1]
  let r1y = e[5]
  let r1z = e[9]
  let r1w = e[13]
  let r2x = e[2]
  let r2y = e[6]
  let r2z = e[10]
  let r2w = e[14]
  let r3x = e[3]
  let r3y = e[7]
  let r3z = e[11]
  let r3w = e[15]
  let planes : FixedArray[Plane] = FixedArray::make(6, {
    nx: 0.0,
    ny: 0.0,
    nz: 0.0,
    d: 0.0,
  })
  // Left:   row3 + row0
  planes[0] = normalize_plane(r3x + r0x, r3y + r0y, r3z + r0z, r3w + r0w)
  // Right:  row3 - row0
  planes[1] = normalize_plane(r3x - r0x, r3y - r0y, r3z - r0z, r3w - r0w)
  // Bottom: row3 + row1
  planes[2] = normalize_plane(r3x + r1x, r3y + r1y, r3z + r1z, r3w + r1w)
  // Top:    row3 - row1
  planes[3] = normalize_plane(r3x - r1x, r3y - r1y, r3z - r1z, r3w - r1w)
  // Near:   row3 + row2
  planes[4] = normalize_plane(r3x + r2x, r3y + r2y, r3z + r2z, r3w + r2w)
  // Far:    row3 - row2
  planes[5] = normalize_plane(r3x - r2x, r3y - r2y, r3z - r2z, r3w - r2w)
  { planes, }
}

///|
fn normalize_plane(a : Double, b : Double, c : Double, d : Double) -> Plane {
  let len = (a * a + b * b + c * c).sqrt()
  if len < 1.0e-10 {
    { nx: 0.0, ny: 0.0, nz: 0.0, d: 0.0 }
  } else {
    let inv = 1.0 / len
    { nx: a * inv, ny: b * inv, nz: c * inv, d: d * inv }
  }
}

///|
/// Test if an AABB is completely outside the frustum (returns true if culled).
/// Uses p-vertex test for each plane.
fn frustum_cull_aabb(
  frustum : Frustum,
  min_x : Double,
  min_y : Double,
  min_z : Double,
  max_x : Double,
  max_y : Double,
  max_z : Double,
) -> Bool {
  for i in 0..<6 {
    let p = frustum.planes[i]
    // p-vertex: the corner of the AABB most in the direction of the plane normal
    let px = if p.nx >= 0.0 { max_x } else { min_x }
    let py = if p.ny >= 0.0 { max_y } else { min_y }
    let pz = if p.nz >= 0.0 { max_z } else { min_z }
    if p.nx * px + p.ny * py + p.nz * pz + p.d < 0.0 {
      return true
    }
  }
  false
}

///|
/// Compute object-space AABB from mesh vertex data.
fn compute_mesh_aabb(
  mesh : @mesh3d.Mesh3D,
) -> (Double, Double, Double, Double, Double, Double) {
  let bounds = mesh.bounds()
  (
    bounds.min_x,
    bounds.min_y,
    bounds.min_z,
    bounds.max_x,
    bounds.max_y,
    bounds.max_z,
  )
}

///|
/// Transform an object-space AABB to world-space using Arvo's method.
fn transform_aabb(
  min_x : Double,
  min_y : Double,
  min_z : Double,
  max_x : Double,
  max_y : Double,
  max_z : Double,
  model : @math3d.Mat4,
) -> (Double, Double, Double, Double, Double, Double) {
  let e = model.elements
  // Start with translation
  let mut wmin_x = e[12]
  let mut wmin_y = e[13]
  let mut wmin_z = e[14]
  let mut wmax_x = wmin_x
  let mut wmax_y = wmin_y
  let mut wmax_z = wmin_z
  // For each axis (column), accumulate min/max contributions
  let mins = [min_x, min_y, min_z]
  let maxs = [max_x, max_y, max_z]
  for j in 0..<3 {
    let a0 = e[j * 4] * mins[j]
    let b0 = e[j * 4] * maxs[j]
    if a0 < b0 {
      wmin_x = wmin_x + a0
      wmax_x = wmax_x + b0
    } else {
      wmin_x = wmin_x + b0
      wmax_x = wmax_x + a0
    }
    let a1 = e[j * 4 + 1] * mins[j]
    let b1 = e[j * 4 + 1] * maxs[j]
    if a1 < b1 {
      wmin_y = wmin_y + a1
      wmax_y = wmax_y + b1
    } else {
      wmin_y = wmin_y + b1
      wmax_y = wmax_y + a1
    }
    let a2 = e[j * 4 + 2] * mins[j]
    let b2 = e[j * 4 + 2] * maxs[j]
    if a2 < b2 {
      wmin_z = wmin_z + a2
      wmax_z = wmax_z + b2
    } else {
      wmin_z = wmin_z + b2
      wmax_z = wmax_z + a2
    }
  }
  (wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z)
}
