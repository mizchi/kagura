///|
fn build_scene_graph(
  doc : GltfDocument,
  scene_index : Int,
  buffers : Array[Bytes],
) -> @scene3d.SceneGraph raise GltfError {
  let graph = @scene3d.SceneGraph::new()
  let mesh_cache : Map[Int, @mesh3d.Mesh3D] = {}
  if scene_index < 0 || scene_index >= doc.scenes.length() {
    return graph
  }
  let scene = doc.scenes[scene_index]
  for node_idx in scene.nodes {
    add_node_recursive(doc, buffers, graph, node_idx, None, mesh_cache)
  }
  graph
}

///|
fn add_node_recursive(
  doc : GltfDocument,
  buffers : Array[Bytes],
  graph : @scene3d.SceneGraph,
  node_index : Int,
  parent_id : Int?,
  mesh_cache : Map[Int, @mesh3d.Mesh3D],
) -> Unit raise GltfError {
  if node_index < 0 || node_index >= doc.nodes.length() {
    return
  }
  let node = doc.nodes[node_index]
  let mesh : @mesh3d.Mesh3D? = match node.mesh {
    Some(mi) =>
      match mesh_cache.get(mi) {
        Some(m) => Some(m)
        None => {
          let m = build_mesh(doc, mi, buffers)
          mesh_cache[mi] = m
          Some(m)
        }
      }
    None => None
  }
  let material : @scene3d.Material? = match node.mesh {
    Some(mi) =>
      if mi < doc.meshes.length() && doc.meshes[mi].primitives.length() > 0 {
        match doc.meshes[mi].primitives[0].material {
          Some(mat_idx) =>
            if mat_idx < doc.materials.length() {
              let mat = doc.materials[mat_idx]
              Some({ color: mat.base_color_factor, src_image_id: -1 })
            } else {
              None
            }
          None => None
        }
      } else {
        None
      }
    None => None
  }
  let color = match material {
    Some(m) => m.color
    None => @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
  }
  let scene_node = @scene3d.scene_node(
    mesh~,
    position=node.translation,
    rotation=node.rotation,
    scale=node.scale,
    color~,
    material~,
  )
  let id = match parent_id {
    Some(pid) => graph.add_child(pid, scene_node)
    None => graph.add_node(scene_node)
  }
  for child_idx in node.children {
    add_node_recursive(doc, buffers, graph, child_idx, Some(id), mesh_cache)
  }
}
