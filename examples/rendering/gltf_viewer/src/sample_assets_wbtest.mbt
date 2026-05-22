///|
test "sample_asset_source_from_query_param falls back to default glb" {
  match sample_asset_source_from_query_param("") {
    DefaultGlb(path) => assert_eq(path, default_glb_asset_path())
  }
}

///|
test "sample_asset_source_from_query_param keeps explicit glb path" {
  match sample_asset_source_from_query_param("./assets/custom.glb") {
    DefaultGlb(path) => assert_eq(path, "./assets/custom.glb")
  }
}
