///|
enum SampleAssetSource {
  DefaultGlb(String)
}

///|
fn default_glb_asset_path() -> String {
  "./assets/generated/gltf-viewer-proxy-chest-trellis.glb"
}

///|
fn sample_asset_source_from_query_param(asset : String) -> SampleAssetSource {
  if asset == "" {
    DefaultGlb(default_glb_asset_path())
  } else {
    DefaultGlb(asset)
  }
}
