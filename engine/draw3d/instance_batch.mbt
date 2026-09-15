///|
/// Instances sharing one mesh and shader. Clear and refill between frames.
/// Submitted commands own their uniforms; geometry is shared with the mesh.
pub struct InstancedMeshBatch {
  priv mesh : @mesh3d.Mesh3D
  priv matrices : Array[@math3d.Mat4]
  priv colors : Array[@math3d.Vec4]
}

///|
pub fn InstancedMeshBatch::new(mesh : @mesh3d.Mesh3D) -> InstancedMeshBatch {
  { mesh, matrices: [], colors: [], }
}

///|
pub fn InstancedMeshBatch::clear(self : InstancedMeshBatch) -> Unit {
  self.matrices.clear()
  self.colors.clear()
}

///|
pub fn InstancedMeshBatch::length(self : InstancedMeshBatch) -> Int {
  self.matrices.length()
}

///|
pub fn InstancedMeshBatch::triangle_count(self : InstancedMeshBatch) -> Int {
  self.mesh.indices.length() / 3 * self.length()
}

///|
pub fn InstancedMeshBatch::push(
  self : InstancedMeshBatch,
  matrix : @math3d.Mat4,
  color? : @math3d.Vec4 = @math3d.Vec4::new(1, 1, 1, 1),
) -> Unit {
  self.matrices.push(matrix)
  self.colors.push(color)
}

///|
/// Place a mesh whose longitudinal endpoints are (0,0,-1) and (0,0,+1).
/// Skip lengths below 0.001 and nonpositive radii, returning false.
pub fn InstancedMeshBatch::push_segment(
  self : InstancedMeshBatch,
  start : @math3d.Vec3,
  end : @math3d.Vec3,
  radius : Double,
  color? : @math3d.Vec4 = @math3d.Vec4::new(1, 1, 1, 1),
) -> Bool {
  let delta = end.sub(start)
  let length = delta.length()
  if length < 0.001 || radius <= 0 {
    return false
  }
  let middle = start.lerp(end, 0.5)
  let yaw = @math.atan2(delta.x, delta.z)
  let pitch = -@math.atan2(
    delta.y,
    (delta.x * delta.x + delta.z * delta.z).sqrt(),
  )
  self.push(
    @math3d.Mat4::translation(middle.x, middle.y, middle.z)
    .multiply(@math3d.Mat4::rotation_y(yaw))
    .multiply(@math3d.Mat4::rotation_x(pitch))
    .multiply(@math3d.Mat4::scaling(radius, radius, length * 0.5)),
    color~,
  )
  true
}

///|
/// Append in insertion order, splitting at the instanced-lit shader's capacity.
/// Custom shaders must use the same instanced-lit uniform layout. No culling,
/// sorting, static GPU registration or material policy is imposed here.
pub fn InstancedMeshBatch::append_draw_commands(
  self : InstancedMeshBatch,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  width : Int,
  height : Int,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  commands : Array[@gfx.DrawTrianglesCommand],
  blend? : @gfx.BlendMode = @gfx.BlendMode::from_int(0),
) -> Unit {
  for start = 0; start < self.length(); start = start + max_instances {
    let end = (start + max_instances).min(self.length())
    commands.push(
      new_instanced_lit_mesh_draw_command(
        dst,
        shader,
        @gfx.new_dst_region(0, 0, width, height, self.mesh.indices.length()),
        blend,
        self.mesh,
        view_projection,
        lighting,
        self.matrices[start:end].to_array(),
        self.colors[start:end].to_array(),
      ),
    )
  }
}
