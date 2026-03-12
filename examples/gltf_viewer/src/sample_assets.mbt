///|
enum SampleAssetSource {
  DefaultGlb(String)
  ProxyChest
}

///|
fn default_glb_asset_path() -> String {
  "./assets/test_scene.glb"
}

///|
fn sample_asset_source_from_query_param(asset : String) -> SampleAssetSource {
  if asset == "proxy_chest" {
    ProxyChest
  } else if asset == "" {
    DefaultGlb(default_glb_asset_path())
  } else {
    DefaultGlb(asset)
  }
}

///|
fn build_proxy_chest_graph() -> @scene3d.SceneGraph {
  let graph = @scene3d.SceneGraph::new()
  let root = graph.add_node(@scene3d.scene_node())
  let wood = @math3d.Vec4::new(0.56, 0.42, 0.24, 1.0)
  let dark_wood = @math3d.Vec4::new(0.36, 0.24, 0.14, 1.0)
  let metal = @math3d.Vec4::new(0.72, 0.72, 0.68, 1.0)
  let lid_rot = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_x(),
    -0.9,
  )
  let _ = graph.add_child(
    root,
    @scene3d.scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
      position=@math3d.Vec3::new(0.0, 0.36, 0.0),
      scale=@math3d.Vec3::new(1.9, 0.72, 1.2),
      color=wood,
    ),
  )
  let _ = graph.add_child(
    root,
    @scene3d.scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
      position=@math3d.Vec3::new(0.0, 1.02, -0.42),
      rotation=lid_rot,
      scale=@math3d.Vec3::new(1.92, 0.24, 1.24),
      color=dark_wood,
    ),
  )
  let _ = graph.add_child(
    root,
    @scene3d.scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
      position=@math3d.Vec3::new(0.0, 0.5, 0.67),
      scale=@math3d.Vec3::new(0.24, 0.34, 0.16),
      color=metal,
    ),
  )
  let _ = graph.add_child(
    root,
    @scene3d.scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
      position=@math3d.Vec3::new(-0.92, 0.54, 0.0),
      scale=@math3d.Vec3::new(0.14, 0.58, 1.18),
      color=metal,
    ),
  )
  let _ = graph.add_child(
    root,
    @scene3d.scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
      position=@math3d.Vec3::new(0.92, 0.54, 0.0),
      scale=@math3d.Vec3::new(0.14, 0.58, 1.18),
      color=metal,
    ),
  )
  let _ = graph.add_child(
    root,
    @scene3d.scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
      position=@math3d.Vec3::new(-0.78, 0.0, -0.44),
      scale=@math3d.Vec3::new(0.18, 0.22, 0.18),
      color=dark_wood,
    ),
  )
  let _ = graph.add_child(
    root,
    @scene3d.scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
      position=@math3d.Vec3::new(0.78, 0.0, -0.44),
      scale=@math3d.Vec3::new(0.18, 0.22, 0.18),
      color=dark_wood,
    ),
  )
  let _ = graph.add_child(
    root,
    @scene3d.scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
      position=@math3d.Vec3::new(-0.78, 0.0, 0.44),
      scale=@math3d.Vec3::new(0.18, 0.22, 0.18),
      color=dark_wood,
    ),
  )
  let _ = graph.add_child(
    root,
    @scene3d.scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
      position=@math3d.Vec3::new(0.78, 0.0, 0.44),
      scale=@math3d.Vec3::new(0.18, 0.22, 0.18),
      color=dark_wood,
    ),
  )
  graph
}
