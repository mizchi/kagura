// ============================================================
// CPU-side software 3D rendering for 2D pipeline
// ============================================================

///|
let bucket_count : Int = 8

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
  let planes : FixedArray[Plane] = FixedArray::make(
    6,
    { nx: 0.0, ny: 0.0, nz: 0.0, d: 0.0 },
  )
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
  let vdata = mesh.vertex_data
  let stride = 8
  let vert_count = vdata.length() / stride
  if vert_count == 0 {
    return (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  }
  let mut min_x = vdata[0]
  let mut min_y = vdata[1]
  let mut min_z = vdata[2]
  let mut max_x = min_x
  let mut max_y = min_y
  let mut max_z = min_z
  for i in 1..<vert_count {
    let x = vdata[i * stride]
    let y = vdata[i * stride + 1]
    let z = vdata[i * stride + 2]
    if x < min_x { min_x = x }
    if y < min_y { min_y = y }
    if z < min_z { min_z = z }
    if x > max_x { max_x = x }
    if y > max_y { max_y = y }
    if z > max_z { max_z = z }
  }
  (min_x, min_y, min_z, max_x, max_y, max_z)
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

///|
priv struct MeshBatch {
  vertices : Array[Double] // flat vertex buffer, stride 4 (x,y,u,v)
  indices : Array[Int] // index buffer
  color_dwords : Array[Int] // single color [r,g,b,a] for the batch
  src_image_id : Int // -1 = no texture
  mut tri_count : Int // number of visible triangles
}

///|
fn MeshBatch::new(
  color_dwords : Array[Int],
  src_image_id? : Int = -1,
) -> MeshBatch {
  { vertices: [], indices: [], color_dwords, src_image_id, tri_count: 0 }
}

///|
fn clamp01(v : Double) -> Double {
  if v < 0.0 {
    0.0
  } else if v > 1.0 {
    1.0
  } else {
    v
  }
}

///|
fn to_byte(v : Double) -> Int {
  let clamped = clamp01(v)
  let result = (clamped * 255.0 + 0.5).to_int()
  if result > 255 {
    255
  } else if result < 0 {
    0
  } else {
    result
  }
}

///|
/// Compute per-bucket lighting colors (8 brightness levels).
/// Returns an array of 8 color_dwords arrays, indexed by brightness bucket.
fn compute_bucket_colors(
  lighting : @light3d.LightingEnvironment,
  color : @math3d.Vec4,
) -> Array[Array[Int]] {
  let amb_r = lighting.ambient.color.x * lighting.ambient.intensity
  let amb_g = lighting.ambient.color.y * lighting.ambient.intensity
  let amb_b = lighting.ambient.color.z * lighting.ambient.intensity
  let dir_r = lighting.directional.color.x * lighting.directional.intensity
  let dir_g = lighting.directional.color.y * lighting.directional.intensity
  let dir_b = lighting.directional.color.z * lighting.directional.intensity
  let result : Array[Array[Int]] = []
  for i in 0..<bucket_count {
    let brightness = i.to_double() / (bucket_count - 1).to_double()
    result.push([
      to_byte(color.x * (amb_r + dir_r * brightness)),
      to_byte(color.y * (amb_g + dir_g * brightness)),
      to_byte(color.z * (amb_b + dir_b * brightness)),
      to_byte(color.w),
    ])
  }
  result
}

///|
/// Transform a point by a 4x4 matrix (manual multiply with perspective divide components).
fn mat4_transform(
  m : @math3d.Mat4,
  x : Double,
  y : Double,
  z : Double,
) -> (Double, Double, Double, Double) {
  let e = m.elements
  let rx = e[0] * x + e[4] * y + e[8] * z + e[12]
  let ry = e[1] * x + e[5] * y + e[9] * z + e[13]
  let rz = e[2] * x + e[6] * y + e[10] * z + e[14]
  let rw = e[3] * x + e[7] * y + e[11] * z + e[15]
  (rx, ry, rz, rw)
}

///|
/// Transform a normal vector by the upper-left 3x3 of a model matrix and normalize.
fn transform_normal_3x3(
  model : @math3d.Mat4,
  nx : Double,
  ny : Double,
  nz : Double,
) -> @math3d.Vec3 {
  let e = model.elements
  let rx = e[0] * nx + e[4] * ny + e[8] * nz
  let ry = e[1] * nx + e[5] * ny + e[9] * nz
  let rz = e[2] * nx + e[6] * ny + e[10] * nz
  @math3d.Vec3::new(rx, ry, rz).normalize()
}

///|
/// Affine transform a point (no perspective divide).
fn mat4_transform_point(
  m : @math3d.Mat4,
  x : Double,
  y : Double,
  z : Double,
) -> @math3d.Vec3 {
  let e = m.elements
  @math3d.Vec3::new(
    e[0] * x + e[4] * y + e[8] * z + e[12],
    e[1] * x + e[5] * y + e[9] * z + e[13],
    e[2] * x + e[6] * y + e[10] * z + e[14],
  )
}

///|
/// Compute extra brightness contribution from point and spot lights at a world-space position.
fn compute_extra_brightness(
  world_pos : @math3d.Vec3,
  world_normal : @math3d.Vec3,
  point_lights : Array[@light3d.PointLight],
  spot_lights : Array[@light3d.SpotLight],
) -> Double {
  let mut extra = 0.0
  for i in 0..<point_lights.length() {
    let pl = point_lights[i]
    let to_light_x = pl.position.x - world_pos.x
    let to_light_y = pl.position.y - world_pos.y
    let to_light_z = pl.position.z - world_pos.z
    let dist_sq = to_light_x * to_light_x +
      to_light_y * to_light_y +
      to_light_z * to_light_z
    let dist = dist_sq.sqrt()
    if dist < 1.0e-6 || dist > pl.radius {
      continue
    }
    let inv_dist = 1.0 / dist
    let lx = to_light_x * inv_dist
    let ly = to_light_y * inv_dist
    let lz = to_light_z * inv_dist
    let ndotl = world_normal.x * lx + world_normal.y * ly + world_normal.z * lz
    if ndotl <= 0.0 {
      continue
    }
    let ratio = dist / pl.radius
    let atten = clamp01(1.0 - ratio * ratio)
    extra = extra + ndotl * atten * pl.intensity
  }
  for i in 0..<spot_lights.length() {
    let sl = spot_lights[i]
    let to_light_x = sl.position.x - world_pos.x
    let to_light_y = sl.position.y - world_pos.y
    let to_light_z = sl.position.z - world_pos.z
    let dist_sq = to_light_x * to_light_x +
      to_light_y * to_light_y +
      to_light_z * to_light_z
    let dist = dist_sq.sqrt()
    if dist < 1.0e-6 || dist > sl.radius {
      continue
    }
    let inv_dist = 1.0 / dist
    let lx = to_light_x * inv_dist
    let ly = to_light_y * inv_dist
    let lz = to_light_z * inv_dist
    // Check cone angle: dot(neg_light_dir, spot_direction)
    // neg_light_dir = direction from light to surface = -to_light normalized
    let neg_lx = -lx
    let neg_ly = -ly
    let neg_lz = -lz
    let cos_angle = neg_lx * sl.direction.x +
      neg_ly * sl.direction.y +
      neg_lz * sl.direction.z
    let cos_outer = @math.cos(sl.outer_angle)
    if cos_angle < cos_outer {
      continue
    }
    let cos_inner = @math.cos(sl.inner_angle)
    let spot_factor = if cos_angle >= cos_inner {
      1.0
    } else {
      let t = (cos_angle - cos_outer) / (cos_inner - cos_outer)
      t * t
    }
    let ndotl = world_normal.x * lx + world_normal.y * ly + world_normal.z * lz
    if ndotl <= 0.0 {
      continue
    }
    let ratio = dist / sl.radius
    let atten = clamp01(1.0 - ratio * ratio)
    extra = extra + ndotl * atten * spot_factor * sl.intensity
  }
  extra
}

///|
/// Project all visible triangles of a mesh into brightness-bucketed batches.
/// Each triangle is assigned to one of 8 buckets based on its face normal's NdotL
/// plus extra brightness from point/spot lights.
fn project_mesh_bucketed(
  mesh : @mesh3d.Mesh3D,
  mvp : @math3d.Mat4,
  model : @math3d.Mat4,
  light_dir : @math3d.Vec3,
  batches : Array[MeshBatch],
  point_lights : Array[@light3d.PointLight],
  spot_lights : Array[@light3d.SpotLight],
) -> Double {
  let vdata = mesh.vertex_data
  let indices = mesh.indices
  let stride = 8
  let tri_count = indices.length() / 3
  let mut z_sum = 0.0
  let mut total_tris = 0
  let has_extra_lights = point_lights.length() > 0 || spot_lights.length() > 0
  for t in 0..<tri_count {
    let i0 = indices[t * 3]
    let i1 = indices[t * 3 + 1]
    let i2 = indices[t * 3 + 2]
    let p0x = vdata[i0 * stride]
    let p0y = vdata[i0 * stride + 1]
    let p0z = vdata[i0 * stride + 2]
    let p1x = vdata[i1 * stride]
    let p1y = vdata[i1 * stride + 1]
    let p1z = vdata[i1 * stride + 2]
    let p2x = vdata[i2 * stride]
    let p2y = vdata[i2 * stride + 1]
    let p2z = vdata[i2 * stride + 2]
    let c0 = mat4_transform(mvp, p0x, p0y, p0z)
    let c1 = mat4_transform(mvp, p1x, p1y, p1z)
    let c2 = mat4_transform(mvp, p2x, p2y, p2z)
    if c0.3 <= 0.001 || c1.3 <= 0.001 || c2.3 <= 0.001 {
      continue
    }
    let ndc0x = c0.0 / c0.3
    let ndc0y = c0.1 / c0.3
    let ndc0z = c0.2 / c0.3
    let ndc1x = c1.0 / c1.3
    let ndc1y = c1.1 / c1.3
    let ndc1z = c1.2 / c1.3
    let ndc2x = c2.0 / c2.3
    let ndc2y = c2.1 / c2.3
    let ndc2z = c2.2 / c2.3
    if (ndc0x < -1.5 && ndc1x < -1.5 && ndc2x < -1.5) ||
      (ndc0x > 1.5 && ndc1x > 1.5 && ndc2x > 1.5) ||
      (ndc0y < -1.5 && ndc1y < -1.5 && ndc2y < -1.5) ||
      (ndc0y > 1.5 && ndc1y > 1.5 && ndc2y > 1.5) {
      continue
    }
    let e1x = ndc1x - ndc0x
    let e1y = ndc1y - ndc0y
    let e2x = ndc2x - ndc0x
    let e2y = ndc2y - ndc0y
    let cross_z = e1x * e2y - e1y * e2x
    if cross_z < 0.0 {
      continue
    }
    // Read face normal from first vertex (faces share normals per vertex data)
    let fnx = vdata[i0 * stride + 3]
    let fny = vdata[i0 * stride + 4]
    let fnz = vdata[i0 * stride + 5]
    // Transform normal to world space
    let world_normal = transform_normal_3x3(model, fnx, fny, fnz)
    // NdotL: light_dir points toward light (negated direction)
    let dir_ndotl = clamp01(world_normal.dot(light_dir))
    // Compute total brightness including point/spot lights
    let total_brightness = if has_extra_lights {
      let cx = (p0x + p1x + p2x) / 3.0
      let cy = (p0y + p1y + p2y) / 3.0
      let cz = (p0z + p1z + p2z) / 3.0
      let world_centroid = mat4_transform_point(model, cx, cy, cz)
      let extra = compute_extra_brightness(
        world_centroid, world_normal, point_lights, spot_lights,
      )
      clamp01(dir_ndotl + extra)
    } else {
      dir_ndotl
    }
    // Bucket index: 0 = darkest, bucket_count-1 = brightest
    let bucket_idx = (total_brightness * (bucket_count - 1).to_double() + 0.5).to_int()
    let bi = if bucket_idx >= bucket_count {
      bucket_count - 1
    } else if bucket_idx < 0 {
      0
    } else {
      bucket_idx
    }
    let batch = batches[bi]
    // Read UV coordinates from vertex data
    let u0 = vdata[i0 * stride + 6]
    let v0 = vdata[i0 * stride + 7]
    let u1 = vdata[i1 * stride + 6]
    let v1 = vdata[i1 * stride + 7]
    let u2 = vdata[i2 * stride + 6]
    let v2 = vdata[i2 * stride + 7]
    // Append vertices to batch (stride 4: x, y, u, v)
    let vi = batch.tri_count * 3
    batch.vertices.push(ndc0x)
    batch.vertices.push(ndc0y)
    batch.vertices.push(u0)
    batch.vertices.push(v0)
    batch.vertices.push(ndc1x)
    batch.vertices.push(ndc1y)
    batch.vertices.push(u1)
    batch.vertices.push(v1)
    batch.vertices.push(ndc2x)
    batch.vertices.push(ndc2y)
    batch.vertices.push(u2)
    batch.vertices.push(v2)
    batch.indices.push(vi)
    batch.indices.push(vi + 1)
    batch.indices.push(vi + 2)
    z_sum = z_sum + (ndc0z + ndc1z + ndc2z) / 3.0
    batch.tri_count = batch.tri_count + 1
    total_tris = total_tris + 1
  }
  if total_tris > 0 {
    z_sum / total_tris.to_double()
  } else {
    0.0
  }
}

///|
fn build_batch_draw_command(
  batch : MeshBatch,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
) -> @gfx.DrawTrianglesCommand {
  let index_count = batch.tri_count * 3
  let region = @gfx.new_dst_region(0, 0, screen_w, screen_h, index_count)
  let src_image_ids : Array[Int] = if batch.src_image_id >= 0 {
    [batch.src_image_id]
  } else {
    []
  }
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [region],
    0,
    0,
    0,
    @gfx.blend_mode_from_int(1),
    batch.vertices,
    batch.indices,
    src_image_ids,
    batch.color_dwords,
  )
}

///|
fn render_object(
  mesh : @mesh3d.Mesh3D,
  model_mat4 : @math3d.Mat4,
  color : @math3d.Vec4,
  material : Material?,
  vp : @math3d.Mat4,
  light_dir : @math3d.Vec3,
  lighting : @light3d.LightingEnvironment,
  all_batches : Array[(MeshBatch, Double)],
  frustum : Frustum,
) -> Unit {
  // Frustum culling: compute world-space AABB and test
  let (omin_x, omin_y, omin_z, omax_x, omax_y, omax_z) = compute_mesh_aabb(
    mesh,
  )
  let (wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) = transform_aabb(
    omin_x, omin_y, omin_z, omax_x, omax_y, omax_z, model_mat4,
  )
  if frustum_cull_aabb(frustum, wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) {
    return
  }
  let (col, src_image_id) = match material {
    Some(mat) => (mat.color, mat.src_image_id)
    None => (color, -1)
  }
  let bucket_colors = compute_bucket_colors(lighting, col)
  let buckets : Array[MeshBatch] = []
  for b in 0..<bucket_count {
    buckets.push(MeshBatch::new(bucket_colors[b], src_image_id~))
  }
  let mvp = vp.multiply(model_mat4)
  let avg_z = project_mesh_bucketed(
    mesh, mvp, model_mat4, light_dir, buckets,
    lighting.point_lights, lighting.spot_lights,
  )
  for b in 0..<bucket_count {
    if buckets[b].tri_count > 0 {
      all_batches.push((buckets[b], avg_z))
    }
  }
}

///|
fn collect_and_sort_commands(
  all_batches : Array[(MeshBatch, Double)],
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
) -> Array[@gfx.DrawTrianglesCommand] {
  all_batches.sort_by(fn(a, b) {
    if a.1 > b.1 {
      -1
    } else if a.1 < b.1 {
      1
    } else {
      0
    }
  })
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  for i in 0..<all_batches.length() {
    cmds.push(
      build_batch_draw_command(
        all_batches[i].0,
        dst,
        shader,
        screen_w,
        screen_h,
      ),
    )
  }
  cmds
}

///|
/// Render a 3D scene using CPU projection, producing an array of draw commands
/// sorted back-to-front for the painter's algorithm.
/// Uses per-face diffuse lighting with 8 brightness buckets per object.
pub fn render_scene3d(
  scene : Scene3D,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
) -> Array[@gfx.DrawTrianglesCommand] {
  let vp = scene.camera.view_projection_matrix()
  let frustum = Frustum::from_vp(vp)
  let light_dir = scene.lighting.directional.direction.negate()
  let all_batches : Array[(MeshBatch, Double)] = []
  for i in 0..<scene.objects.length() {
    let obj = scene.objects[i]
    let model = obj.transform.to_mat4()
    render_object(
      obj.mesh,
      model,
      obj.color,
      obj.material,
      vp,
      light_dir,
      scene.lighting,
      all_batches,
      frustum,
    )
  }
  collect_and_sort_commands(all_batches, dst, shader, screen_w, screen_h)
}

///|
pub fn render_scene3d_graph(
  graph : SceneGraph,
  camera : @camera3d.Camera3D,
  lighting? : @light3d.LightingEnvironment = @light3d.LightingEnvironment::default(),
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
) -> Array[@gfx.DrawTrianglesCommand] {
  let vp = camera.view_projection_matrix()
  let frustum = Frustum::from_vp(vp)
  let light_dir = lighting.directional.direction.negate()
  let all_batches : Array[(MeshBatch, Double)] = []
  let identity = @math3d.Mat4::identity()
  for i in 0..<graph.roots.length() {
    traverse_node(
      graph,
      graph.roots[i],
      identity,
      vp,
      light_dir,
      lighting,
      all_batches,
      frustum,
    )
  }
  collect_and_sort_commands(all_batches, dst, shader, screen_w, screen_h)
}

///|
fn traverse_node(
  graph : SceneGraph,
  node_id : Int,
  parent_world : @math3d.Mat4,
  vp : @math3d.Mat4,
  light_dir : @math3d.Vec3,
  lighting : @light3d.LightingEnvironment,
  all_batches : Array[(MeshBatch, Double)],
  frustum : Frustum,
) -> Unit {
  match graph.nodes.get(node_id) {
    None => ()
    Some(node) => {
      let world = parent_world.multiply(node.transform.to_mat4())
      match node.mesh {
        Some(mesh) =>
          render_object(
            mesh,
            world,
            node.color,
            node.material,
            vp,
            light_dir,
            lighting,
            all_batches,
            frustum,
          )
        None => ()
      }
      for i in 0..<node.children.length() {
        traverse_node(
          graph,
          node.children[i],
          world,
          vp,
          light_dir,
          lighting,
          all_batches,
          frustum,
        )
      }
    }
  }
}
