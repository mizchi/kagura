///|
enum SampleAssetSource {
  DefaultGlb(String)
}

///|
fn default_glb_asset_path() -> String {
  "./assets/test_scene.glb"
}

///|
fn sample_asset_source_from_query_param(asset : String) -> SampleAssetSource {
  if asset == "" {
    DefaultGlb(default_glb_asset_path())
  } else {
    DefaultGlb(asset)
  }
}
