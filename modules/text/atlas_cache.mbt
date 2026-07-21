///|
/// GlyphAtlas persistent cache — delegates to @font serialization.

///|
/// Replace the first page of a TextRenderer with deserialized data.
/// Accepts a single page's serialized data (Array[Int]).
pub fn TextRenderer::load_atlas_cache(
  self : TextRenderer,
  data : Array[Int],
) -> Bool {
  let loaded = self.inner.load_cache([data])
  loaded > 0
}
