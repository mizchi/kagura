// ============================================================
// CPU-side software 3D rendering for 2D pipeline
// ============================================================

///|
priv struct MeshBatch {
  vertices : Array[Double] // flat vertex buffer, stride 4 (x,y,u,v)
  indices : Array[Int] // index buffer
  color_dwords : Array[Int] // single color [r,g,b,a] for the batch
  mut avg_z : Double // average depth for mesh-level sorting
  mut tri_count : Int // number of visible triangles
}

///|
fn MeshBatch::new(color_dwords : Array[Int]) -> MeshBatch {
  { vertices: [], indices: [], color_dwords, avg_z: 0.0, tri_count: 0 }
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
/// Compute per-mesh lighting color (ambient + hemisphere-average diffuse).
fn compute_mesh_color(
  lighting : @light3d.LightingEnvironment,
  color : @math3d.Vec4,
) -> Array[Int] {
  let amb_r = lighting.ambient.color.x * lighting.ambient.intensity
  let amb_g = lighting.ambient.color.y * lighting.ambient.intensity
  let amb_b = lighting.ambient.color.z * lighting.ambient.intensity
  // Average diffuse: hemisphere average NdotL ≈ 0.5
  let avg_ndotl = 0.5
  let diff_r = lighting.directional.color.x *
    lighting.directional.intensity *
    avg_ndotl
  let diff_g = lighting.directional.color.y *
    lighting.directional.intensity *
    avg_ndotl
  let diff_b = lighting.directional.color.z *
    lighting.directional.intensity *
    avg_ndotl
  [
    to_byte(color.x * (diff_r + amb_r)),
    to_byte(color.y * (diff_g + amb_g)),
    to_byte(color.z * (diff_b + amb_b)),
    to_byte(color.w),
  ]
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
/// Project all visible triangles of a mesh into a single batch.
fn project_mesh_batched(
  mesh : @mesh3d.Mesh3D,
  mvp : @math3d.Mat4,
  batch : MeshBatch,
) -> Unit {
  let vdata = mesh.vertex_data
  let indices = mesh.indices
  let stride = 8
  let tri_count = indices.length() / 3
  let mut z_sum = 0.0
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
    // Append vertices to batch (stride 4: x, y, u, v)
    let vi = batch.tri_count * 3
    batch.vertices.push(ndc0x)
    batch.vertices.push(ndc0y)
    batch.vertices.push(0.0)
    batch.vertices.push(0.0)
    batch.vertices.push(ndc1x)
    batch.vertices.push(ndc1y)
    batch.vertices.push(0.0)
    batch.vertices.push(0.0)
    batch.vertices.push(ndc2x)
    batch.vertices.push(ndc2y)
    batch.vertices.push(0.0)
    batch.vertices.push(0.0)
    batch.indices.push(vi)
    batch.indices.push(vi + 1)
    batch.indices.push(vi + 2)
    z_sum = z_sum + (ndc0z + ndc1z + ndc2z) / 3.0
    batch.tri_count = batch.tri_count + 1
  }
  if batch.tri_count > 0 {
    batch.avg_z = z_sum / batch.tri_count.to_double()
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
    [],
    batch.color_dwords,
  )
}

///|
/// Render a 3D scene using CPU projection, producing an array of draw commands
/// sorted back-to-front for the painter's algorithm.
pub fn render_scene3d(
  scene : Scene3D,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
) -> Array[@gfx.DrawTrianglesCommand] {
  let vp = scene.camera.view_projection_matrix()
  let batches : Array[MeshBatch] = []
  for i in 0..<scene.objects.length() {
    let obj = scene.objects[i]
    let color_dwords = compute_mesh_color(scene.lighting, obj.color)
    let batch = MeshBatch::new(color_dwords)
    let model = obj.transform.to_mat4()
    let mvp = vp.multiply(model)
    project_mesh_batched(obj.mesh, mvp, batch)
    if batch.tri_count > 0 {
      batches.push(batch)
    }
  }
  // Sort batches back-to-front (mesh-level depth sorting)
  batches.sort_by(fn(a, b) {
    if a.avg_z > b.avg_z {
      -1
    } else if a.avg_z < b.avg_z {
      1
    } else {
      0
    }
  })
  // One draw command per batch
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  for i in 0..<batches.length() {
    cmds.push(build_batch_draw_command(batches[i], dst, shader, screen_w, screen_h))
  }
  cmds
}
