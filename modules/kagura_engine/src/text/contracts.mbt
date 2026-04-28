///|
/// Text contracts — GPU text rendering wrapper over mizchi/font.
///
/// GPU-independent types and logic are in mizchi/font.
/// This module adds GPU-specific rendering (draw commands, batch building).

///|
pub trait FontEngine {
  measure(Self, run : @font.TextRun) -> @font.TextMetrics
  shape(Self, run : @font.TextRun) -> Array[@font.GlyphQuad] raise
}

///|
pub trait TextBatchBuilder {
  build_draw_commands(
    Self,
    target : @gfx.ImageHandle,
    glyphs : Array[@font.GlyphQuad],
    shader : @gfx.ShaderHandle,
  ) -> Array[@gfx.DrawTrianglesCommand] raise
}

///|
/// Parse font from raw bytes (auto-detects TTF/OTF/WOFF1/WOFF2).
pub fn parse_font_bytes(data : Bytes) -> @font.TTFont? {
  @font.parse_font(data)
}

///|
/// Load font engine from raw bytes.
pub fn load_font_engine_from_bytes(data : Bytes) -> SimpleFontEngine? {
  match @font.parse_font(data) {
    Some(font) => Some(SimpleFontEngine::new(font))
    None => None
  }
}

///|
/// GPU-aware text renderer wrapping @font.TextRenderer.
/// Adds render_text() which produces @gfx.DrawTrianglesCommand.
pub struct TextRenderer {
  inner : @font.TextRenderer
}

///|
pub fn TextRenderer::new(
  font : @font.TTFont,
  atlas_size : Int,
  base_page_id : Int,
  pipeline_id : Int,
) -> TextRenderer {
  {
    inner: @font.TextRenderer::new(font, atlas_size, base_page_id, pipeline_id),
  }
}

///|
pub fn TextRenderer::new_with_options(
  font : @font.TTFont,
  atlas_size : Int,
  base_page_id : Int,
  pipeline_id : Int,
  max_pages : Int,
) -> TextRenderer {
  {
    inner: @font.TextRenderer::new_with_options(
      font, atlas_size, base_page_id, pipeline_id, max_pages,
    ),
  }
}

///|
/// Render text at the given position, returning draw commands ready
/// for the graphics pipeline. Also rasterizes any new glyphs into the atlas.
pub fn TextRenderer::render_text(
  self : TextRenderer,
  text : String,
  size_px : Double,
  x : Double,
  y : Double,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  blend : @gfx.BlendMode,
  uniform_dwords : Array[Int],
) -> Array[@gfx.DrawTrianglesCommand] {
  let font = self.inner.font
  let scale = size_px / font.units_per_em.to_double()
  let positions = font.layout_text(text, size_px)
  // Group: page_index -> Array[GlyphQuad]
  let page_quads : Map[Int, Array[@font.GlyphQuad]] = {}
  for pos in positions {
    if pos.glyph_id == 0 {
      continue
    }
    match self.inner.ensure_glyph(pos.codepoint, size_px) {
      None => continue
      Some((page_idx, entry)) => {
        let metrics = font.glyph_metrics(pos.glyph_id)
        let bbox = metrics.bbox
        let cache_key = @font.make_glyph_cache_key(pos.glyph_id, size_px)
        let dst_x = pos.x_offset +
          metrics.left_side_bearing.to_double() * scale +
          x
        let dst_y = -(bbox.y_max.to_double() * scale) + y
        let quad : @font.GlyphQuad = {
          glyph_id: cache_key,
          atlas_x: entry.atlas_x,
          atlas_y: entry.atlas_y,
          atlas_w: entry.atlas_w,
          atlas_h: entry.atlas_h,
          dst_x,
          dst_y,
          dst_w: entry.atlas_w,
          dst_h: entry.atlas_h,
        }
        match page_quads.get(page_idx) {
          Some(arr) => arr.push(quad)
          None => page_quads.set(page_idx, [quad])
        }
      }
    }
  }
  // Build draw commands per page
  let all_commands : Array[@gfx.DrawTrianglesCommand] = []
  page_quads.each(fn(page_idx, quads) {
    if quads.length() == 0 {
      return
    }
    let page = self.inner.get_page(page_idx)
    let builder = SimpleTextBatchBuilder::new(
      page.get_cache(),
      self.inner.pipeline_id,
    )
    let commands = builder.build_draw_commands(dst, quads, shader) catch {
      _ => return
    }
    if uniform_dwords.length() > 0 {
      for cmd in commands {
        all_commands.push(
          @gfx.new_draw_triangles_command(
            cmd.dst,
            cmd.shader,
            cmd.dst_regions,
            cmd.index_offset,
            cmd.pipeline_id,
            cmd.uniform_hash,
            blend,
            cmd.vertex_data,
            cmd.indices,
            cmd.src_image_ids,
            uniform_dwords,
          ),
        )
      }
    } else {
      for cmd in commands {
        all_commands.push(cmd)
      }
    }
  })
  all_commands
}

///|
/// Measure text dimensions without rasterizing.
pub fn TextRenderer::measure(
  self : TextRenderer,
  text : String,
  size_px : Double,
) -> @font.TextMetrics {
  self.inner.measure(text, size_px)
}

///|
pub fn TextRenderer::get_atlas(self : TextRenderer) -> @font.GlyphAtlas {
  self.inner.get_atlas()
}

///|
pub fn TextRenderer::get_page_id(self : TextRenderer) -> Int {
  self.inner.base_page_id
}

///|
pub fn TextRenderer::glyph_count(self : TextRenderer) -> Int {
  self.inner.glyph_count()
}

///|
pub fn TextRenderer::clear(self : TextRenderer) -> Unit {
  self.inner.clear()
}

///|
pub fn TextRenderer::page_count(self : TextRenderer) -> Int {
  self.inner.page_count()
}

///|
pub fn TextRenderer::get_page(
  self : TextRenderer,
  index : Int,
) -> @font.GlyphAtlas {
  self.inner.get_page(index)
}

///|
pub fn TextRenderer::get_page_ids(self : TextRenderer) -> Array[Int] {
  self.inner.get_page_ids()
}

///|
pub fn TextRenderer::flush_dirty_pages(
  self : TextRenderer,
) -> Array[@font.AtlasPageInfo] {
  self.inner.flush_dirty_pages()
}

// ---------------------------------------------------------------------------
// Font Load Hooks — pluggable font binary loading for platform integration
// ---------------------------------------------------------------------------

///|
pub struct FontLoadHooks {
  load_font_data : (String) -> Array[Int]?
}

///|
pub fn new_font_load_hooks(
  load_font_data : (String) -> Array[Int]?,
) -> FontLoadHooks {
  { load_font_data, }
}

///|
fn default_load_font_data(_name : String) -> Array[Int]? {
  None
}

///|
fn default_font_load_hooks() -> FontLoadHooks {
  { load_font_data: default_load_font_data }
}

///|
let font_load_hooks : Ref[FontLoadHooks] = Ref::new(default_font_load_hooks())

///|
pub fn set_font_load_hooks(hooks : FontLoadHooks) -> Unit {
  font_load_hooks.val = hooks
}

///|
pub fn reset_font_load_hooks() -> Unit {
  font_load_hooks.val = default_font_load_hooks()
}

///|
pub fn font_data_to_bytes(data : Array[Int]) -> Bytes {
  let arr : FixedArray[Byte] = FixedArray::make(data.length(), b'\x00')
  for i, v in data {
    arr[i] = v.to_byte()
  }
  Bytes::from_array(arr)
}

///|
pub fn load_font(name : String) -> @font.TTFont? {
  match (font_load_hooks.val.load_font_data)(name) {
    None => None
    Some(data) => {
      let bytes = font_data_to_bytes(data)
      parse_font_bytes(bytes)
    }
  }
}

///|
pub fn load_text_renderer(
  name : String,
  atlas_size : Int,
  page_id : Int,
  pipeline_id : Int,
) -> TextRenderer? {
  match load_font(name) {
    None => None
    Some(font) =>
      Some(TextRenderer::new(font, atlas_size, page_id, pipeline_id))
  }
}
