///|
/// Immutable bind geometry for GPU skinning, with an independent lazy CPU cache.
/// GPU bind data can be shared across poses. CPU callers retaining different
/// simultaneous poses need separate assets because the CPU buffer is borrowed.
/// Change the CPU pose revision whenever matrices change, including rig switches.
/// Mesh uses position/normal/UV vertices (stride 8); skin has four influences
/// per vertex. Both inputs remain immutable for the lifetime of the asset.
pub struct SkinnedMeshAsset {
  bind_mesh : @mesh3d.Mesh3D
  skin_data : @skeleton3d.SkinData
  packed_vertex_data : Array[Double]
  priv mut cached_mesh : @mesh3d.Mesh3D?
  priv mut cached_revision : Int?
  priv mut builds : Int
}

///|
pub fn SkinnedMeshAsset::new(
  mesh : @mesh3d.Mesh3D,
  skin : @skeleton3d.SkinData,
) -> SkinnedMeshAsset {
  {
    bind_mesh: mesh,
    skin_data: skin,
    packed_vertex_data: @skeleton3d.build_skinned_vertex_data(mesh, skin),
    cached_mesh: None,
    cached_revision: None,
    builds: 0,
  }
}

///|
/// CPU deformation only occurs for a requested, changed pose. Returned vertex
/// storage is borrowed until the next revision; copy it to retain an old pose.
/// GPU callers can use packed_vertex_data without allocating a CPU mesh.
pub fn SkinnedMeshAsset::skinned_mesh(
  self : SkinnedMeshAsset,
  pose_revision : Int,
  skinning : Array[@math3d.Mat4],
) -> @mesh3d.Mesh3D {
  if self.cached_revision == Some(pose_revision) {
    if self.cached_mesh is Some(mesh) {
      return mesh
    }
  }
  let vertices = match self.cached_mesh {
    Some(mesh) => mesh.vertex_data
    None => Array::make(self.bind_mesh.vertex_data.length(), 0.0)
  }
  @skeleton3d.apply_skin_into(
    self.bind_mesh,
    self.skin_data,
    skinning,
    vertices,
  )
  let mesh = @mesh3d.Mesh3D::new(vertices, self.bind_mesh.indices)
  self.cached_mesh = Some(mesh)
  self.cached_revision = Some(pose_revision)
  self.builds += 1
  mesh
}

///|
pub fn SkinnedMeshAsset::cpu_skin_count(self : SkinnedMeshAsset) -> Int {
  self.builds
}
