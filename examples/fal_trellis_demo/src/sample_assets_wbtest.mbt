///|
test "sample_asset_source_from_query_param falls back to default generated glb" {
  match sample_asset_source_from_query_param("") {
    DefaultGlb(path) => assert_eq(path, default_glb_asset_path())
  }
}

///|
test "sample_asset_source_from_query_param keeps explicit glb path" {
  match sample_asset_source_from_query_param("./assets/generated/custom.glb") {
    DefaultGlb(path) => assert_eq(path, "./assets/generated/custom.glb")
  }
}

///|
test "default_glb_asset_path points at generated sample asset" {
  assert_eq(
    default_glb_asset_path(),
    "./assets/generated/gltf-viewer-proxy-chest-trellis.glb",
  )
}
