///|
test "sample_asset_source_from_query_param selects proxy chest" {
  match sample_asset_source_from_query_param("proxy_chest") {
    ProxyChest => ()
    DefaultGlb(_) => fail("expected proxy chest asset")
  }
}

///|
test "sample_asset_source_from_query_param falls back to default glb" {
  match sample_asset_source_from_query_param("") {
    ProxyChest => fail("expected default glb asset")
    DefaultGlb(path) => assert_eq(path, default_glb_asset_path())
  }
}

///|
test "build_proxy_chest_graph creates multi-part chest silhouette" {
  let graph = build_proxy_chest_graph()
  assert_eq(graph.roots.length(), 1)
  let mut mesh_node_count = 0
  let mut rotated_lid_count = 0
  let mut foot_count = 0
  for _, node in graph.nodes {
    if node.mesh is Some(_) {
      mesh_node_count = mesh_node_count + 1
      if node.transform.position.y > 0.8 &&
        !node.transform.rotation.approx_eq(
          @math3d.Quaternion::identity(),
          1.0e-6,
        ) {
        rotated_lid_count = rotated_lid_count + 1
      }
      if node.transform.position.y < 0.05 {
        foot_count = foot_count + 1
      }
    }
  }
  assert_true(mesh_node_count >= 8)
  assert_true(rotated_lid_count >= 1)
  assert_true(foot_count >= 4)
}
