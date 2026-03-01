///|
pub fn mesh_from_gltf(
  source : String,
  buffers : Array[Bytes],
) -> @mesh3d.Mesh3D raise GltfError {
  let root = @json.parse(source) catch {
    _ => raise GltfError::ParseError("invalid JSON")
  }
  let doc = parse_document(root)
  if doc.meshes.is_empty() {
    return @mesh3d.Mesh3D::new([], [])
  }
  let all_vertex_data : Array[Double] = []
  let all_indices : Array[Int] = []
  for i in 0..<doc.meshes.length() {
    let m = build_mesh(doc, i, buffers)
    let base = all_vertex_data.length() / 8
    for v in m.vertex_data {
      all_vertex_data.push(v)
    }
    for idx in m.indices {
      all_indices.push(idx + base)
    }
  }
  @mesh3d.Mesh3D::new(all_vertex_data, all_indices)
}

///|
pub fn meshes_from_gltf(
  source : String,
  buffers : Array[Bytes],
) -> Array[@mesh3d.Mesh3D] raise GltfError {
  let root = @json.parse(source) catch {
    _ => raise GltfError::ParseError("invalid JSON")
  }
  let doc = parse_document(root)
  let result : Array[@mesh3d.Mesh3D] = []
  for i in 0..<doc.meshes.length() {
    result.push(build_mesh(doc, i, buffers))
  }
  result
}

///|
pub fn scene_graph_from_gltf(
  source : String,
  buffers : Array[Bytes],
  scene_index? : Int,
) -> @scene3d.SceneGraph raise GltfError {
  let root = @json.parse(source) catch {
    _ => raise GltfError::ParseError("invalid JSON")
  }
  let doc = parse_document(root)
  let idx = match scene_index {
    Some(i) => i
    None => doc.default_scene
  }
  build_scene_graph(doc, idx, buffers)
}

///|
/// Load a skinned scene from glTF, returning the scene graph, skeleton,
/// animation clips, and skin data.
pub fn skinned_scene_from_gltf(
  source : String,
  buffers : Array[Bytes],
  scene_index? : Int,
) -> (
  @scene3d.SceneGraph,
  @skeleton3d.Skeleton?,
  Array[@animation3d.AnimationClip],
  @skeleton3d.SkinData?,
) raise GltfError {
  let root = @json.parse(source) catch {
    _ => raise GltfError::ParseError("invalid JSON")
  }
  let doc = parse_document(root)
  let idx = match scene_index {
    Some(i) => i
    None => doc.default_scene
  }
  let graph = build_scene_graph(doc, idx, buffers)
  if doc.skins.is_empty() {
    return (graph, None, [], None)
  }
  // Use the first skin
  let skeleton = skeleton_from_gltf(doc, 0, buffers)
  let skin_data = skin_data_from_gltf(doc, 0, buffers)
  let clips = animations_from_gltf(doc, 0, buffers)
  (graph, Some(skeleton), clips, skin_data)
}
